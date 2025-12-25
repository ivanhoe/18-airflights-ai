# Flight Tracker 🛫

A monorepo with Phoenix LiveView web app and Tauri mobile app for tracking flights.

## Project Structure

```
apps/
├── web/      # Phoenix + LiveVue (Elixir)
└── mobile/   # Tauri + Vue (Desktop/iOS/Android)
```

## Quick Start

### Web App
```bash
cd apps/web
mix deps.get
cd assets && npm install && cd ..
mix phx.server
```
Open http://localhost:4000

### Mobile/Desktop App
```bash
cd apps/mobile
npm install
npm run tauri dev          # Desktop
npm run tauri ios dev      # iOS
npm run tauri android dev  # Android
```

## Architecture

- **Hexagonal Architecture** for clean separation of concerns
- **REST API** at `/api/flights/*` for mobile consumption
- **Amadeus API** integration for flight data

## Tech Stack

| Layer | Technology |
|-------|------------|
| Web | Phoenix 1.8 + LiveVue |
| Mobile | Tauri 2.0 + Vue 3 |
| Backend | Elixir |
| Styling | Tailwind CSS |
| API | Amadeus |
