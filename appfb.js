'use strict';

var config = {
    apiKey: "AIzaSyBXNoo8V1qZ2CUzagVA6eIChaoDjbAiVMM",
    authDomain: "elm-chat-ea700.firebaseapp.com",
    databaseURL: "https://elm-chat-ea700.firebaseio.com",
    storageBucket: "elm-chat-ea700.appspot.com",
    // messagingSenderId: "398624235755"
  };

var app = firebase.initializeApp(config);
var database = app.database();
var CUSTOMERREFPATH = "chats"

// AUTH
firebase.auth().signInAnonymously().catch(function(error) {
  // Handle Errors here.
  var errorCode = error.code;
  var errorMessage = error.message;
  console.log("AUTH ERROR: ", errorCode, errorMessage);
  // ...
});

firebase.auth().onAuthStateChanged(function(user) {
  if (user) {
    // User is signed in.
    var isAnonymous = user.isAnonymous;
    var uid = user.uid;
    console.log("SIGNED IN: ", isAnonymous, uid);
  } else {
    console.log("SIGNED OUT")
  }
});

// PORTS
function addMessage(message){
  var promise = database
    .ref(CUSTOMERREFPATH)
    .push(message);
  return promise;
}

function updateCustomer(customer){
  var id = customer.id;
  var promise = database
    .ref(CUSTOMERREFPATH + "/" + id)
    .set(customer);
  return promise;
}

function deleteCustomer(customer){
  var id = customer.id;
  var promise = database
    .ref(CUSTOMERREFPATH + "/" + id)
    .remove();
  return promise;
}

function messageListener(){
  return database.ref(CUSTOMERREFPATH);
}
