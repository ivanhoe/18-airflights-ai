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
 * Send a notification for a price alert.
 */
export async function notifyPriceAlert(
    route: string,
    newPrice: number,
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
    }).format(newPrice)

    await sendNotification({
        title: '🔔 Alerta de Precio',
        body: `¡${route} bajó a ${formattedPrice}!`
    })

    console.log('[Notification] Price alert notification sent')
}
