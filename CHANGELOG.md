# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-12-27

### Added
- **Mobile:** Created `composables/` directory with reusable Vue composables:
  - `useFlightSearch` - Flight search state and business logic
  - `useNetworkStatus` - Online/offline connectivity tracking
  - `useDatabase` - SQLite database initialization
  - `useNavigation` - Tab navigation with offline-aware switching
- **Mobile:** Created `views/` directory with dedicated view components:
  - `SearchView` - Search tab content (form + results)
  - `SavedView` - Saved flights tab content
- **Mobile:** Created `utils/` directory with utility functions:
  - `dates.ts` - Date utility functions for default flight dates
- **Docs:** Added screenshots for README.md (web and mobile apps)

### Changed
- **Mobile:** Refactored `App.vue` from ~195 lines to ~38 lines
  - Extracted all business logic into composables
  - Extracted view content into dedicated view components
  - Improved code organization and separation of concerns
  - Added JSDoc documentation to all new files

## [0.1.0] - 2025-12-25

### Added
- **Mobile:** Implemented Favorites feature using SQLite for local storage.
  - Added `SavedFlights` component.
  - Created `db.ts` service for database operations.
  - Integrated `sqlite` plugin in Tauri.
- **Web:** Added flight segment breakdown in `FlightSearchLive` results card.
  - Shows departure/arrival airports, times, airline, and duration for each leg.
  - Displays "Layover" indicators between segments.

### Changed
- **Backend:** Removed `Amadeus` flight provider completely to rely solely on `SerpApi`.
  - Updated `config.exs` and `runtime.exs` to remove Amadeus keys.
  - Updated `ResilientProvider` to use `SerpApi` as the single source of truth.
  - Cleaned up `FlightController` and frontend assets (`FlightSearch.vue`) to remove Amadeus references.

### Fixed
- **Mobile:** Fixed flight segment rendering in `FlightResult.vue`.
  - App now correctly behaves when segments are available/unavailable.
  - Added "Details unavailable" fallback state.
- **Web:** Fixed LiveView session warning (`csrf_token`) in `root.html.heex` by explicitly calling `Plug.CSRFProtection.get_csrf_token()`.
- **Infrastructure:** Resolved `all_providers_failed` error by identifying missing `SERPAPI_API_KEY` in server environment.
