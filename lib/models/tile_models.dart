import 'package:wordle/constants/answer_stages.dart';

class TileModel {
  late final String letter;

  AnswerStage answerStage;

  TileModel({required this.letter, required this.answerStage});
}
