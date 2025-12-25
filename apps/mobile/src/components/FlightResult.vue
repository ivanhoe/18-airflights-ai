<script setup lang="ts">
import { computed } from 'vue'
import type { FlightOffer } from '../api'

const props = defineProps<{
  offer: FlightOffer
}>()

const formattedPrice = computed(() => {
  if (!props.offer?.price) return null
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: props.offer.currency || 'USD'
  }).format(props.offer.price)
})

function formatDuration(duration: string | null): string {
  if (!duration) return 'N/A'
  return duration.replace('PT', '').replace('H', 'h ').replace('M', 'm')
}

function formatDateTime(dateStr: string | null): string {
  if (!dateStr) return 'N/A'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + 
    ', ' + date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <section class="results-card">
    <h2>🎉 Cheapest Flight Found!</h2>

    <div class="offer">
      <!-- Price -->
      <div class="price">
        <div class="amount">{{ formattedPrice }}</div>
        <div class="currency">{{ offer.currency }}</div>
      </div>

      <!-- Flight Details -->
      <div class="details">
        <div class="detail">
          <span class="label">Airline</span>
          <span class="value">{{ offer.airline_code || 'N/A' }}</span>
        </div>
        <div class="detail">
          <span class="label">Stops</span>
          <span class="value">{{ offer.stops === 0 ? 'Direct' : `${offer.stops} stop(s)` }}</span>
        </div>
        <div class="detail">
          <span class="label">Duration</span>
          <span class="value">{{ formatDuration(offer.duration) }}</span>
        </div>
        <div class="detail">
          <span class="label">Departure</span>
          <span class="value">{{ formatDateTime(offer.departure_at) }}</span>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.results-card {
  margin-top: 1.5rem;
  background: var(--bg-secondary);
  backdrop-filter: blur(10px);
  border-radius: 1.5rem;
  padding: 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.results-card h2 {
  text-align: center;
  margin-bottom: 1.5rem;
}

.offer {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.2), rgba(16, 185, 129, 0.2));
  border-radius: 1rem;
  padding: 1.5rem;
  border: 1px solid rgba(34, 197, 94, 0.3);
}

.price {
  text-align: center;
  margin-bottom: 1.5rem;
}

.amount {
  font-size: 2.5rem;
  font-weight: bold;
  color: var(--success);
}

.currency {
  font-size: 0.9rem;
  color: #86efac;
}

.details {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

.detail {
  background: rgba(255, 255, 255, 0.05);
  padding: 0.75rem;
  border-radius: 0.75rem;
}

.detail .label {
  display: block;
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.detail .value {
  font-size: 1.1rem;
  font-weight: 600;
}
</style>
