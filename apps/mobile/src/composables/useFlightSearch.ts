import { ref } from 'vue'
import { searchFlights, type FlightOffer } from '../api'
import { saveFlightResult, toggleFavorite } from '../db'
import { notifyFlightSaved } from '../notifications'
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

    // Saved flights tracking
    const savedOfferIds = ref<Map<number, number>>(new Map())
    const lastSavedId = ref<number | null>(null)
    const isFavorite = ref(false)

    /**
     * Execute flight search
     */
    async function search() {
        loading.value = true
        error.value = null
        offers.value = []
        lastSavedId.value = null
        isFavorite.value = false

        const result = await searchFlights(
            origin.value,
            destination.value,
            departureDate.value
        )

        loading.value = false

        if (result.success && result.data && result.data.length > 0) {
            // Take top 5 cheapest
            offers.value = result.data.slice(0, 5)
            savedOfferIds.value.clear()
        } else {
            error.value = result.error || 'No flights found'
        }
    }

    /**
     * Save a flight offer
     */
    async function saveFlight(offer: FlightOffer, index: number) {
        try {
            const savedId = await saveFlightResult(
                origin.value,
                destination.value,
                departureDate.value,
                offer
            )

            // Track this offer as saved
            savedOfferIds.value.set(index, savedId)
            lastSavedId.value = savedId

            // Send native notification
            await notifyFlightSaved(
                origin.value,
                destination.value,
                offer.price,
                offer.currency
            )

            console.log('[useFlightSearch] Flight saved and notification sent')
        } catch (e) {
            console.error('Failed to save flight:', e)
        }
    }

    /**
     * Toggle favorite status for a saved flight
     */
    async function toggleFavoriteStatus(id: number) {
        try {
            isFavorite.value = await toggleFavorite(id)
        } catch (e) {
            console.error('Failed to toggle favorite:', e)
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
        // Saved state
        savedOfferIds,
        lastSavedId,
        isFavorite,
        // Actions
        search,
        saveFlight,
        toggleFavoriteStatus
    }
}
