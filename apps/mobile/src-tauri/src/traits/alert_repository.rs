//! Alert repository trait - defines contract for alert data access

use crate::errors::AppResult;
use crate::types::PriceAlert;

/// Repository for managing price alerts
///
/// This trait abstracts the data layer, allowing for different implementations
/// (SQLite, API, mock for testing, etc.)
pub trait AlertRepository: Send + Sync {
    /// Get all unread alerts
    fn get_unread_alerts(&self) -> AppResult<Vec<PriceAlert>>;

    /// Get all alerts (read and unread)
    fn get_all_alerts(&self) -> AppResult<Vec<PriceAlert>>;

    /// Mark an alert as read
    fn mark_as_read(&self, alert_id: &str) -> AppResult<()>;

    /// Mark all alerts as read
    fn mark_all_as_read(&self) -> AppResult<()>;

    /// Save a new alert locally
    fn save_alert(&self, alert: &PriceAlert) -> AppResult<()>;

    /// Delete an alert
    fn delete_alert(&self, alert_id: &str) -> AppResult<()>;

    /// Get count of unread alerts
    fn get_unread_count(&self) -> AppResult<usize>;
}
