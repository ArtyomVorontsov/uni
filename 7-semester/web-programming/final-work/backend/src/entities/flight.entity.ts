import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('flights')
export class FlightEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  icao24: string;

  @Column({ nullable: true })
  callsign: string;

  @Column({ nullable: true })
  originCountry: string;

  @Column('double precision', { nullable: true })
  longitude: number;

  @Column('double precision', { nullable: true })
  latitude: number;

  @Column('double precision', { nullable: true })
  altitude: number;

  @Column('double precision', { nullable: true })
  velocity: number;

  @Column('double precision', { nullable: true })
  heading: number;

  @Column('double precision', { nullable: true })
  verticalRate: number;

  @Column({ default: false })
  onGround: boolean;

  @Column({ nullable: true })
  lastContact: number;

  @CreateDateColumn()
  updatedAt: Date;
}

@Entity('watchlists')
export class WatchlistEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  icao24: string;

  @Column({ nullable: true })
  callsign: string;

  @Column({ nullable: true })
  notes: string;

  @Column({ default: 'HIGH' })
  alertPriority: string;

  @CreateDateColumn()
  createdAt: Date;
}
