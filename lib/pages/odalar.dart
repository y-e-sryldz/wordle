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
  int whiteTimeInMenutes = 100;
  int blackTimeInMenutes = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("odalar"),
        centerTitle: true,
      ),
      body: Consumer<GameProvider>(builder: (context, gameProvider, child) {
        return Column(
          children: [
            Text("oyuna başlamak için tıklayın"),
            ElevatedButton(
              onPressed: () {
                // navigate to game screen
                playGame(gameProvider: gameProvider);
              },
              child: Text('Play'),
            ),
          ],
        );
      }),
    );
  }

  void playGame({
    required GameProvider gameProvider,
  }) async {
    final userModel = context.read<AuthenticationProvider>().userModel;
    // check if is custome time
    if (false) {
      // check all timer are greater than 0
      if (whiteTimeInMenutes <= 0 || blackTimeInMenutes <= 0) {
        // show snackbar
        print("zaman 0 olamaz");
        return;
      }

      // 1. start loading dialog
      gameProvider.setIsLoading(value: true);

      // 2. save time and player color for both players
      await gameProvider
          .setGameTime(
        newSavedWhitesTime: whiteTimeInMenutes.toString(),
        newSavedBlacksTime: blackTimeInMenutes.toString(),
      )
          .whenComplete(() {
        //oyun pc ile oynanıyorsa içeri gir
        if (gameProvider.vsComputer) {
          gameProvider.setIsLoading(value: false);
          // 3. navigate to game screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Oyun_ekrani()),
          );
        } else {
          // search for players
        }
      });
    } else {
      // not custom time
      // check if its incremental time
      // get the value after the + sign
      print(widget.gameTime);
      final String incrementalTime = "999";

      // get the value before the + sign
      final String gameTime = "999";

      // check if incremental is equal to 0
      if (incrementalTime != '0') {
        // save the incremental value
        gameProvider.setIncrementalValue(value: int.parse(incrementalTime));
      }

      gameProvider.setIsLoading(value: true);

      await gameProvider
          .setGameTime(
        newSavedWhitesTime: gameTime,
        newSavedBlacksTime: gameTime,
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
                      print("aaaa");
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
}
