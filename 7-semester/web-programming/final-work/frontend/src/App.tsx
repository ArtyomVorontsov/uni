import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { Header } from './components/Header';
import { RadarMap } from './components/RadarMap';
import { TelemetryInspector } from './components/TelemetryInspector';
import { FlightList } from './components/FlightList';
import { Flight, FlightStats } from './types/flight';
import 'leaflet/dist/leaflet.css';
import './App.scss';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3002/api/flights';

export const App: React.FC = () => {
  const [flights, setFlights] = useState<Flight[]>([]);
  const [selectedFlight, setSelectedFlight] = useState<Flight | null>(null);
  const [stats, setStats] = useState<FlightStats | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [filterAirborneOnly, setFilterAirborneOnly] = useState<boolean>(false);
  const [watchlist, setWatchlist] = useState<string[]>([]);
  const [mapStyle, setMapStyle] = useState<'dark' | 'satellite'>('dark');
  const [isLoading, setIsLoading] = useState<boolean>(false);

  // Simple fetch — no bounds, always returns full stable pool
  const fetchData = async () => {
    setIsLoading(true);
    try {
      const [flightsRes, statsRes, watchlistRes] = await Promise.all([
        axios.get(`${API_BASE_URL}/live`),
        axios.get(`${API_BASE_URL}/stats`),
        axios.get(`${API_BASE_URL}/watchlist`),
      ]);
      // Merge incoming flights with existing to preserve positions during transition
      setFlights(flightsRes.data);
      setStats(statsRes.data);
      if (Array.isArray(watchlistRes.data)) {
        setWatchlist(watchlistRes.data.map((w: any) => w.icao24));
      }
    } catch (err) {
      console.warn('Backend API request failed');
    } finally {
      setIsLoading(false);
    }
  };

  // Poll every 5 seconds — interval never rebuilds so no glitches
  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  // Filtered flights — purely client-side filtering, no re-fetching
  const filteredFlights = flights.filter((f) => {
    const matchesSearch =
      f.callsign.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.originCountry.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.icao24.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFilter = filterAirborneOnly ? !f.onGround : true;
    return matchesSearch && matchesFilter;
  });

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
      if (isBookmarked) {
        setWatchlist(watchlist.filter((id) => id !== flight.icao24));
      } else {
        setWatchlist([...watchlist, flight.icao24]);
      }
    }
  };

  return (
    <div className="skytracker-app">
      <Header
        stats={stats}
        mapStyle={mapStyle}
        filterAirborneOnly={filterAirborneOnly}
        isLoading={isLoading}
        onToggleMapStyle={() => setMapStyle(mapStyle === 'dark' ? 'satellite' : 'dark')}
        onToggleAirborneFilter={() => setFilterAirborneOnly(!filterAirborneOnly)}
        onRefresh={fetchData}
      />

      <main className="main-dashboard">
        <RadarMap
          flights={filteredFlights}
          selectedFlight={selectedFlight}
          searchTerm={searchTerm}
          mapStyle={mapStyle}
          onSearchChange={setSearchTerm}
          onSelectFlight={setSelectedFlight}
        />

        <aside className="sidebar">
          <TelemetryInspector
            selectedFlight={selectedFlight}
            watchlist={watchlist}
            onToggleWatchlist={toggleWatchlist}
          />

          <FlightList
            flights={filteredFlights}
            selectedFlight={selectedFlight}
            onSelectFlight={setSelectedFlight}
          />
        </aside>
      </main>
    </div>
  );
};

export default App;
