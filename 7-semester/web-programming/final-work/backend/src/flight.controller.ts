import { Controller, Get, Post, Delete, Body, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { FlightService, FlightDto } from './flight.service';

@ApiTags('flights')
@Controller('api/flights')
export class FlightController {
  constructor(private readonly flightService: FlightService) {}

  @Get('live')
  @ApiOperation({ summary: 'Get real-time tracked flights from OpenSky API / DB cache' })
  @ApiResponse({ status: 200, description: 'List of active aircraft state vectors' })
  async getLiveFlights(
    @Query('lamin') lamin?: string,
    @Query('lomin') lomin?: string,
    @Query('lamax') lamax?: string,
    @Query('lomax') lomax?: string,
  ): Promise<FlightDto[]> {
    return this.flightService.fetchLiveFlights(
      lamin ? parseFloat(lamin) : undefined,
      lomin ? parseFloat(lomin) : undefined,
      lamax ? parseFloat(lamax) : undefined,
      lomax ? parseFloat(lomax) : undefined,
    );
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get global flight metrics and airspace telemetry statistics' })
  async getStats() {
    return this.flightService.getFlightStats();
  }

  @Get('watchlist')
  @ApiOperation({ summary: 'Get user pinned watchlist aircraft' })
  async getWatchlist() {
    return this.flightService.getWatchlist();
  }

  @Post('watchlist')
  @ApiOperation({ summary: 'Add aircraft to tracking watchlist' })
  async addToWatchlist(@Body() body: { icao24: string; callsign?: string; notes?: string; alertPriority?: string }) {
    return this.flightService.addToWatchlist(body);
  }

  @Delete('watchlist/:icao24')
  @ApiOperation({ summary: 'Remove aircraft from tracking watchlist' })
  async removeFromWatchlist(@Param('icao24') icao24: string) {
    return this.flightService.removeFromWatchlist(icao24);
  }
}
