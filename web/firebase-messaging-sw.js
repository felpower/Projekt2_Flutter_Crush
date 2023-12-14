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

let lastNotificationId = null;

let darkPatternsRandomValue = 0;

self.addEventListener('message', function(event){
  if (event.data && event.data.type === 'SET_DARK_PATTERNS_VALUE') {
    darkPatternsRandomValue = event.data.value;
    console.log('receiveDarkPatternsValue Dark Patterns Value: ', darkPatternsRandomValue);
  }
});

messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);
    if(darkPatternsRandomValue != 1){
      return;
    }
    const currentNotificationId = payload.data['google.c.a.c_id'];

    if (lastNotificationId === currentNotificationId) {
        console.log('Duplicate notification, not displaying.');
        return;
    }

    lastNotificationId = currentNotificationId;

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
      };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', function(event) {
    console.log('Notification clicked ', event);
    event.notification.close();

   // Example: navigate to a specific URL on notification click
    event.waitUntil(
        clients.openWindow('/?source=notification')
    );
 });