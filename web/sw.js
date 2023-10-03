self.addEventListener('install', (event) => {
    console.log('[Service Worker] Installing Service Worker...', event);
});

self.addEventListener('activate', (event) => {
    console.log('[Service Worker] Activating Service Worker...', event);
    return self.clients.claim();
});

self.addEventListener('message', (event) => {
    console.log('Scheduling Notification', event);
    if (event.data.action === 'scheduleNotification') {
        const delay = event.data.delay;
        const title = event.data.title;
        const options = {
            body: event.data.body,
        };
        console.log('Successfully scheduled', delay, title, options);
        setTimeout(() => {
            self.registration.showNotification(title, options);
        }, delay);
    }
});
