//! Type definitions for the Flight Tracker app

use serde::{Deserialize, Serialize};

/// Price alert received from the server
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PriceAlert {
    pub id: String,
    pub route: String,
    pub old_price: f64,
    pub new_price: f64,
    pub triggered_at: String,
}
