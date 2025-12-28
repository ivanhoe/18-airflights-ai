/**
 * useLocale - Composable for language/locale management
 * 
 * Centralizes locale switching logic for the app.
 */
import { useI18n } from 'vue-i18n'
import { computed } from 'vue'

export function useLocale() {
    const { locale } = useI18n()

    /**
     * Current locale code ('es' or 'en')
     */
    const currentLocale = computed(() => locale.value)

    /**
     * Check if current locale is Spanish
     */
    const isSpanish = computed(() => locale.value === 'es')

    /**
     * Get the flag emoji for current locale
     */
    const flagEmoji = computed(() => locale.value === 'es' ? '🇲🇽' : '🇺🇸')

    /**
     * Get tooltip text for language toggle button
     */
    const toggleTooltip = computed(() =>
        locale.value === 'es' ? 'Switch to English' : 'Cambiar a Español'
    )

    /**
     * Toggle between Spanish and English
     */
    function toggleLanguage() {
        locale.value = locale.value === 'es' ? 'en' : 'es'
    }

    /**
     * Set a specific locale
     */
    function setLocale(newLocale: 'es' | 'en') {
        locale.value = newLocale
    }

    return {
        currentLocale,
        isSpanish,
        flagEmoji,
        toggleTooltip,
        toggleLanguage,
        setLocale
    }
}
