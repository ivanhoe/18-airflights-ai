// Database service for SQLite offline storage
import Database from '@tauri-apps/plugin-sql'
import type { FlightOffer } from './api'

let db: Database | null = null

export interface SavedFlight {
    id: number
    origin: string
    destination: string
    travel_date: string
    price: number
    currency: string
    airline: string | null
    airline_code: string | null
    duration: string | null
    stops: number
    segments: string | null
    is_favorite: boolean
    searched_at: string
}

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
 * Save a flight result to the database.
 */
export async function saveFlightResult(
    origin: string,
    destination: string,
    travelDate: string,
    offer: FlightOffer
): Promise<number> {
    if (!db) await initDatabase()

    const result = await db!.execute(
        `INSERT INTO saved_flights (
      origin, destination, travel_date, price, currency,
      airline, airline_code, duration, stops, segments
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            origin,
            destination,
            travelDate,
            offer.price,
            offer.currency,
            offer.airline,
            offer.airline_code,
            offer.duration,
            offer.stops,
            JSON.stringify(offer.segments || [])
        ]
    )

    console.log('[DB] Saved flight result, id:', result.lastInsertId)
    return result.lastInsertId as number
}

/**
 * Get all saved flights, ordered by most recent first.
 */
export async function getSavedFlights(): Promise<SavedFlight[]> {
    if (!db) await initDatabase()

    const results = await db!.select<SavedFlight[]>(
        `SELECT * FROM saved_flights ORDER BY searched_at DESC LIMIT 50`
    )

    return results.map(row => ({
        ...row,
        is_favorite: Boolean(row.is_favorite)
    }))
}

/**
 * Get only favorite flights.
 */
export async function getFavorites(): Promise<SavedFlight[]> {
    if (!db) await initDatabase()

    const results = await db!.select<SavedFlight[]>(
        `SELECT * FROM saved_flights WHERE is_favorite = 1 ORDER BY searched_at DESC`
    )

    return results.map(row => ({
        ...row,
        is_favorite: true
    }))
}

/**
 * Toggle favorite status for a flight.
 */
export async function toggleFavorite(id: number): Promise<boolean> {
    if (!db) await initDatabase()

    // Get current status
    const [flight] = await db!.select<SavedFlight[]>(
        `SELECT is_favorite FROM saved_flights WHERE id = ?`,
        [id]
    )

    if (!flight) return false

    const newStatus = flight.is_favorite ? 0 : 1
    await db!.execute(
        `UPDATE saved_flights SET is_favorite = ? WHERE id = ?`,
        [newStatus, id]
    )

    console.log('[DB] Toggled favorite for id:', id, 'to:', Boolean(newStatus))
    return Boolean(newStatus)
}

/**
 * Delete a saved flight.
 */
export async function deleteSavedFlight(id: number): Promise<void> {
    if (!db) await initDatabase()

    await db!.execute(`DELETE FROM saved_flights WHERE id = ?`, [id])
    console.log('[DB] Deleted flight id:', id)
}

/**
 * Delete old flights (older than specified days), keeping favorites.
 */
export async function cleanupOldFlights(daysOld: number = 30): Promise<number> {
    if (!db) await initDatabase()

    const result = await db!.execute(
        `DELETE FROM saved_flights 
     WHERE is_favorite = 0 
     AND datetime(searched_at) < datetime('now', '-' || ? || ' days')`,
        [daysOld]
    )

    console.log('[DB] Cleaned up', result.rowsAffected, 'old flights')
    return result.rowsAffected as number
}

/**
 * Check if database is available (for offline detection).
 */
export function isDatabaseReady(): boolean {
    return db !== null
}
