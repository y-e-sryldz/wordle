import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wordle/Constants.dart';
import 'package:wordle/models/user_model.dart';

Future<String> kelimemiz() async {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final availableGames =
      await firebaseFirestore.collection(Constants.availableGames).get();

  final List<DocumentSnapshot> gamesList = availableGames.docs
      .where((element) => element[Constants.isPlaying] == true)
      .toList();

  final opponentsGame = await firebaseFirestore
      .collection(Constants.availableGames)
      .doc(gamesList.first[Constants.gameCreatorUid])
      .get();

  var userData = opponentsGame.data(); // Veritabanından gelen veri

  var userModel = UserModel.fromMap(userData!); // UserModel'e dönüştürme

  if (opponentsGame.exists) {
    var gameCreatorName = opponentsGame.data()?[Constants.gameCreatorName];
    print('bunlar aradıkların');
    print(userModel.name);
    print(gameCreatorName);

    if (userModel.name.toString() == gameCreatorName.toString()) {
      var whitesTime = opponentsGame.data()?[Constants.whitesTime];
      return whitesTime;
    } else {
      var blacksTime = opponentsGame.data()?[Constants.blacksTime];
      print("ALDIĞIN KELİMEE" + blacksTime);
      return blacksTime;
    }
  } else {
    print('Opponents game document does not exist.');
    return 'hello';
  }
}
