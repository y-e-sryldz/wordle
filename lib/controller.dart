import 'package:flutter/material.dart';
import 'package:wordle/constants/answer_stages.dart';
import 'package:wordle/models/tile_models.dart';

class Controller extends ChangeNotifier {
  String correctWord = "";

  int currenttile = 0, currentRow = 0;
  List<TileModel> tilesEnterad = [];

  setCorrectWord({required String word}) => correctWord = word;

  setKeyTapped({required String value}) {
    if (value == "ENTER") {

      if (currenttile == 5 * (currentRow + 1)) {
        checkWord();
      }
    } else if (value == "BACK") {
      if (currenttile > 0 * (currentRow + 1) - 5) {
        currenttile--;
        tilesEnterad.removeLast();
      }
    } else {
      if (currenttile < 5 * (currentRow + 1)) {
        tilesEnterad.add(
            TileModel(letter: value, answerStage: AnswerStage.notAnswered));
        currenttile++;
      }
    }
    notifyListeners();
  }

  checkWord() {
    List<String> guessed = [], remainingCorrect = [];
    String guessedWord = "";

    for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
      guessed.add(tilesEnterad[i].letter);
    }

    guessedWord = guessed.join();
    remainingCorrect = correctWord.characters.toList();
    print(remainingCorrect);

    if (guessedWord == correctWord) {
      for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
        tilesEnterad[i].answerStage = AnswerStage.correct;
      }
    } else {
      for (int i = 0; i < 5; i++) {
        if (guessedWord[i] == correctWord[i]) {
          remainingCorrect.remove(guessedWord[i]);
          tilesEnterad[i + (currentRow * 5)].answerStage = AnswerStage.correct;
        }
      }

      for (int i = 0; i < remainingCorrect.length; i++) {
        for (int j = 0; j < 5; j++) {
          if (remainingCorrect[i] ==
              tilesEnterad[j + (currentRow * 5)].letter) {
            if (tilesEnterad[j + (currentRow * 5)].answerStage !=
                AnswerStage.correct) {
              tilesEnterad[j + (currentRow * 5)].answerStage =
                  AnswerStage.contains;
            }
          }
        }
      }
    }

    currentRow++;
    notifyListeners();
  }
}
