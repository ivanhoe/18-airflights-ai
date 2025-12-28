# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-12-28

### Added
- **Mobile:** New composables for centralized logic:
  - `useFormatters` - formatPrice, formatDate, formatTime, formatDuration, formatTimeAgo
  - `useLocale` - Language switching (es/en) with flagEmoji, toggleLanguage
  - `usePriceWatcher` - Price watcher API calls and state management

- **Mobile:** New constants:
  - `constants/airports.ts` - Single source of truth for airport data

- **Mobile:** New sub-components for better code organization:
  - `inputs/` - AirportSelect, DateInput
  - `display/` - PriceDisplay
  - `flight/` - FlightPriceHeader, FlightSegment, FlightSimpleView
  - `watcher/` - WatcherHeader, WatcherPriceStatus, WatcherActions
  - `search/` - TripOptionsChips, RouteCard, DateCard

- **Mobile:** Price Watcher feature:
  - `WatchersView` - Main view for managing price watchers
  - `WatcherForm` - Form to create new watchers
  - `WatcherCard` - Display watcher with price status
  - `PriceHistoryModal` - Show price history as bottom sheet

- **Mobile:** Global CSS component classes in `index.css`:
  - input-card, input-row, input-divider
  - chip, chip-select, chip-icon
  - select-wrapper, select-input
  - modal-backdrop, modal-sheet, modal-handle
  - price-input-wrapper, offline-banner

### Changed
- **Mobile:** Major component refactoring:
  - FlightResult: 137 → 60 lines (split into 3 sub-components)
  - WatcherCard: 138 → 71 lines (split into 3 sub-components)
  - SearchForm: 310 → 81 lines (split into 3 sub-components)
  - AppHeader: Now uses useLocale composable

- **Mobile:** Migrated ~350 lines of scoped CSS to global Tailwind classes

- **Mobile:** Reorganized component folders:
  - `ui/` split into `inputs/` and `display/`

### Removed
- **Mobile:** Saved Flights feature completely removed:
  - Deleted SavedView, SavedFlights components
  - Removed saved flights logic from useFlightSearch, db.ts
  - Updated navigation from 3 tabs to 2 tabs (Search, Alerts)

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
