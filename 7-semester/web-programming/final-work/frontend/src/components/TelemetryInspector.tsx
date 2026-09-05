import React from 'react';
import { Radio, Bookmark } from 'lucide-react';
import { Flight } from '../types/flight';

interface TelemetryInspectorProps {
  selectedFlight: Flight | null;
  watchlist: string[];
  onToggleWatchlist: (flight: Flight) => void;
}

export const TelemetryInspector: React.FC<TelemetryInspectorProps> = ({
  selectedFlight,
  watchlist,
  onToggleWatchlist,
}) => {
  const isPinned = selectedFlight ? watchlist.includes(selectedFlight.icao24) : false;

  return (
    <div className="panel-card">
      <h2 className="panel-title">
        <span>
          <Radio size={18} /> Telemetry Inspector
        </span>
        {selectedFlight && (
          <button
            className="btn-toggle"
            style={{ padding: '4px 8px' }}
            onClick={() => onToggleWatchlist(selectedFlight)}
          >
            <Bookmark size={14} fill={isPinned ? '#0ea5e9' : 'none'} />
            {isPinned ? 'Pinned' : 'Pin'}
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
  );
};
