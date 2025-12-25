<script setup lang="ts">
defineProps<{
  origin: string
  originCity: string
  destination: string
  destinationCity: string
}>()
</script>

<template>
  <div class="route">
    <div class="airport">
      <div class="code">{{ origin }}</div>
      <div class="city">{{ originCity }}</div>
    </div>
    <div class="arrow">→</div>
    <div class="airport">
      <div class="code">{{ destination }}</div>
      <div class="city">{{ destinationCity }}</div>
    </div>
  </div>
</template>

<style scoped>
.route {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.airport {
  text-align: center;
}

.code {
  font-size: 2rem;
  font-weight: bold;
}

.city {
  font-size: 0.8rem;
  color: var(--text-secondary);
}

.arrow {
  font-size: 1.5rem;
  color: var(--text-secondary);
}
</style>
