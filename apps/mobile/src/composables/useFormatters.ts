/**
 * useFormatters - Composable with all formatting utilities
 * 
 * Centralizes all formatting functions to avoid duplication across components.
 */

/**
 * Format a price with currency
 */
export function formatPrice(price: number, currency: string = 'MXN'): string {
    return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: currency,
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(price)
}

/**
 * Format a date string to short format (e.g., "27 dic 2024")
 */
export function formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString('es-MX', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
    })
}

/**
 * Format a date string to short format without year (e.g., "Dec 27")
 */
export function formatShortDate(dateString: string): string {
    if (!dateString) return ''
    const date = new Date(dateString.replace(' ', 'T'))
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

/**
 * Format a datetime string (e.g., "27 dic, 14:30")
 */
export function formatDateTime(dateString: string): string {
    return new Date(dateString).toLocaleString('es-MX', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    })
}

/**
 * Format a time string (e.g., "14:30")
 */
export function formatTime(timeString: string | null): string {
    if (!timeString) return 'N/A'
    const date = new Date(timeString.replace(' ', 'T'))
    return date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
    })
}

/**
 * Format a duration (ISO 8601 or minutes)
 */
export function formatDuration(duration: string | number | null): string {
    if (!duration) return 'N/A'

    if (typeof duration === 'number') {
        const hours = Math.floor(duration / 60)
        const mins = duration % 60
        return `${hours}h ${mins}m`
    }

    // Handle ISO 8601 duration (e.g., "PT2H30M")
    return duration.replace('PT', '').replace('H', 'h ').replace('M', 'm')
}

/**
 * Format relative time ago (e.g., "hace 5m", "hace 2h")
 */
export function formatTimeAgo(dateString: string | null): string {
    if (!dateString) return 'Nunca'

    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMins / 60)
    const diffDays = Math.floor(diffHours / 24)

    if (diffMins < 60) return `hace ${diffMins}m`
    if (diffHours < 24) return `hace ${diffHours}h`
    return `hace ${diffDays}d`
}

/**
 * Composable hook that returns all formatters
 */
export function useFormatters() {
    return {
        formatPrice,
        formatDate,
        formatShortDate,
        formatDateTime,
        formatTime,
        formatDuration,
        formatTimeAgo
    }
}
