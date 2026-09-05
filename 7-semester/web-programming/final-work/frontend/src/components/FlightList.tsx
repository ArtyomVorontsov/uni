import React from 'react';
import { Eye } from 'lucide-react';
import { Flight } from '../types/flight';

interface FlightListProps {
  flights: Flight[];
  selectedFlight: Flight | null;
  onSelectFlight: (flight: Flight) => void;
}

export const FlightList: React.FC<FlightListProps> = ({
  flights,
  selectedFlight,
  onSelectFlight,
}) => {
  return (
    <div className="panel-card" style={{ flex: 1 }}>
      <h2 className="panel-title">
        <span>
          <Eye size={18} /> Detected Airspace ({flights.length})
        </span>
      </h2>

      <div className="flight-list">
        {flights.map((flight) => (
          <div
            key={flight.icao24}
            className={`flight-item ${
              selectedFlight?.icao24 === flight.icao24 ? 'selected' : ''
            }`}
            onClick={() => onSelectFlight(flight)}
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
  );
};
