importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

const firebaseConfig = {
    apiKey: "AIzaSyCcBYFUJbTyRWUjy6dhLbLLEj_lwhqnsh4",
    authDomain: "darkpatterns-ac762.firebaseapp.com",
    databaseURL: "https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "darkpatterns-ac762",
    storageBucket: "darkpatterns-ac762.appspot.com",
    messagingSenderId: "552263184384",
    appId: "1:552263184384:web:87e17944dc571dc4e028e5"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

let darkPatternsValue = 0;

self.addEventListener('message', function(event) {
    if (event.data && event.data.type === 'SET_DARK_PATTERNS_VALUE') {
        darkPatternsValue = event.data.value;
    }
});

messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);
    if (darkPatternsValue != 1) {
        return;
    }

    const notificationTitle = payload.data.title;
    const notificationOptions = {
        body: payload.data.body,
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
    console.log('Notification clicked ', event);
    const clickedNotification = event.notification;
    clickedNotification.close();

    const promiseChain = clients.openWindow('/?source=notification')
    event.waitUntil(promiseChain);
});