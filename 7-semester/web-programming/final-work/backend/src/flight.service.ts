import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FlightEntity, WatchlistEntity } from './entities/flight.entity';
import { firstValueFrom } from 'rxjs';

export interface FlightDto {
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
  lastContact: number;
  isBookmarked?: boolean;
}

@Injectable()
export class FlightService {
  private readonly logger = new Logger(FlightService.name);

  // 30 stable simulated flights spread around Europe with realistic headings
  private simPool: FlightDto[] = [
    { icao24: 'sim00', callsign: 'BT651',  originCountry: 'Latvia',      latitude: 56.95, longitude: 24.10, altitude: 10668, velocity: 235, heading: 145, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim01', callsign: 'LH1425', originCountry: 'Germany',     latitude: 52.50, longitude: 13.40, altitude:  9400, velocity: 210, heading: 220, verticalRate: -3.5, onGround: false, lastContact: 0 },
    { icao24: 'sim02', callsign: 'AF1102', originCountry: 'France',      latitude: 48.85, longitude:  2.35, altitude: 11200, velocity: 245, heading:  85, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim03', callsign: 'BA882',  originCountry: 'UK',          latitude: 51.50, longitude: -0.12, altitude:  8200, velocity: 195, heading: 310, verticalRate: -5.2, onGround: false, lastContact: 0 },
    { icao24: 'sim04', callsign: 'AY1013', originCountry: 'Finland',     latitude: 60.17, longitude: 24.93, altitude: 10100, velocity: 220, heading: 190, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim05', callsign: 'WZZ402', originCountry: 'Hungary',     latitude: 47.50, longitude: 19.04, altitude: 11800, velocity: 250, heading:  45, verticalRate: 1.2,  onGround: false, lastContact: 0 },
    { icao24: 'sim06', callsign: 'RYR284', originCountry: 'Ireland',     latitude: 53.33, longitude: -6.25, altitude:  9900, velocity: 228, heading: 130, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim07', callsign: 'SAS741', originCountry: 'Sweden',      latitude: 59.33, longitude: 18.06, altitude: 10800, velocity: 240, heading: 270, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim08', callsign: 'EZY123', originCountry: 'UK',          latitude: 50.10, longitude:   1.85, altitude:  9200, velocity: 218, heading: 100, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim09', callsign: 'TK789',  originCountry: 'Turkey',      latitude: 41.01, longitude: 28.97, altitude: 12100, velocity: 260, heading: 315, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim10', callsign: 'KL234',  originCountry: 'Netherlands', latitude: 52.37, longitude:  4.89, altitude: 10500, velocity: 230, heading:  60, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim11', callsign: 'IB567',  originCountry: 'Spain',       latitude: 40.42, longitude: -3.70, altitude: 11000, velocity: 242, heading: 350, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim12', callsign: 'FR890',  originCountry: 'Ireland',     latitude: 45.75, longitude:  4.85, altitude:  8700, velocity: 205, heading: 200, verticalRate: -2,   onGround: false, lastContact: 0 },
    { icao24: 'sim13', callsign: 'OS321',  originCountry: 'Austria',     latitude: 48.21, longitude: 16.37, altitude: 10200, velocity: 225, heading: 135, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim14', callsign: 'LX654',  originCountry: 'Switzerland', latitude: 47.37, longitude:  8.54, altitude: 11500, velocity: 248, heading:  20, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim15', callsign: 'SK987',  originCountry: 'Sweden',      latitude: 55.67, longitude: 12.56, altitude:  9800, velocity: 215, heading: 250, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim16', callsign: 'DY112',  originCountry: 'Norway',      latitude: 59.91, longitude: 10.75, altitude: 10900, velocity: 235, heading: 175, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim17', callsign: 'VY556',  originCountry: 'Spain',       latitude: 41.38, longitude:  2.17, altitude:  9500, velocity: 222, heading:  75, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim18', callsign: 'TAP132', originCountry: 'Portugal',    latitude: 38.72, longitude: -9.14, altitude: 11300, velocity: 252, heading:  30, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim19', callsign: 'DLH777', originCountry: 'Germany',     latitude: 53.63, longitude:  9.99, altitude: 10400, velocity: 238, heading: 160, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim20', callsign: 'AAL888', originCountry: 'USA',         latitude: 55.00, longitude: -20.00, altitude: 12000, velocity: 270, heading:  90, verticalRate: 0,   onGround: false, lastContact: 0 },
    { icao24: 'sim21', callsign: 'UAE444', originCountry: 'UAE',         latitude: 43.00, longitude: 35.00, altitude: 12500, velocity: 265, heading: 280, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim22', callsign: 'QTR555', originCountry: 'Qatar',       latitude: 38.00, longitude: 22.00, altitude: 11800, velocity: 255, heading: 320, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim23', callsign: 'CFG354', originCountry: 'Germany',     latitude: 49.00, longitude:  8.00, altitude:  9600, velocity: 208, heading: 280, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim24', callsign: 'NAX334', originCountry: 'Norway',      latitude: 63.00, longitude: 14.00, altitude: 10700, velocity: 232, heading: 185, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim25', callsign: 'FIN900', originCountry: 'Finland',     latitude: 65.00, longitude: 25.00, altitude:  8900, velocity: 200, heading: 270, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim26', callsign: 'SWR111', originCountry: 'Switzerland', latitude: 46.20, longitude:  6.15, altitude: 11100, velocity: 244, heading:  50, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim27', callsign: 'ETD333', originCountry: 'UAE',         latitude: 36.00, longitude: 30.00, altitude: 12200, velocity: 258, heading: 295, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim28', callsign: 'THY666', originCountry: 'Turkey',      latitude: 39.92, longitude: 32.85, altitude: 10300, velocity: 226, heading: 330, verticalRate: 0,    onGround: false, lastContact: 0 },
    { icao24: 'sim29', callsign: 'CRL021', originCountry: 'Belgium',     latitude: 50.85, longitude:  4.35, altitude:  9700, velocity: 212, heading: 120, verticalRate: 0,    onGround: false, lastContact: 0 },
  ];

  constructor(
    private readonly httpService: HttpService,
    @InjectRepository(FlightEntity)
    private flightRepository: Repository<FlightEntity>,
    @InjectRepository(WatchlistEntity)
    private watchlistRepository: Repository<WatchlistEntity>,
  ) {}

  async fetchLiveFlights(lamin = 40.0, lomin = -10.0, lamax = 70.0, lomax = 40.0): Promise<FlightDto[]> {
    try {
      const clientId = process.env.OPENSKY_CLIENT_ID || 'artjomsvoroncovs-api-client';
      const clientSecret = process.env.OPENSKY_CLIENT_SECRET || 'fpPvVAA8No5FnfVpFc5BuBZmcrTG0w0b';

      const response = await firstValueFrom(
        this.httpService.get(
          `https://opensky-network.org/api/states/all?lamin=${lamin}&lomin=${lomin}&lamax=${lamax}&lomax=${lomax}`,
          {
            timeout: 6000,
            headers: { 'User-Agent': 'SkyTracker/1.0' },
            auth: { username: clientId, password: clientSecret },
          }
        )
      );

      if (response.data?.states && Array.isArray(response.data.states)) {
        const live: FlightDto[] = response.data.states
          .filter((s: any) => s[5] != null && s[6] != null) // must have coordinates
          .slice(0, 50)
          .map((s: any) => ({
            icao24: s[0],
            callsign: (s[1] || 'N/A').trim(),
            originCountry: s[2] || 'Unknown',
            longitude: s[5],
            latitude: s[6],
            altitude: s[7] || 0,
            velocity: s[9] || 0,
            heading: s[10] || 0,
            verticalRate: s[11] || 0,
            onGround: s[8] || false,
            lastContact: s[4] || Math.floor(Date.now() / 1000),
          }));

        await this.syncToDatabase(live);
        return await this.attachWatchlistInfo(live);
      }
    } catch (err) {
      this.logger.warn(`OpenSky unavailable (${err.message}). Using simulation.`);
    }

    // Drift simulation pool and return all 30 planes
    this.driftSimPool();
    return await this.attachWatchlistInfo(this.simPool);
  }

  private driftSimPool(): void {
    this.simPool = this.simPool.map(f => {
      // Move plane along its heading by ~5 seconds of travel
      const distDeg = (f.velocity * 5) / 111320;
      const rad = (f.heading * Math.PI) / 180;
      let lat = f.latitude  + Math.cos(rad) * distDeg;
      let lon = f.longitude + Math.sin(rad) * distDeg;

      // Keep longitude in -180..180
      if (lon > 180) lon -= 360;
      if (lon < -180) lon += 360;
      // Bounce off poles
      if (lat > 80) { lat = 80; }
      if (lat < 30) { lat = 30; }

      return {
        ...f,
        latitude: lat,
        longitude: lon,
        heading: (f.heading + (Math.random() - 0.5) * 2 + 360) % 360,
        altitude: Math.max(1000, Math.min(14000, f.altitude + (Math.random() - 0.5) * 30)),
        lastContact: Math.floor(Date.now() / 1000),
      };
    });
  }

  async getWatchlist(): Promise<WatchlistEntity[]> {
    try { return await this.watchlistRepository.find(); } catch { return []; }
  }

  async addToWatchlist(dto: { icao24: string; callsign?: string; notes?: string; alertPriority?: string }): Promise<WatchlistEntity> {
    const existing = await this.watchlistRepository.findOne({ where: { icao24: dto.icao24 } });
    if (existing) return existing;
    return await this.watchlistRepository.save(this.watchlistRepository.create(dto));
  }

  async removeFromWatchlist(icao24: string): Promise<{ success: boolean }> {
    await this.watchlistRepository.delete({ icao24 });
    return { success: true };
  }

  async getFlightStats() {
    const flights = await this.fetchLiveFlights();
    const airborne = flights.filter(f => !f.onGround);
    return {
      totalFlights: flights.length,
      airborneCount: airborne.length,
      groundedCount: flights.length - airborne.length,
      averageSpeedKmh: Math.round(airborne.reduce((s, f) => s + f.velocity, 0) / (airborne.length || 1) * 3.6),
      highestAltitudeMeters: Math.round(Math.max(...flights.map(f => f.altitude), 0)),
      timestamp: new Date().toISOString(),
    };
  }

  private async attachWatchlistInfo(flights: FlightDto[]): Promise<FlightDto[]> {
    try {
      const wl = await this.watchlistRepository.find();
      const set = new Set(wl.map(w => w.icao24));
      return flights.map(f => ({ ...f, isBookmarked: set.has(f.icao24) }));
    } catch { return flights; }
  }

  private async syncToDatabase(flights: FlightDto[]) {
    try {
      for (const f of flights) {
        let e = await this.flightRepository.findOne({ where: { icao24: f.icao24 } });
        if (!e) e = this.flightRepository.create(f);
        else Object.assign(e, f);
        await this.flightRepository.save(e);
      }
    } catch { /* DB might not be ready */ }
  }
}
