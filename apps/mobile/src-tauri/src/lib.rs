//! Flight Tracker - Tauri Backend
//!
//! A well-structured Tauri application following clean architecture:
//!
//! - **traits/** - Interface definitions (contracts)
//! - **repositories/** - Data access implementations
//! - **services/** - Business logic implementations
//! - **commands/** - Tauri command handlers
//! - **types/** - Shared data structures
//! - **errors/** - Error handling
//! - **utils/** - Utility functions
//!
//! Note: Price monitoring runs on the Elixir server (GenServer).
//! This Rust backend handles local storage and notifications.

// Module declarations
mod commands;
mod errors;
mod repositories;
mod services;
mod traits;
mod types;
mod utils;

use tauri_plugin_sql::{Migration, MigrationKind};

// Public exports
pub use errors::{AppError, AppResult};
pub use types::PriceAlert;

/// Database migrations for local SQLite storage
fn get_migrations() -> Vec<Migration> {
    vec![
        Migration {
            version: 1,
            description: "create saved_flights table",
            sql: r#"
                CREATE TABLE IF NOT EXISTS saved_flights (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    origin TEXT NOT NULL,
                    destination TEXT NOT NULL,
                    travel_date TEXT NOT NULL,
                    price REAL NOT NULL,
                    currency TEXT NOT NULL DEFAULT 'USD',
                    airline TEXT,
                    airline_code TEXT,
                    duration TEXT,
                    stops INTEGER DEFAULT 0,
                    segments TEXT,
                    is_favorite INTEGER DEFAULT 0,
                    searched_at TEXT DEFAULT CURRENT_TIMESTAMP
                );
                CREATE INDEX IF NOT EXISTS idx_favorite ON saved_flights(is_favorite);
                CREATE INDEX IF NOT EXISTS idx_searched_at ON saved_flights(searched_at);
            "#,
            kind: MigrationKind::Up,
        },
        Migration {
            version: 2,
            description: "create local_alerts cache table",
            sql: r#"
                CREATE TABLE IF NOT EXISTS local_alerts (
                    id TEXT PRIMARY KEY,
                    watcher_id TEXT NOT NULL,
                    route TEXT NOT NULL,
                    old_price REAL NOT NULL,
                    new_price REAL NOT NULL,
                    is_read INTEGER DEFAULT 0,
                    triggered_at TEXT NOT NULL,
                    synced_at TEXT DEFAULT CURRENT_TIMESTAMP
                );
                CREATE INDEX IF NOT EXISTS idx_local_alerts_read ON local_alerts(is_read);
            "#,
            kind: MigrationKind::Up,
        },
    ]
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let migrations = get_migrations();

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_notification::init())
        .plugin(
            tauri_plugin_sql::Builder::default()
                .add_migrations("sqlite:flights.db", migrations)
                .build(),
        )
        .invoke_handler(tauri::generate_handler![
            commands::greet,
            commands::show_price_alert_notification,
            commands::check_and_notify_alerts,
            commands::get_device_id,
            commands::reset_device_id
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
