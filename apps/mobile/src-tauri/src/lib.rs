//! Flight Tracker - Tauri Backend
//! 
//! This module provides:
//! - SQLite database for saved flights (offline cache)
//! - Tauri commands for Vue frontend integration
//! - Local notifications when alerts are detected
//! 
//! Note: Price monitoring runs on the Elixir server (GenServer).
//! This Rust backend handles local storage and notifications.

use serde::{Deserialize, Serialize};
use tauri::AppHandle;
use tauri_plugin_notification::NotificationExt;
use tauri_plugin_sql::{Migration, MigrationKind};

// ============================================================================
// TYPES
// ============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PriceAlert {
    pub id: String,
    pub route: String,
    pub old_price: f64,
    pub new_price: f64,
    pub triggered_at: String,
}

// ============================================================================
// TAURI COMMANDS
// ============================================================================

/// Greeting command (kept for compatibility/testing)
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

/// Show a local notification for a price alert
#[tauri::command]
async fn show_price_alert_notification(
    app: AppHandle,
    route: String,
    old_price: f64,
    new_price: f64,
) -> Result<(), String> {
    let message = format!(
        "¡{} bajó de ${:.0} a ${:.0}!",
        route, old_price, new_price
    );
    
    app.notification()
        .builder()
        .title("🔔 Alerta de Precio")
        .body(&message)
        .show()
        .map_err(|e| e.to_string())?;
    
    Ok(())
}

/// Check for new alerts and show notifications
/// Called when the app opens or resumes
#[tauri::command]
async fn check_and_notify_alerts(
    app: AppHandle,
    alerts: Vec<PriceAlert>,
) -> Result<u32, String> {
    let mut notified = 0;
    
    for alert in alerts {
        let message = format!(
            "¡{} bajó a ${:.0}!",
            alert.route, alert.new_price
        );
        
        if let Ok(_) = app.notification()
            .builder()
            .title("🔔 Alerta de Precio")
            .body(&message)
            .show()
        {
            notified += 1;
        }
    }
    
    Ok(notified)
}

/// Get device identifier for API calls
#[tauri::command]
fn get_device_id() -> String {
    // In a production app, you'd use a proper device identifier
    // For now, we generate a random one and store it
    use std::fs;
    use std::path::PathBuf;
    
    let config_dir = dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("flight-tracker");
    
    let _ = fs::create_dir_all(&config_dir);
    let device_file = config_dir.join("device_id");
    
    if let Ok(id) = fs::read_to_string(&device_file) {
        return id;
    }
    
    // Generate new device ID
    let new_id = format!(
        "device_{}_{}", 
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis(),
        rand_string(8)
    );
    
    let _ = fs::write(&device_file, &new_id);
    new_id
}

fn rand_string(len: usize) -> String {
    use std::collections::hash_map::RandomState;
    use std::hash::{BuildHasher, Hasher};
    
    let s = RandomState::new();
    let mut result = String::with_capacity(len);
    let chars: Vec<char> = "abcdefghijklmnopqrstuvwxyz0123456789".chars().collect();
    
    for _ in 0..len {
        let mut hasher = s.build_hasher();
        hasher.write_usize(result.len());
        let idx = hasher.finish() as usize % chars.len();
        result.push(chars[idx]);
    }
    
    result
}

// ============================================================================
// APP ENTRY POINT
// ============================================================================

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    // Define database migrations for local storage
    let migrations = vec![
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
    ];

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_notification::init())
        .plugin(
            tauri_plugin_sql::Builder::default()
                .add_migrations("sqlite:flights.db", migrations)
                .build(),
        )
        .invoke_handler(tauri::generate_handler![
            greet,
            show_price_alert_notification,
            check_and_notify_alerts,
            get_device_id
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
