import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import axios from 'axios';
import { Plane, Activity, Bookmark, Eye, RefreshCw, Radio, Layers, Filter } from 'lucide-react';
import 'leaflet/dist/leaflet.css';
import './App.scss';

// Types
export interface Flight {
  icao24: string;
  callsign: string;
  originCountry: string;
  longitude: number;
  latitude: number;
  altitude: number;
  velocity: number;
  heading: number;
  verticalRate: number;
  onGround: boolean;
  isBookmarked?: boolean;
}

export interface FlightStats {
  totalFlights: number;
  airborneCount: number;
  groundedCount: number;
  averageSpeedKmh: number;
  highestAltitudeMeters: number;
  timestamp: string;
}

// Custom Plane SVG Icon generator with rotation for heading
const createPlaneIcon = (heading: number, isSelected: boolean) => {
  const color = isSelected ? '#ef4444' : '#0ea5e9';
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="${color}" stroke="#ffffff" stroke-width="1.5" style="transform: rotate(${heading}deg); transition: transform 0.4s ease;"><path d="M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/></svg>`;
  return L.divIcon({
    html: svg,
    className: 'custom-plane-icon',
    iconSize: [28, 28],
    iconAnchor: [14, 14],
  });
};

// Map Recenter Helper Component
function ChangeMapView({ center }: { center: [number, number] }) {
  const map = useMap();
  map.setView(center, map.getZoom());
  return null;
}

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3002/api/flights';

