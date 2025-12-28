// Database service for SQLite offline storage
import Database from '@tauri-apps/plugin-sql'

let db: Database | null = null

/**
 * Initialize the database connection.
 * Must be called before any other database operations.
 */
export async function initDatabase(): Promise<void> {
    if (db) return

    try {
        db = await Database.load('sqlite:flights.db')
        console.log('[DB] Database initialized successfully')
    } catch (error) {
        console.error('[DB] Failed to initialize database:', error)
        throw error
    }
}

/**
 * Check if database is available (for offline detection).
 */
export function isDatabaseReady(): boolean {
    return db !== null
}
