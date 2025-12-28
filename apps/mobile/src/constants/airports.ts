/**
 * Airport constants - Single source of truth for airport data
 */
export interface Airport {
    code: string
    name: string
    city?: string
    country?: string
}

export const airports: Airport[] = [
    // Mexico
    { code: 'MEX', name: 'Ciudad de México', country: 'MX' },
    { code: 'MTY', name: 'Monterrey', country: 'MX' },
    { code: 'GDL', name: 'Guadalajara', country: 'MX' },
    { code: 'CUN', name: 'Cancún', country: 'MX' },
    { code: 'TIJ', name: 'Tijuana', country: 'MX' },

    // Europe
    { code: 'VIE', name: 'Viena', country: 'AT' },
    { code: 'MAD', name: 'Madrid', country: 'ES' },
    { code: 'BCN', name: 'Barcelona', country: 'ES' },
    { code: 'LHR', name: 'Londres', country: 'GB' },
    { code: 'CDG', name: 'París CDG', country: 'FR' },
    { code: 'FCO', name: 'Roma', country: 'IT' },
    { code: 'AMS', name: 'Ámsterdam', country: 'NL' },
    { code: 'FRA', name: 'Frankfurt', country: 'DE' },

    // USA
    { code: 'JFK', name: 'New York JFK', country: 'US' },
    { code: 'LAX', name: 'Los Angeles', country: 'US' },
    { code: 'MIA', name: 'Miami', country: 'US' },
    { code: 'DFW', name: 'Dallas', country: 'US' }
]

export default airports
