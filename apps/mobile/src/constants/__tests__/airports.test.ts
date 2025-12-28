/**
 * Tests for airports constant
 */
import { describe, it, expect } from 'vitest'
import { airports, type Airport } from '../airports'

describe('airports constant', () => {
    it('exports an array of airports', () => {
        expect(Array.isArray(airports)).toBe(true)
        expect(airports.length).toBeGreaterThan(0)
    })

    it('each airport has required fields', () => {
        airports.forEach((airport: Airport) => {
            expect(airport).toHaveProperty('code')
            expect(airport).toHaveProperty('name')
            expect(typeof airport.code).toBe('string')
            expect(typeof airport.name).toBe('string')
        })
    })

    it('all airport codes are 3 characters (IATA format)', () => {
        airports.forEach((airport: Airport) => {
            expect(airport.code).toHaveLength(3)
            expect(airport.code).toMatch(/^[A-Z]{3}$/)
        })
    })

    it('has no duplicate airport codes', () => {
        const codes = airports.map((a) => a.code)
        const uniqueCodes = new Set(codes)
        expect(uniqueCodes.size).toBe(codes.length)
    })

    it('includes common Mexican airports', () => {
        const codes = airports.map((a) => a.code)
        expect(codes).toContain('MEX')
        expect(codes).toContain('GDL')
        expect(codes).toContain('CUN')
    })

    it('includes common international airports', () => {
        const codes = airports.map((a) => a.code)
        expect(codes).toContain('JFK')
        expect(codes).toContain('LAX')
        expect(codes).toContain('MAD')
    })
})
