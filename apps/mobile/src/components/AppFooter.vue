<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <footer class="app-footer">
    {{ t('footer') }}
  </footer>
</template>

<style scoped>
.app-footer {
  text-align: center;
  padding: 24px 16px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.4);
  margin-top: auto;
}
</style>
