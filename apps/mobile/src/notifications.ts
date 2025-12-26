// Notification service for Tauri native notifications
import {
    isPermissionGranted,
    requestPermission,
    sendNotification
} from '@tauri-apps/plugin-notification'

/**
 * Check and request notification permission if needed.
 * Returns true if notifications are allowed.
 */
export async function ensureNotificationPermission(): Promise<boolean> {
    try {
        let granted = await isPermissionGranted()

        if (!granted) {
            const permission = await requestPermission()
            granted = permission === 'granted'
        }

        return granted
    } catch (error) {
        console.error('[Notification] Permission check failed:', error)
        return false
    }
}

/**
 * Send a notification when a flight is saved.
 */
export async function notifyFlightSaved(
    origin: string,
    destination: string,
    price: number,
    currency: string
): Promise<void> {
    const hasPermission = await ensureNotificationPermission()

    if (!hasPermission) {
        console.warn('[Notification] Permission not granted')
        return
    }

    const formattedPrice = new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: currency
    }).format(price)

    await sendNotification({
        title: '✈️ Vuelo guardado',
        body: `${origin} → ${destination} - ${formattedPrice}`
    })

    console.log('[Notification] Flight saved notification sent')
}
