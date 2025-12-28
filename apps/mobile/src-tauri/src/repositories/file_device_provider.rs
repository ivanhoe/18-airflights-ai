//! File-based device provider implementation
//!
//! Stores device ID in a local file in the app's config directory

use std::fs;
use std::path::PathBuf;

use crate::errors::AppResult;
use crate::traits::DeviceProvider;
use crate::utils::rand_string;

/// Device provider that stores the ID in a local file
pub struct FileDeviceProvider {
    config_dir: PathBuf,
}

impl FileDeviceProvider {
    /// Create a new file-based device provider
    pub fn new() -> Self {
        let config_dir = dirs::config_dir()
            .unwrap_or_else(|| PathBuf::from("."))
            .join("flight-tracker");
        
        Self { config_dir }
    }

    /// Get the path to the device ID file
    fn device_file_path(&self) -> PathBuf {
        self.config_dir.join("device_id")
    }

    /// Generate a new unique device ID
    fn generate_device_id(&self) -> String {
        format!(
            "device_{}_{}",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_millis(),
            rand_string(8)
        )
    }
}

impl Default for FileDeviceProvider {
    fn default() -> Self {
        Self::new()
    }
}

impl DeviceProvider for FileDeviceProvider {
    fn get_device_id(&self) -> AppResult<String> {
        // Ensure config directory exists
        fs::create_dir_all(&self.config_dir)?;
        
        let device_file = self.device_file_path();

        // Return existing ID if available
        if let Ok(id) = fs::read_to_string(&device_file) {
            if !id.trim().is_empty() {
                return Ok(id.trim().to_string());
            }
        }

        // Generate and store new ID
        let new_id = self.generate_device_id();
        fs::write(&device_file, &new_id)?;
        
        Ok(new_id)
    }

    fn reset_device_id(&self) -> AppResult<String> {
        fs::create_dir_all(&self.config_dir)?;
        
        let new_id = self.generate_device_id();
        fs::write(self.device_file_path(), &new_id)?;
        
        Ok(new_id)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_device_id_generation() {
        let provider = FileDeviceProvider::new();
        let id = provider.generate_device_id();
        
        assert!(id.starts_with("device_"));
        assert!(id.len() > 20);
    }
}
