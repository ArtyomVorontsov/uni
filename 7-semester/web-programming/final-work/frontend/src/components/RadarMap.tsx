import React from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import { Flight } from '../types/flight';

interface RadarMapProps {
  flights: Flight[];
  selectedFlight: Flight | null;
  searchTerm: string;
  onSearchChange: (value: string) => void;
  onSelectFlight: (flight: Flight) => void;
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

function ChangeMapView({ center }: { center: [number, number] }) {
  const map = useMap();
  map.setView(center, map.getZoom());
  return null;
}

export const RadarMap: React.FC<RadarMapProps> = ({
  flights,
  selectedFlight,
  searchTerm,
  onSearchChange,
  onSelectFlight,
}) => {
  const mapCenter: [number, number] = selectedFlight
    ? [selectedFlight.latitude, selectedFlight.longitude]
    : [56.9496, 24.1052];

  const tileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  return (
    <div className="map-wrapper">
      <div className="map-overlay-search">
        <input
          type="text"
          placeholder="Search callsign, country, or ICAO24..."
          value={searchTerm}
          onChange={(e) => onSearchChange(e.target.value)}
        />
      </div>

      <MapContainer center={mapCenter} zoom={6} scrollWheelZoom={true}>
        <ChangeMapView center={mapCenter} />
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url={tileUrl}
        />

        {flights.map((flight) => (
          <Marker
            key={flight.icao24}
            position={[flight.latitude, flight.longitude]}
            icon={createPlaneIcon(
              flight.heading,
              selectedFlight?.icao24 === flight.icao24
            )}
            eventHandlers={{
              click: () => onSelectFlight(flight),
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
  );
};
