//! Device identification commands

use crate::repositories::FileDeviceProvider;
use crate::traits::DeviceProvider;

/// Get device identifier for API calls
/// Uses the FileDeviceProvider implementation
#[tauri::command]
pub fn get_device_id() -> Result<String, String> {
    let provider = FileDeviceProvider::new();
    provider.get_device_id().map_err(|e| e.to_string())
}

/// Reset device ID (for testing or debugging)
#[tauri::command]
pub fn reset_device_id() -> Result<String, String> {
    let provider = FileDeviceProvider::new();
    provider.reset_device_id().map_err(|e| e.to_string())
}
