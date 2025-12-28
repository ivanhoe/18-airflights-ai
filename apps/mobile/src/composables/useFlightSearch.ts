import { ref } from 'vue'
import { searchFlights, type FlightOffer } from '../api'
import { getDefaultDepartureDate, getDefaultReturnDate } from '../utils/dates'

/**
 * Composable for flight search functionality
 */
export function useFlightSearch() {
    // Search form state
    const origin = ref('MEX')
    const destination = ref('VIE')
    const departureDate = ref(getDefaultDepartureDate())
    const returnDate = ref(getDefaultReturnDate())
    const roundTrip = ref(false)

    // Results state
    const offers = ref<FlightOffer[]>([])
    const loading = ref(false)
    const error = ref<string | null>(null)

    /**
     * Execute flight search
     */
    async function search() {
        loading.value = true
        error.value = null
        offers.value = []

        const result = await searchFlights(
            origin.value,
            destination.value,
            departureDate.value
        )

        loading.value = false

        if (result.success && result.data && result.data.length > 0) {
            // Take top 5 cheapest
            offers.value = result.data.slice(0, 5)
        } else {
            error.value = result.error || 'No flights found'
        }
    }

    return {
        // Form state
        origin,
        destination,
        departureDate,
        returnDate,
        roundTrip,
        // Results state
        offers,
        loading,
        error,
        // Actions
        search
    }
}
