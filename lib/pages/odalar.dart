import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/Constants.dart';
import 'package:wordle/pages/Oyun_ekrani.dart';
import 'package:wordle/providers/authentication_provider.dart';
import 'package:wordle/providers/game_provider.dart';

class Odalar extends StatefulWidget {
  const Odalar({
    super.key,
    required this.isCustomTime,
  });

  final bool isCustomTime;
  final String gameTime = "99";
  @override
  State<Odalar> createState() => _OdalarState();
}

class _OdalarState extends State<Odalar> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "odalar",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Consumer<GameProvider>(builder: (context, gameProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "5 harflik birkelime giriniz",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.grey,
                    )),
                  ),
                  style: TextStyle(
                      color: Colors.black), // Yazı rengini beyaz yapar
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text("oyuna başlamak için tıklayın"),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  // navigate to game screen
                  playGame(gameProvider: gameProvider);
                },
                child: Text('Play'),
              ),
            ],
          ),
        );
      }),
    );
  }

  void playGame({
    required GameProvider gameProvider,
  }) async {
    final userModel = context.read<AuthenticationProvider>().userModel;

    print(widget.gameTime);
    final String incrementalTime = "15";

    // get the value before the + sign
    final String whitetime = _controller.text;
    final String blacktime = _controller.text;

    // check if incremental is equal to 0
    if (incrementalTime != '0') {
      // save the incremental value
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
        // 3. navigate to game screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Oyun_ekrani()),
        );
      } else {
        // search for players
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
                // navigate to gameScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Oyun_ekrani()),
                );
              }
            },
            onFail: (error) {
              gameProvider.setIsLoading(value: false);
              print(error);
            });
      }
    });
  }
}
