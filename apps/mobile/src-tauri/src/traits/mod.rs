//! Trait definitions (interfaces) for the Flight Tracker app
//!
//! These traits define contracts that implementations must fulfill,
//! enabling dependency injection and testability.

mod device_provider;
mod notification_service;

pub use device_provider::DeviceProvider;
pub use notification_service::NotificationService;

// Note: AlertRepository is defined but not yet implemented
// Uncomment when SQLite repository is added:
// mod alert_repository;
// pub use alert_repository::AlertRepository;
