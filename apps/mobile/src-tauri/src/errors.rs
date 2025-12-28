//! Error types for the Flight Tracker app

use std::fmt;

/// Application error type
#[derive(Debug)]
pub enum AppError {
    /// Database operation failed
    Database(String),
    /// Notification failed to send
    Notification(String),
    /// IO operation failed
    Io(std::io::Error),
    /// Configuration error
    Config(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::Database(msg) => write!(f, "Database error: {}", msg),
            AppError::Notification(msg) => write!(f, "Notification error: {}", msg),
            AppError::Io(err) => write!(f, "IO error: {}", err),
            AppError::Config(msg) => write!(f, "Config error: {}", msg),
        }
    }
}

impl std::error::Error for AppError {}

impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        AppError::Io(err)
    }
}

/// Result type alias for the app
pub type AppResult<T> = Result<T, AppError>;
