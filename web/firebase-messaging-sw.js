// Import the functions you need from the SDKs you need
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDDC-2IZHc3NCXp1lQtOauQMyZ-1Wz5RrE",
  authDomain: "flutter-crush-4ece9.firebaseapp.com",
  projectId: "flutter-crush-4ece9",
  storageBucket: "flutter-crush-4ece9.appspot.com",
  messagingSenderId: "287711278777",
  appId: "1:287711278777:web:07e4db55dcb6ef0be44d68",
  measurementId: "G-0ZT7HMRWNX"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});