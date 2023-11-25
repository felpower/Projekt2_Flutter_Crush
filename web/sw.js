//self.addEventListener('install', (event) => {
//    console.info('[Service Worker] Installing Service Worker...', event);
//    self.skipWaiting();
//});
//
//self.addEventListener('activate', (event) => {
//    console.info('[Service Worker] Activating Service Worker...', event);
//    event.waitUntil(self.clients.claim());
//});
//
//self.addEventListener('message', (event) => {
//    console.info('Scheduling Notification', event);
//    if (event.data.action === 'scheduleNotification') {
//        const delay = event.data.delay;
//        const title = event.data.title;
//        const options = {
//            body: event.data.body,
//            icon: '/assets/icons/icon-192x192.png',
//            badge: '/assets/icons/icon-192x192.png',
//        };
//        console.info('Successfully scheduled', delay, title, options);
//        setTimeout(() => {
//            self.registration.showNotification(title, options);
//        }, delay);
//    }
//});
//
//self.addEventListener('notificationclick', function(event) {
//    event.notification.close(); // Close the notification
//    event.waitUntil(
//        clients.matchAll({
//            type: "window"
//        }).then(function(clientList) {
//            for (let i = 0; i < clientList.length; i++) {
//                let client = clientList[i];
//                if (client.url == '/' && 'focus' in client) {
//                    return client.focus();
//                }
//            }
//            if (clients.openWindow) {
//                return clients.openWindow('/');
//            }
//        })
//    );
//});
