//! Notification commands for price alerts

use tauri::AppHandle;

use crate::services::TauriNotificationService;
use crate::traits::NotificationService;
use crate::types::PriceAlert;

/// Show a local notification for a price alert
#[tauri::command]
pub async fn show_price_alert_notification(
    app: AppHandle,
    route: String,
    old_price: f64,
    new_price: f64,
) -> Result<(), String> {
    let service = TauriNotificationService::new(app);
    service
        .send_price_alert(&route, old_price, new_price)
        .map_err(|e| e.to_string())
}

/// Check for new alerts and show notifications
/// Called when the app opens or resumes
#[tauri::command]
pub async fn check_and_notify_alerts(
    app: AppHandle,
    alerts: Vec<PriceAlert>,
) -> Result<u32, String> {
    let service = TauriNotificationService::new(app);
    service
        .send_batch_alerts(&alerts)
        .map_err(|e| e.to_string())
}
