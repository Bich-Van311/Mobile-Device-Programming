
importScripts(
  'https://www.gstatic.com/firebasejs/11.10.0/firebase-app-compat.js'
);

importScripts(
  'https://www.gstatic.com/firebasejs/11.10.0/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: "AIzaSyD7u275DBW8ziPCWMxxG3IK-3sch3vpjB8",
  authDomain: "uth-todo-week-05.firebaseapp.com",
  projectId: "uth-todo-week-05",
  messagingSenderId: "214158607395",
  appId: "1:214158607395:web:4b759232a4be4f264d9d96"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message:', payload);
});
