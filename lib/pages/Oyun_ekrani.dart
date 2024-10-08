import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/components/Grid.dart';
import 'package:wordle/components/keyboard_row.dart';
import 'package:wordle/constants/words.dart';
import 'package:wordle/data/keys_map.dart';
import 'package:wordle/providers/authentication_provider.dart';
import '../controller.dart';

class Oyun_ekrani extends StatefulWidget {
  const Oyun_ekrani({super.key});

  @override
  State<Oyun_ekrani> createState() => _Oyun_ekraniState();
}

class _Oyun_ekraniState extends State<Oyun_ekrani> {
  @override
  void initState() {
    _fetchWord();
    super.initState();
  }

  void _fetchWord() async {
    final userModel = context.read<AuthenticationProvider>().userModel;
    String _word = await kelimemiz(userModel: userModel!);
    if (_word != null) {
      setState(() {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          Provider.of<Controller>(context, listen: false)
              .setCorrectWord(word: _word);
        });
      });
    } else {
      // Hata durumunda yapılacak işlemler
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wordle"),
        centerTitle: true,
        backgroundColor: Color(0xff833ac8),
        shadowColor: Color(0xff833ac8),
        elevation: 0,
      ),
      backgroundColor: Color(0xff21254A),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              color: const Color(0xff21254A),
              child: Grid(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Color(0xff21254A),
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