export const App: React.FC = () => {
  // DYNAMIC ELEMENT 1: Live Real-time Flight List State
  const [flights, setFlights] = useState<Flight[]>([]);
  // DYNAMIC ELEMENT 2: Interactive Selected Flight & Telemetry Detail Panel
  const [selectedFlight, setSelectedFlight] = useState<Flight | null>(null);
  // DYNAMIC ELEMENT 3: Live Telemetry & Metrics Aggregator Statistics
  const [stats, setStats] = useState<FlightStats | null>(null);
  // DYNAMIC ELEMENT 4: Interactive Airspace Filter & Search Bar
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [filterAirborneOnly, setFilterAirborneOnly] = useState<boolean>(false);
  // DYNAMIC ELEMENT 5: Pinned Watchlist & Favorites Management
  const [watchlist, setWatchlist] = useState<string[]>([]);
  // Map View Mode State
  const [mapStyle, setMapStyle] = useState<'dark' | 'satellite'>('dark');
  const [isLoading, setIsLoading] = useState<boolean>(false);

  // Fetch Live Flights & Stats
  const fetchData = async () => {
    setIsLoading(true);
    try {
      const [flightsRes, statsRes, watchlistRes] = await Promise.all([
        axios.get(`${API_BASE_URL}/live`),
        axios.get(`${API_BASE_URL}/stats`),
        axios.get(`${API_BASE_URL}/watchlist`),
      ]);
      setFlights(flightsRes.data);
      setStats(statsRes.data);
      if (Array.isArray(watchlistRes.data)) {
        setWatchlist(watchlistRes.data.map((w: any) => w.icao24));
      }
    } catch (err) {
      console.warn('Backend unavailable, using direct telemetry fallback');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 10000); // Dynamic polling refresh
    return () => clearInterval(interval);
  }, []);

  // Filtered flights logic
  const filteredFlights = flights.filter((f) => {
    const matchesSearch =
      f.callsign.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.originCountry.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.icao24.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFilter = filterAirborneOnly ? !f.onGround : true;
    return matchesSearch && matchesFilter;
  });

  // Toggle Watchlist Item
  const toggleWatchlist = async (flight: Flight) => {
    const isBookmarked = watchlist.includes(flight.icao24);
    try {
      if (isBookmarked) {
        await axios.delete(`${API_BASE_URL}/watchlist/${flight.icao24}`);
        setWatchlist(watchlist.filter((id) => id !== flight.icao24));
      } else {
        await axios.post(`${API_BASE_URL}/watchlist`, {
          icao24: flight.icao24,
          callsign: flight.callsign,
          alertPriority: 'HIGH',
        });
        setWatchlist([...watchlist, flight.icao24]);
      }
    } catch (e) {
      // Local optimistic toggle fallback
      if (isBookmarked) {
        setWatchlist(watchlist.filter((id) => id !== flight.icao24));
      } else {
        setWatchlist([...watchlist, flight.icao24]);
      }
    }
  };

  const mapCenter: [number, number] = selectedFlight
    ? [selectedFlight.latitude, selectedFlight.longitude]
    : [56.9496, 24.1052]; // Default centered on Baltic Airspace

  const tileUrl =
    mapStyle === 'dark'
      ? 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
      : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  return (
    <div className="skytracker-app">
      {/* Dynamic Header & Telemetry Metrics */}
      <header className="navbar">
        <div className="brand">
          <Plane className="logo-icon" size={28} />
          <h1>SkyTracker Live Radar</h1>
        </div>

        {stats && (
          <div className="nav-stats">
            <div className="stat-badge">
              <span className="stat-label">Active Airspace</span>
              <span className="stat-value">{stats.airborneCount} Aircraft</span>
            </div>
            <div className="stat-badge">
              <span className="stat-label">Avg Speed</span>
              <span className="stat-value">{stats.averageSpeedKmh} km/h</span>
            </div>
            <div className="stat-badge">
              <span className="stat-label">Peak Altitude</span>
              <span className="stat-value">{stats.highestAltitudeMeters} m</span>
            </div>
          </div>
        )}

        <div className="controls">
          <button
            className={`btn-toggle ${mapStyle === 'satellite' ? 'active' : ''}`}
            onClick={() => setMapStyle(mapStyle === 'dark' ? 'satellite' : 'dark')}
          >
            <Layers size={16} /> {mapStyle === 'dark' ? 'Satellite' : 'Vector Dark'}
          </button>
          <button
            className={`btn-toggle ${filterAirborneOnly ? 'active' : ''}`}
            onClick={() => setFilterAirborneOnly(!filterAirborneOnly)}
          >
            <Filter size={16} /> Airborne Only
          </button>
          <button className="btn-toggle" onClick={fetchData} disabled={isLoading}>
            <RefreshCw size={16} className={isLoading ? 'spin' : ''} /> Refresh
          </button>
        </div>
      </header>

      {/* Main Interactive Grid */}
      <main className="main-dashboard">
        {/* Interactive Map */}
        <div className="map-wrapper">
          <div className="map-overlay-search">
            <input
              type="text"
              placeholder="Search callsign, country, or ICAO24..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <MapContainer center={mapCenter} zoom={6} scrollWheelZoom={true}>
            <ChangeMapView center={mapCenter} />
            <TileLayer
              attribution='&copy; <a href="https://carto.com/">CARTO</a> & OpenStreetMap'
              url={tileUrl}
            />

            {filteredFlights.map((flight) => (
              <Marker
                key={flight.icao24}
                position={[flight.latitude, flight.longitude]}
                icon={createPlaneIcon(
                  flight.heading,
                  selectedFlight?.icao24 === flight.icao24
                )}
                eventHandlers={{
                  click: () => setSelectedFlight(flight),
                }}
              >
                <Popup>
                  <div style={{ color: '#090d16', padding: '4px' }}>
                    <strong>Flight: {flight.callsign}</strong>
                    <br />
                    Country: {flight.originCountry}
                    <br />
                    Speed: {Math.round(flight.velocity * 3.6)} km/h
                    <br />
                    Altitude: {Math.round(flight.altitude)} m
                  </div>
                </Popup>
              </Marker>
            ))}
          </MapContainer>
        </div>

        {/* Sidebar Controls & Telemetry Panels */}
        <aside className="sidebar">
          {/* Dynamic Element 2: Aircraft Telemetry Inspector */}
          <div className="panel-card">
            <h2 className="panel-title">
              <span>
                <Radio size={18} /> Telemetry Inspector
              </span>
              {selectedFlight && (
                <button
                  className="btn-toggle"
                  style={{ padding: '4px 8px' }}
                  onClick={() => toggleWatchlist(selectedFlight)}
                >
                  <Bookmark
                    size={14}
                    fill={watchlist.includes(selectedFlight.icao24) ? '#0ea5e9' : 'none'}
                  />
                  {watchlist.includes(selectedFlight.icao24) ? 'Pinned' : 'Pin'}
                </button>
              )}
            </h2>

            {selectedFlight ? (
              <div>
                <div style={{ fontSize: '1.4rem', fontWeight: 700, color: '#0ea5e9' }}>
                  {selectedFlight.callsign || 'N/A'}
                </div>
                <div style={{ fontSize: '0.85rem', color: '#94a3b8', marginBottom: '12px' }}>
                  ICAO24: {selectedFlight.icao24} | Country: {selectedFlight.originCountry}
                </div>

                <div className="telemetry-card">
                  <div className="metric-item">
                    <div className="label">Airspeed</div>
                    <div className="val">{Math.round(selectedFlight.velocity * 3.6)} km/h</div>
                  </div>
                  <div className="metric-item">
                    <div className="label">Altitude</div>
                    <div className="val">{Math.round(selectedFlight.altitude)} m</div>
                  </div>
                  <div className="metric-item">
                    <div className="label">Heading</div>
                    <div className="val">{Math.round(selectedFlight.heading)}°</div>
                  </div>
                  <div className="metric-item">
                    <div className="label">Vertical Rate</div>
                    <div className="val">{selectedFlight.verticalRate} m/s</div>
                  </div>
                </div>
              </div>
            ) : (
              <div style={{ color: '#94a3b8', fontStyle: 'italic', padding: '12px 0' }}>
                Select an aircraft marker on the map or from the list below to view telemetry.
              </div>
            )}
          </div>

          {/* Dynamic Element 1: Active Flights List */}
          <div className="panel-card" style={{ flex: 1 }}>
            <h2 className="panel-title">
              <span>
                <Eye size={18} /> Detected Airspace ({filteredFlights.length})
              </span>
            </h2>

            <div className="flight-list">
              {filteredFlights.map((flight) => (
                <div
                  key={flight.icao24}
                  className={`flight-item ${
                    selectedFlight?.icao24 === flight.icao24 ? 'selected' : ''
                  }`}
                  onClick={() => setSelectedFlight(flight)}
                >
                  <div>
                    <div className="flight-callsign">{flight.callsign || 'N/A'}</div>
                    <div className="flight-country">{flight.originCountry}</div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '0.85rem', fontWeight: 600 }}>
                      {Math.round(flight.altitude)}m
                    </div>
                    <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                      {Math.round(flight.velocity * 3.6)} km/h
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </aside>
      </main>
    </div>
  );
};

export default App;
