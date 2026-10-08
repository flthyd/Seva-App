const { initializeApp } = require('firebase/app');
const { getFirestore, collection, getDocs } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: "AIzaSyBL0ucvw6HiBr0N7QqdfJprZG_qQ2VNLnY",
  authDomain: "sevaapp-af368.firebaseapp.com",
  projectId: "sevaapp-af368",
  storageBucket: "sevaapp-af368.firebasestorage.app",
  messagingSenderId: "11804332615",
  appId: "1:11804332615:web:a38c1eefe4531b84d6d762"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function check() {
  const querySnapshot = await getDocs(collection(db, "flowers"));
  querySnapshot.forEach((doc) => {
    console.log(doc.id, " => ", doc.data());
  });
}
check();
