//! Device provider trait - defines contract for device identification

use crate::errors::AppResult;

/// Provider for device identification
///
/// Abstracts how device IDs are generated and stored
pub trait DeviceProvider: Send + Sync {
    /// Get the unique device identifier
    /// Creates one if it doesn't exist
    fn get_device_id(&self) -> AppResult<String>;

    /// Reset the device ID (for testing or user request)
    fn reset_device_id(&self) -> AppResult<String>;
}
