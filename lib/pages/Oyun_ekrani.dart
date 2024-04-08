import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/components/Grid.dart';
import 'package:wordle/components/keyboard_row.dart';
import 'package:wordle/constants/words.dart';
import 'package:wordle/data/keys_map.dart';

import '../controller.dart';

class Oyun_ekrani extends StatefulWidget {
  const Oyun_ekrani({super.key});

  @override
  State<Oyun_ekrani> createState() => _Oyun_ekraniState();
}

class _Oyun_ekraniState extends State<Oyun_ekrani> {
  late String _word;

  @override
  void initState() {
    final r = Random().nextInt(words.length);
    _word = words[r];

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<Controller>(context, listen: false)
          .setCorrectWord(word: _word);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wordle"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              color: Colors.yellow,
              child: Grid(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.green,
              child: Column(
                children: [
                  KeyboardRow(min: 1, max: 12),
                  KeyboardRow(min: 13, max: 23),
                  KeyboardRow(min: 24, max: 34),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
