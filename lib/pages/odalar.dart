import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/Constants.dart';
import 'package:wordle/pages/Oyun_ekrani.dart';
import 'package:wordle/providers/authentication_provider.dart';
import 'package:wordle/providers/game_provider.dart';

class Odalar extends StatefulWidget {
  const Odalar({
    Key? key,
    required this.isCustomTime,
  }) : super(key: key);

  final bool isCustomTime;

  @override
  State<Odalar> createState() => _OdalarState();
}

class _OdalarState extends State<Odalar> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Odalar"),
        backgroundColor: Color(0xff833ac8),
        shadowColor: Color(0xff833ac8),
      ),
      backgroundColor: Color(0xff21254A),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "5 harflik bir kelime giriniz",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Örnek: kelime",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    playGame(gameProvider: context.read<GameProvider>());
                  },
                  child: Text('Oyuna Başla'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void playGame({required GameProvider gameProvider}) async {
    final userModel = context.read<AuthenticationProvider>().userModel;

    final String incrementalTime = "15";

    final String whitetime = _controller.text;
    final String blacktime = _controller.text;

    if (incrementalTime != '0') {
      gameProvider.setIncrementalValue(value: int.parse(incrementalTime));
    }

    await gameProvider
        .setGameTime(
      newSavedWhitesTime: whitetime,
      newSavedBlacksTime: blacktime,
    )
        .whenComplete(() {
      if (gameProvider.vsComputer) {
        gameProvider.setIsLoading(value: false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Oyun_ekrani()),
        );
      } else {
        gameProvider.searchPlayer(
          userModel: userModel!,
          onSuccess: () {
            if (gameProvider.waitingText == Constants.searchingPlayerText) {
              gameProvider.checkIfOpponentJoined(
                userModel: userModel,
                onSuccess: () {
                  gameProvider.setIsLoading(value: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Oyun_ekrani()),
                  );
                },
              );
            } else {
              gameProvider.setIsLoading(value: false);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Oyun_ekrani()),
              );
            }
          },
          onFail: (error) {
            gameProvider.setIsLoading(value: false);
            print(error);
          },
        );
      }
    });
  }

  Widget buildAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
    );
  }
}
