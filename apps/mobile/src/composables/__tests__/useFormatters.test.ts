/**
 * Tests for useFormatters composable
 */
import { describe, it, expect } from 'vitest'
import {
    formatPrice,
    formatDate,
    formatShortDate,
    formatTime,
    formatDuration,
    formatTimeAgo
} from '../useFormatters'

describe('useFormatters', () => {
    describe('formatPrice', () => {
        it('formats price with default currency (MXN)', () => {
            const result = formatPrice(9000)
            expect(result).toMatch(/9,000|9.000/) // Locale may vary
            expect(result).toContain('$')
        })

        it('formats price with specified currency', () => {
            const result = formatPrice(1500, 'USD')
            expect(result).toMatch(/1,500|1.500/)
        })

        it('handles zero price', () => {
            const result = formatPrice(0)
            expect(result).toContain('0')
        })

        it('handles large prices', () => {
            const result = formatPrice(150000)
            expect(result).toMatch(/150,000|150.000/)
        })
    })

    describe('formatDate', () => {
        it('formats ISO date string to short format', () => {
            const result = formatDate('2024-12-27')
            expect(result).toBeTruthy()
            expect(result.length).toBeGreaterThan(0)
        })
    })

    describe('formatShortDate', () => {
        it('formats date to short format without year', () => {
            const result = formatShortDate('2024-12-27')
            expect(result).toBeTruthy()
        })

        it('returns empty string for empty input', () => {
            const result = formatShortDate('')
            expect(result).toBe('')
        })
    })

    describe('formatTime', () => {
        it('formats datetime to time only', () => {
            const result = formatTime('2024-12-27 14:30:00')
            expect(result).toMatch(/14:30|2:30/)
        })

        it('returns N/A for null input', () => {
            const result = formatTime(null)
            expect(result).toBe('N/A')
        })
    })

    describe('formatDuration', () => {
        it('formats minutes to hours and minutes', () => {
            const result = formatDuration(150)
            expect(result).toBe('2h 30m')
        })

        it('formats ISO 8601 duration', () => {
            const result = formatDuration('PT2H30M')
            expect(result).toBe('2h 30m')
        })

        it('returns N/A for null input', () => {
            const result = formatDuration(null)
            expect(result).toBe('N/A')
        })
    })

    describe('formatTimeAgo', () => {
        it('returns "Never" for null input', () => {
            const result = formatTimeAgo(null)
            expect(result).toBe('Never')
        })

        it('formats recent time as minutes ago', () => {
            const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString()
            const result = formatTimeAgo(fiveMinutesAgo)
            expect(result).toMatch(/\d+m ago/)
        })

        it('formats hours ago correctly', () => {
            const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()
            const result = formatTimeAgo(twoHoursAgo)
            expect(result).toMatch(/\d+h ago/)
        })
    })
})
