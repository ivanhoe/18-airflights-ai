//! Notification service trait - defines contract for sending notifications

use crate::errors::AppResult;
use crate::types::PriceAlert;

/// Service for sending notifications
///
/// Abstracts the notification mechanism, allowing for different implementations
/// (OS notifications, push notifications, mock for testing, etc.)
pub trait NotificationService: Send + Sync {
    /// Send a price alert notification
    fn send_price_alert(&self, route: &str, old_price: f64, new_price: f64) -> AppResult<()>;

    /// Send multiple price alert notifications
    fn send_batch_alerts(&self, alerts: &[PriceAlert]) -> AppResult<u32>;
}
