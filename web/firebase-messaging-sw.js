importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

const firebaseConfig = {
  apiKey: "AIzaSyCcBYFUJbTyRWUjy6dhLbLLEj_lwhqnsh4",
  authDomain: "darkpatterns-ac762.firebaseapp.com",
  projectId: "darkpatterns-ac762",
  storageBucket: "darkpatterns-ac762.appspot.com",
  messagingSenderId: "552263184384",
  appId: "1:552263184384:web:87e17944dc571dc4e028e5"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});