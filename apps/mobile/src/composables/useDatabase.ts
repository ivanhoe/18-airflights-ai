import { ref, onMounted } from 'vue'
import { initDatabase } from '../db'

/**
 * Composable for database initialization and status
 */
export function useDatabase() {
    const isInitialized = ref(false)
    const initError = ref<Error | null>(null)

    async function initialize() {
        try {
            await initDatabase()
            isInitialized.value = true
            initError.value = null
            console.log('[useDatabase] Database initialized successfully')
        } catch (e) {
            initError.value = e instanceof Error ? e : new Error(String(e))
            console.error('Failed to initialize database:', e)
        }
    }

    onMounted(() => {
        initialize()
    })

    return {
        isInitialized,
        initError,
        initialize
    }
}
