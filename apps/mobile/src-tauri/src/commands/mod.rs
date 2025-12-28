//! Tauri commands for Vue frontend integration
//!
//! This module re-exports all commands for easy registration in lib.rs

mod device;
mod notifications;

// Re-export command functions
pub use device::{get_device_id, reset_device_id};
pub use notifications::{check_and_notify_alerts, show_price_alert_notification};

/// Simple greeting command (kept for compatibility/testing)
#[tauri::command]
pub fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

// Re-export the hidden Tauri command symbols for generate_handler! macro
pub use device::{__cmd__get_device_id, __cmd__reset_device_id};
pub use notifications::{__cmd__check_and_notify_alerts, __cmd__show_price_alert_notification};
