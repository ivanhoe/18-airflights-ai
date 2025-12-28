<script setup lang="ts">
/**
 * PriceDisplay - Reusable formatted price display
 * 
 * Displays a price with currency formatting. Used in FlightResult and WatcherCard.
 */
import { computed } from 'vue'

const props = defineProps<{
  price: number
  currency?: string
  size?: 'sm' | 'md' | 'lg' | 'xl'
  highlight?: boolean
}>()

const formattedPrice = computed(() => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: props.currency || 'MXN',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(props.price)
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm': return 'text-sm'
    case 'md': return 'text-lg'
    case 'lg': return 'text-2xl'
    case 'xl': return 'text-3xl'
    default: return 'text-xl'
  }
})
</script>

<template>
  <span 
    class="price-display font-bold"
    :class="[
      sizeClasses,
      highlight ? 'text-green-400' : 'text-white'
    ]"
  >
    {{ formattedPrice }}
  </span>
</template>

<style scoped>
.price-display {
  font-variant-numeric: tabular-nums;
}
</style>
