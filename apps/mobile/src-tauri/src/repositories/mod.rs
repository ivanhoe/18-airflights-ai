//! Repository implementations

mod file_device_provider;

pub use file_device_provider::FileDeviceProvider;

// Note: SQLite repository would go here, but Tauri SQL plugin handles it
// For a full implementation, we'd create SqliteAlertRepository
