//! Utility functions for the Flight Tracker app

use std::collections::hash_map::RandomState;
use std::hash::{BuildHasher, Hasher};

/// Generate a random alphanumeric string of given length
pub fn rand_string(len: usize) -> String {
    let s = RandomState::new();
    let mut result = String::with_capacity(len);
    let chars: Vec<char> = "abcdefghijklmnopqrstuvwxyz0123456789".chars().collect();
    
    for i in 0..len {
        let mut hasher = s.build_hasher();
        hasher.write_usize(i);
        hasher.write_usize(result.len());
        let idx = hasher.finish() as usize % chars.len();
        result.push(chars[idx]);
    }
    
    result
}
