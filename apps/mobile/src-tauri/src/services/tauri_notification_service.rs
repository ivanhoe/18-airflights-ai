//! Tauri-based notification service implementation
//!
//! Uses Tauri's notification plugin to send OS-level notifications

use tauri::AppHandle;
use tauri_plugin_notification::NotificationExt;

use crate::errors::{AppError, AppResult};
use crate::traits::NotificationService;
use crate::types::PriceAlert;

/// Notification service using Tauri's notification plugin
pub struct TauriNotificationService {
    app: AppHandle,
}

impl TauriNotificationService {
    /// Create a new Tauri notification service
    pub fn new(app: AppHandle) -> Self {
        Self { app }
    }
}

impl NotificationService for TauriNotificationService {
    fn send_price_alert(&self, route: &str, old_price: f64, new_price: f64) -> AppResult<()> {
        let message = format!(
            "{} dropped from ${:.0} to ${:.0}!",
            route, old_price, new_price
        );

        self.app
            .notification()
            .builder()
            .title("🔔 Price Alert")
            .body(&message)
            .show()
            .map_err(|e| AppError::Notification(e.to_string()))?;

        Ok(())
    }

    fn send_batch_alerts(&self, alerts: &[PriceAlert]) -> AppResult<u32> {
        let mut notified = 0;

        for alert in alerts {
            let message = format!("{} dropped to ${:.0}!", alert.route, alert.new_price);

            if self
                .app
                .notification()
                .builder()
                .title("🔔 Price Alert")
                .body(&message)
                .show()
                .is_ok()
            {
                notified += 1;
            }
        }

        Ok(notified)
    }
}
