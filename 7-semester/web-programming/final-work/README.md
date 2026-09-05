# SkyTracker - Real-Time Flight Radar & Telemetry System

A dynamic full-stack web application built for the **Web Application Construction Course** (TSI). 
SkyTracker tracks live commercial and regional aircraft in real time utilizing open aviation telemetry APIs, PostgreSQL persistence, NestJS REST backend, and a modern React glassmorphism frontend with Leaflet mapping.

---

## 🌟 Key Features & Requirements Met

1. **Framework & Architecture**:
   - **Backend**: NestJS (TypeScript, Node.js) with modular controllers, services, entities, and Swagger OpenAPI docs.
   - **Frontend**: React (TypeScript) with modern functional components and hooks.
   - **Database**: PostgreSQL with TypeORM ORM schema mapping and migration synchronizer.

2. **Open Aviation API Integration**:
   - Real-time connection to **OpenSky Network REST API** for live aircraft state vectors (latitude, longitude, altitude, velocity, heading, origin country).

3. **5+ Dynamic Elements**:
   - **Dynamic Element 1**: Live updating flight radar map with directional aircraft markers rotated according to live heading.
   - **Dynamic Element 2**: Real-time Telemetry Inspector panel displaying detailed airspeed, altitude, vertical rate, and flight status.
   - **Dynamic Element 3**: Airspace Telemetry Aggregator dashboard computing live average speed, active aircraft count, and peak altitude.
   - **Dynamic Element 4**: Interactive search and airspace filter (airborne-only filter & multi-attribute text search).
   - **Dynamic Element 5**: Interactive Pinned Watchlist & Favorites manager persisted in database.

4. **Advanced Stylesheet Techniques & Preprocessors**:
   - Written in **SASS (`.scss`)** using nested rules, custom variables (`$primary-color`, `$accent-color`), glassmorphism mixins (`@mixin glass-panel`), dynamic animations, and responsive flex/grid layouts.

5. **Deployment & Hosting Readiness**:
   - Production Dockerized via `docker-compose.yml`, multi-stage Dockerfiles for backend and Nginx frontend.

---

## 🚀 How to Run Locally

### Option A: Local Development (Node.js & NPM)

1. **Backend Setup**:
   ```bash
   cd backend
   npm install
   # (Optional) Set DB credentials in .env or run with defaults
   npm run start:dev
   ```
   - API Endpoint: `http://localhost:3001/api/flights/live`
   - Swagger OpenAPI Docs: `http://localhost:3001/api/docs`

2. **Frontend Setup**:
   ```bash
   cd frontend
   npm install
   npm start
   ```
   - Access web app at `http://localhost:3000`

### Option B: One-Click Docker Containerization

```bash
docker-compose up --build -d
```
This automatically boots:
- PostgreSQL database container on port `5432`
- NestJS backend service on port `3001`
- React static production Nginx server on port `3000`

---

## 📁 Repository Structure

```
.
├── backend/                # NestJS API Server
│   ├── src/
│   │   ├── entities/       # TypeORM PostgreSQL entities
│   │   ├── app.module.ts   # NestJS App Module & DB config
│   │   ├── flight.controller.ts # REST API Controller
│   │   ├── flight.service.ts    # OpenSky API & Telemetry Logic
│   │   └── main.ts         # Bootstrap entrypoint & Swagger setup
│   ├── Dockerfile
│   └── package.json
├── frontend/               # React Dashboard App
│   ├── src/
│   │   ├── App.tsx         # Main React Radar Application & Dynamic UI
│   │   ├── App.scss        # SASS Stylesheet & Glassmorphism design
│   │   └── index.tsx
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml      # Orchestration config
└── README.md
```
