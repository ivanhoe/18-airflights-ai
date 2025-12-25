<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  origin: { type: String, default: 'MEX' },
  destination: { type: String, default: 'VIE' },
  date: { type: String, default: '' },
  offer: { type: Object, default: null },
  loading: { type: Boolean, default: false },
  error: { type: String, default: null }
})

const emit = defineEmits(['search'])

const selectedDate = ref(props.date || getDefaultDate())

function getDefaultDate() {
  const date = new Date()
  date.setDate(date.getDate() + 30)
  return date.toISOString().split('T')[0]
}

function handleSearch() {
  emit('search', { date: selectedDate.value })
}

const formattedPrice = computed(() => {
  if (!props.offer?.price) return null
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: props.offer.currency || 'USD'
  }).format(props.offer.price)
})

function formatDuration(duration) {
  if (!duration) return 'N/A'
  return duration.replace('PT', '').replace('H', 'h ').replace('M', 'm')
}

function formatDateTime(dateStr) {
  if (!dateStr) return 'N/A'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + 
    ', ' + date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
    <div class="container mx-auto px-4 py-12">
      <!-- Header -->
      <div class="text-center mb-12">
        <h1 class="text-5xl font-bold text-white mb-4">
          ✈️ Flight Tracker
        </h1>
        <p class="text-xl text-purple-200">
          Find the cheapest flights from Mexico City to Vienna
        </p>
      </div>

      <!-- Search Card -->
      <div class="max-w-2xl mx-auto">
        <div class="bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20">
          <!-- Route Display -->
          <div class="flex items-center justify-center gap-6 mb-8">
            <div class="text-center">
              <div class="text-4xl font-bold text-white">{{ origin }}</div>
              <div class="text-purple-300 text-sm">Mexico City</div>
            </div>
            <div class="text-purple-400 text-3xl">→</div>
            <div class="text-center">
              <div class="text-4xl font-bold text-white">{{ destination }}</div>
              <div class="text-purple-300 text-sm">Vienna</div>
            </div>
          </div>

          <!-- Search Form -->
          <form @submit.prevent="handleSearch" class="space-y-6">
            <div>
              <label class="block text-purple-200 text-sm font-medium mb-2">
                Departure Date
              </label>
              <input
                type="date"
                v-model="selectedDate"
                :min="new Date().toISOString().split('T')[0]"
                class="w-full px-4 py-3 bg-white/10 border border-white/30 rounded-xl text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              />
            </div>

            <button
              type="submit"
              :disabled="loading"
              class="w-full py-4 px-6 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-bold text-lg rounded-xl shadow-lg transform transition hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              <span v-if="loading" class="inline-flex items-center gap-2">
                <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                </svg>
                Searching...
              </span>
              <span v-else>🔍 Find Cheapest Flight</span>
            </button>
          </form>

          <!-- Error Message -->
          <div v-if="error" class="mt-6 p-4 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200">
            ⚠️ {{ error }}
          </div>
        </div>

        <!-- Results Card -->
        <transition name="fade">
          <div v-if="offer" class="mt-8 bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20">
            <h2 class="text-2xl font-bold text-white mb-6 text-center">
              🎉 Cheapest Flight Found!
            </h2>

            <div class="bg-gradient-to-r from-green-500/20 to-emerald-500/20 rounded-2xl p-6 border border-green-500/30">
              <!-- Price -->
              <div class="text-center mb-6">
                <div class="text-5xl font-bold text-green-400">{{ formattedPrice }}</div>
                <div class="text-green-200 text-sm">{{ offer.currency }}</div>
              </div>

              <!-- Flight Details -->
              <div class="grid grid-cols-2 gap-4 text-white">
                <div class="bg-white/5 rounded-xl p-4">
                  <div class="text-purple-300 text-sm">Airline</div>
                  <div class="text-xl font-semibold">{{ offer.airline_code || 'N/A' }}</div>
                </div>
                <div class="bg-white/5 rounded-xl p-4">
                  <div class="text-purple-300 text-sm">Stops</div>
                  <div class="text-xl font-semibold">
                    {{ offer.stops === 0 ? 'Direct' : `${offer.stops} stop(s)` }}
                  </div>
                </div>
                <div class="bg-white/5 rounded-xl p-4">
                  <div class="text-purple-300 text-sm">Duration</div>
                  <div class="text-xl font-semibold">{{ formatDuration(offer.duration) }}</div>
                </div>
                <div class="bg-white/5 rounded-xl p-4">
                  <div class="text-purple-300 text-sm">Departure</div>
                  <div class="text-xl font-semibold">{{ formatDateTime(offer.departure_at) }}</div>
                </div>
              </div>
            </div>
          </div>
        </transition>

        <!-- Footer -->
        <div class="text-center mt-12 text-purple-300 text-sm">
          Powered by Amadeus API • Built with Elixir, Phoenix LiveView & Vue
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
