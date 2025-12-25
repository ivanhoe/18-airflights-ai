<script setup lang="ts">
defineProps<{
  message: string
}>()
</script>

<template>
  <div class="error">
    ⚠️ {{ message }}
  </div>
</template>

<style scoped>
.error {
  margin-top: 1rem;
  padding: 0.75rem;
  background: rgba(239, 68, 68, 0.2);
  border: 1px solid rgba(239, 68, 68, 0.5);
  border-radius: 0.75rem;
  color: #fca5a5;
}
</style>
