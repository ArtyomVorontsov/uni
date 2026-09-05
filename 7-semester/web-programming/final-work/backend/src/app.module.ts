import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { FlightController } from './flight.controller';
import { FlightService } from './flight.service';
import { FlightEntity, WatchlistEntity } from './entities/flight.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    HttpModule.register({
      timeout: 5000,
      maxRedirects: 5,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get<string>('DB_USERNAME', 'postgres'),
        password: configService.get<string>('DB_PASSWORD', 'postgres'),
        database: configService.get<string>('DB_DATABASE', 'skytracker'),
        entities: [FlightEntity, WatchlistEntity],
        synchronize: true, // Auto sync schema for development convenience
      }),
    }),
    TypeOrmModule.forFeature([FlightEntity, WatchlistEntity]),
  ],
  controllers: [FlightController],
  providers: [FlightService],
})
export class AppModule {}
