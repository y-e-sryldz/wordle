import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/constants/answer_stages.dart';
import 'package:wordle/constants/colors.dart';
import 'package:wordle/controller.dart';

class Tile extends StatefulWidget {
  const Tile({required this.index,
  Key? key,
  }):super(key: key);

  final int index;


  @override
  State<Tile> createState() => _TileState();
}
  
class _TileState extends State<Tile> {

  Color _backgroundcolor = Colors.transparent;
  late AnswerStage _answerStage;


  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (_, notifier, __) {
        String text = "";
        if (widget.index < notifier.tilesEnterad.length) {
          text = notifier.tilesEnterad[widget.index].letter;
          _answerStage = notifier.tilesEnterad[widget.index].answerStage;
          if(_answerStage == AnswerStage.correct){
            _backgroundcolor = correctGreen;
            

          }else if(_answerStage == AnswerStage.contains){
            _backgroundcolor = containsYellow;


          }

          return Container(
            color: _backgroundcolor,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(text)));
        } else {
          return SizedBox();
        }
    });
  }
}
