/**
 * Date utility functions for flight search
 */

/**
 * Get default departure date (30 days from now)
 */
export function getDefaultDepartureDate(): string {
    const date = new Date()
    date.setDate(date.getDate() + 30)
    return date.toISOString().split('T')[0]
}

/**
 * Get default return date (37 days from now / 7 days after departure)
 */
export function getDefaultReturnDate(): string {
    const date = new Date()
    date.setDate(date.getDate() + 37)
    return date.toISOString().split('T')[0]
}
