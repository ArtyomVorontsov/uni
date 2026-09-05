import React from 'react';
import { Plane, Layers, Filter, RefreshCw } from 'lucide-react';
import { FlightStats } from '../types/flight';

interface HeaderProps {
  stats: FlightStats | null;
  mapStyle: 'dark' | 'satellite';
  filterAirborneOnly: boolean;
  isLoading: boolean;
  onToggleMapStyle: () => void;
  onToggleAirborneFilter: () => void;
  onRefresh: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  stats,
  mapStyle,
  filterAirborneOnly,
  isLoading,
  onToggleMapStyle,
  onToggleAirborneFilter,
  onRefresh,
}) => {
  return (
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
          onClick={onToggleMapStyle}
        >
          <Layers size={16} /> {mapStyle === 'dark' ? 'Satellite' : 'Vector Dark'}
        </button>
        <button
          className={`btn-toggle ${filterAirborneOnly ? 'active' : ''}`}
          onClick={onToggleAirborneFilter}
        >
          <Filter size={16} /> Airborne Only
        </button>
        <button className="btn-toggle" onClick={onRefresh} disabled={isLoading}>
          <RefreshCw size={16} className={isLoading ? 'spin' : ''} /> Refresh
        </button>
      </div>
    </header>
  );
};
