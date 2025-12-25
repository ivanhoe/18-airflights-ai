# Flight Tracker ✈️

A monorepo with Phoenix LiveView web app and Tauri mobile app for tracking flights.

## Project Structure

```
apps/
├── web/      # Phoenix + LiveVue (Elixir backend)
└── mobile/   # Tauri + Vue (Desktop/iOS/Android)
```

## Quick Start

### Web App (Phoenix)
```bash
cd apps/web
mix deps.get
cd assets && npm install && cd ..
mix phx.server
```
→ Open http://localhost:4000

### Mobile/Desktop App (Tauri)
```bash
cd apps/mobile
npm install
npm run tauri dev          # Desktop
npm run tauri ios dev      # iOS
npm run tauri android dev  # Android
```

## Architecture

- **Hexagonal Architecture** with ports/adapters pattern
- **REST API** at `/api/flights/*` for mobile consumption
- **Amadeus API** integration for real flight data
- **Dependency Injection** for testable, swappable components

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed documentation.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Web Backend | Phoenix 1.8 + LiveVue |
| Mobile | Tauri 2.0 + Vue 3 |
| Language | Elixir, TypeScript, Rust |
| Styling | Tailwind CSS |
| API | Amadeus |

## Environment Variables

```bash
# Required for Amadeus API
AMADEUS_API_KEY=your_key
AMADEUS_API_SECRET=your_secret
```

## License

MIT
