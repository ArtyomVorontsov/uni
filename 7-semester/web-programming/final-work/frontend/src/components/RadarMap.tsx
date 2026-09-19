import React, { useRef, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import { Flight } from '../types/flight';

interface RadarMapProps {
  flights: Flight[];
  selectedFlight: Flight | null;
  searchTerm: string;
  mapStyle: 'dark' | 'satellite';
  onSearchChange: (value: string) => void;
  onSelectFlight: (flight: Flight) => void;
}

function createPlaneIcon(heading: number, isSelected: boolean) {
  const color = isSelected ? '#ef4444' : '#0ea5e9';
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24"
    fill="${color}" stroke="#fff" stroke-width="1.5"
    style="transform:rotate(${heading}deg);display:block;">
    <path d="M21 16v-2l-8-5V3.5c0-.83-.67-1.5-1.5-1.5S10 2.67 10 3.5V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z"/>
  </svg>`;
  return L.divIcon({ html: svg, className: '', iconSize: [28, 28], iconAnchor: [14, 14] });
}

// Separate inner component so we can use useMap inside MapContainer
function MapInner({ flights, selectedFlight, onSelectFlight }: {
  flights: Flight[];
  selectedFlight: Flight | null;
  onSelectFlight: (f: Flight) => void;
}) {
  return (
    <>
      {flights.map((flight) => (
        <Marker
          key={flight.icao24}
          position={[flight.latitude, flight.longitude]}
          icon={createPlaneIcon(flight.heading, selectedFlight?.icao24 === flight.icao24)}
          eventHandlers={{ click: () => onSelectFlight(flight) }}
        >
          <Popup>
            <div>
              <strong>{flight.callsign}</strong><br />
              {flight.originCountry}<br />
              Alt: {Math.round(flight.altitude)} m &nbsp;|&nbsp;
              {Math.round(flight.velocity * 3.6)} km/h
            </div>
          </Popup>
        </Marker>
      ))}
    </>
  );
}

export const RadarMap: React.FC<RadarMapProps> = ({
  flights,
  selectedFlight,
  searchTerm,
  mapStyle,
  onSearchChange,
  onSelectFlight,
}) => {
  const mapRef = useRef<L.Map | null>(null);

  // Pan to selected flight without affecting the user's zoom level
  useEffect(() => {
    if (selectedFlight && mapRef.current) {
      mapRef.current.panTo([selectedFlight.latitude, selectedFlight.longitude]);
    }
  }, [selectedFlight?.icao24]); // only when selection changes

  const tileUrl = mapStyle === 'satellite'
    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

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

      <MapContainer
        center={[52.0, 15.0]}
        zoom={5}
        scrollWheelZoom={true}
        ref={mapRef}
        style={{ height: '100%', width: '100%' }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url={tileUrl}
        />
        <MapInner
          flights={flights}
          selectedFlight={selectedFlight}
          onSelectFlight={onSelectFlight}
        />
      </MapContainer>
    </div>
  );
};
