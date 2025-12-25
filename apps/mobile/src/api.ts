// API service to communicate with Phoenix backend
const API_BASE_URL = 'http://localhost:4000/api'

export interface FlightSegment {
    airline: string
    airline_logo?: string
    flight_number: string
    airplane?: string
    departure_airport: {
        id: string
        name: string
        time: string
    }
    arrival_airport: {
        id: string
        name: string
        time: string
    }
    duration: number
    travel_class?: string
    legroom?: string
}

export interface FlightOffer {
    price: number
    currency: string
    departure_at: string | null
    arrival_at: string | null
    duration: string | null
    stops: number
    airline: string | null
    airline_code: string | null
    segments: FlightSegment[]
}

export interface ApiResponse<T> {
    success: boolean
    data?: T
    error?: string
}

export async function searchCheapestFlight(
    origin: string,
    destination: string,
    date: string
): Promise<ApiResponse<FlightOffer>> {
    try {
        const response = await fetch(`${API_BASE_URL}/flights/cheapest`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ origin, destination, date }),
        })

        return await response.json()
    } catch (error) {
        return {
            success: false,
            error: error instanceof Error ? error.message : 'Network error',
        }
    }
}

export async function searchFlights(
    origin: string,
    destination: string,
    date: string,
    adults: number = 1
): Promise<ApiResponse<FlightOffer[]>> {
    try {
        const response = await fetch(`${API_BASE_URL}/flights/search`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ origin, destination, date, adults }),
        })

        return await response.json()
    } catch (error) {
        return {
            success: false,
            error: error instanceof Error ? error.message : 'Network error',
        }
    }
}
