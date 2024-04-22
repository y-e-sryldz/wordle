import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:squares/squares.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:stockfish/stockfish.dart';
import 'package:uuid/uuid.dart';
import 'package:wordle/Constants.dart';
import 'package:wordle/models/game_model.dart';
import 'package:wordle/models/user_model.dart';

class GameProvider extends ChangeNotifier {
  late bishop.Game _game = bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = SquaresState.initial(0);
  bool _aiThinking = false;
  bool _flipBoard = false;
  bool _vsComputer = false;
  bool _isLoading = false;
  bool _playWhitesTimer = true;
  bool _playBlacksTimer = true;
  int _gameLevel = 1;
  int _incrementalValue = 0;
  int _player = Squares.white;
  Timer? _whitesTimer;
  Timer? _blacksTimer;
  int _whitesScore = 0;
  int _blacksSCore = 0;
  String _gameId = '';

  String get gameId => _gameId;

  String _whitesTime = '';
  String _blacksTime = '';

  // saved time
  String _savedWhitesTime = '';
  String _savedBlacksTime = '';

  bool get playWhitesTimer => _playWhitesTimer;
  bool get playBlacksTimer => _playBlacksTimer;

  int get whitesScore => _whitesScore;
  int get blacksScore => _blacksSCore;

  Timer? get whitesTimer => _whitesTimer;
  Timer? get blacksTimer => _blacksTimer;

  bishop.Game get game => _game;
  SquaresState get state => _state;
  bool get aiThinking => _aiThinking;
  bool get flipBoard => _flipBoard;

  int get gameLevel => _gameLevel;

  int get incrementalValue => _incrementalValue;
  int get player => _player;

  String get whitesTime => _whitesTime;
  String get blacksTime => _blacksTime;

  String get savedWhitesTime => _savedWhitesTime;
  String get savedBlacksTime => _savedBlacksTime;

  // get method
  bool get vsComputer => _vsComputer;
  bool get isLoading => _isLoading;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // set play whitesTimer
  Future<void> setPlayWhitesTimer({required bool value}) async {
    _playWhitesTimer = value;
    notifyListeners();
  }

  // set play blacksTimer
  Future<void> setPlayBlactsTimer({required bool value}) async {
    _playBlacksTimer = value;
    notifyListeners();
  }

  // get position fen
  getPositionFen() {
    return game.fen;
  }

  // reset game
  void resetGame({required bool newGame}) {
    if (newGame) {
      // check if the player was white in the previous game
      // change the player
      if (_player == Squares.white) {
        _player = Squares.black;
      } else {
        _player = Squares.white;
      }
      notifyListeners();
    }
    // reset game
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);
  }

  // make squre move
  bool makeSquaresMove(Move move) {
    bool result = game.makeSquaresMove(move);
    notifyListeners();
    return result;
  }

  // make squre move
  bool makeStringMove(String bestMove) {
    bool result = game.makeMoveString(bestMove);
    notifyListeners();
    return result;
  }

  // set sqaures state
  Future<void> setSquaresState() async {
    _state = game.squaresState(player);
    notifyListeners();
  }

  // make random move
  void makeRandomMove() {
    _game.makeRandomMove();
    notifyListeners();
  }

  void flipTheBoard() {
    _flipBoard = !_flipBoard;
    notifyListeners();
  }

  void setAiThinking(bool value) {
    _aiThinking = value;
    notifyListeners();
  }

  // set incremental value
  void setIncrementalValue({required int value}) {
    _incrementalValue = value;
    notifyListeners();
  }

  // set vs computer
  void setVsComputer({required bool value}) {
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // set game time
  Future<void> setGameTime({
    required String newSavedWhitesTime,
    required String newSavedBlacksTime,
  }) async {
    // save the times
    _savedWhitesTime = newSavedWhitesTime;
    _savedBlacksTime = newSavedBlacksTime;
    print(_savedWhitesTime);
    print(_savedBlacksTime);
    notifyListeners();
    // set times
    setWhitesTime(_savedWhitesTime);
    setBlacksTime(_savedBlacksTime);
  }

  void setWhitesTime(String time) {
    _whitesTime = time;
    notifyListeners();
  }

  void setBlacksTime(String time) {
    _blacksTime = time;
    notifyListeners();
  }

  // game over dialog
  void gameOverDialog({
    required BuildContext context,
    Stockfish? stockfish,
    required bool timeOut,
    required bool whiteWon,
    required Function onNewGame,
  }) {
    // stop stockfish engine

    String resultsToShow = '';
    int whitesScoresToShow = 0;
    int blacksSCoresToShow = 0;

    // check if its a timeOut
    if (timeOut) {
      // check who has won and increment the results accordingly
      if (whiteWon) {
        resultsToShow = 'White won on time';
        whitesScoresToShow = _whitesScore + 1;
      } else {
        resultsToShow = 'Black won on time';
        blacksSCoresToShow = _blacksSCore + 1;
      }
    } else {
      // its not a timeOut
      resultsToShow = game.result!.readable;

      if (game.drawn) {
        // game is a draw
        String whitesResults = game.result!.scoreString.split('-').first;
        String blacksResults = game.result!.scoreString.split('-').last;
        whitesScoresToShow = _whitesScore += int.parse(whitesResults);
        blacksSCoresToShow = _blacksSCore += int.parse(blacksResults);
      } else if (game.winner == 0) {
        // meaning white is the winner
        String whitesResults = game.result!.scoreString.split('-').first;
        whitesScoresToShow = _whitesScore += int.parse(whitesResults);
      } else if (game.winner == 1) {
        // meaning black is the winner
        String blacksResults = game.result!.scoreString.split('-').last;
        blacksSCoresToShow = _blacksSCore += int.parse(blacksResults);
      } else if (game.stalemate) {
        whitesScoresToShow = whitesScore;
        blacksSCoresToShow = blacksScore;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Over\n $whitesScoresToShow - $blacksSCoresToShow',
          textAlign: TextAlign.center,
        ),
        content: Text(
          resultsToShow,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // navigate to home screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                Constants.homeScreen,
                (route) => false,
              );
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // reset the game
            },
            child: const Text(
              'New Game',
            ),
          ),
        ],
      ),
    );
  }

  String _waitingText = '';

  String get waitingText => _waitingText;

  setWaitingText() {
    _waitingText = '';
    notifyListeners();
  }

  // search for player
  Future searchPlayer({
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      // mevcut tüm oyunları al
      final availableGames =
          await firebaseFirestore.collection(Constants.availableGames).get();

      //mevcut oyun olup olmadığını kontrol edin
      if (availableGames.docs.isNotEmpty) {
        final List<DocumentSnapshot> gamesList = availableGames.docs
            .where((element) => element[Constants.isPlaying] == false)
            .toList();

        // isPlaying == false olan herhangi bir oyun olup olmadığını kontrol edin
        if (gamesList.isEmpty) {
          _waitingText = Constants.searchingPlayerText;
          notifyListeners();
          // create a new game
          createNewGameInFireStore(
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        } else {
          _waitingText = Constants.joiningGameText;
          notifyListeners();
          // join a game
          joinGame(
            game: gamesList.first,
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        }
      } else {
        _waitingText = Constants.searchingPlayerText;
        notifyListeners();
        // elimizde herhangi bir oyun yok - bir oyun oluştur
        createNewGameInFireStore(
          userModel: userModel,
          onSuccess: onSuccess,
          onFail: onFail,
        );
      }
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  // oyun oluştur
  void createNewGameInFireStore({
    required UserModel userModel,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    // create a game id
    _gameId = const Uuid().v4();
    notifyListeners();

    try {
      await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .set({
        Constants.uid: '',
        Constants.name: '',
        Constants.ikinci_kazanan: false,
        Constants.userRating: 1200,
        Constants.gameCreatorUid: userModel.uid,
        Constants.gameCreatorName: userModel.name,
        Constants.birinci_kazanan: false,
        Constants.gameCreatorRating: userModel.playerRating,
        Constants.isPlaying: false,
        Constants.gameId: gameId,
        Constants.dateCreated: DateTime.now().microsecondsSinceEpoch.toString(),
        Constants.blacksTime: _savedBlacksTime.toString(),
        Constants.whitesTime: '',
      });

      onSuccess();
    } on FirebaseException catch (e) {
      onFail(e.toString());
    }
  }

  String _gameCreatorUid = '';
  String _gameCreatorName = '';
  String _gameCreatorPhoto = '';
  int _gameCreatorRating = 1200;
  String _userId = '';
  String _userName = '';
  String _userPhoto = '';
  int _userRating = 1200;

  String get gameCreatorUid => _gameCreatorUid;
  String get gameCreatorName => _gameCreatorName;
  String get gameCreatorPhoto => _gameCreatorPhoto;
  int get gameCreatorRating => _gameCreatorRating;
  String get userId => _userId;
  String get userName => _userName;
  String get userPhoto => _userPhoto;
  int get userRating => _userRating;

  // join game
  void joinGame({
    required DocumentSnapshot<Object?> game,
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      // yarattığımız oyunu edinin
      final myGame = await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .get();

      // Katıldığımız oyundan veri al
      _gameCreatorUid = game[Constants.gameCreatorUid];
      _gameCreatorName = game[Constants.gameCreatorName];
      _gameCreatorPhoto = game[Constants.birinci_kazanan];
      _gameCreatorRating = game[Constants.gameCreatorRating];
      _userId = userModel.uid;
      _userName = userModel.name;
      _userPhoto = userModel.image;
      _userRating = userModel.playerRating;
      _gameId = game[Constants.gameId];
      notifyListeners();

      if (myGame.exists) {
        // Başka bir oyuna katılacağımız için oluşturduğunuz oyunu silin
        await myGame.reference.delete();
      }

      // gameModel'i başlat
      final gameModel = GameModel(
        gameId: gameId,
        gameCreatorUid: _gameCreatorUid,
        userId: userId,
        positonFen: getPositionFen(),
        winnerId: '',
        whitesTime: game[Constants.whitesTime],
        blacksTime: game[Constants.blacksTime],
        whitsCurrentMove: '',
        blacksCurrentMove: '',
        boardState: state.board.flipped().toString(),
        playState: PlayState.ourTurn.name.toString(),
        isWhitesTurn: true,
        isGameOver: false,
        squareState: state.player,
        moves: state.moves.toList(),
      );

      // fireStore'da bir oyun kumandası dizini oluşturun
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .set(gameModel.toMap());

      // fireStore'da yeni bir oyun dizini oluşturun
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .set({
        Constants.gameCreatorUid: gameCreatorUid,
        Constants.gameCreatorName: gameCreatorName,
        Constants.birinci_kazanan: gameCreatorPhoto,
        Constants.gameCreatorRating: gameCreatorRating,
        Constants.userId: userId,
        Constants.userName: userName,
        Constants.userImage: userPhoto,
        Constants.userRating: userRating,
        Constants.isPlaying: true,
        Constants.dateCreated: DateTime.now().microsecondsSinceEpoch.toString(),
        Constants.gameScore: '0-0',
      });

      // Katıldığımız oyunun verilerine göre oyun ayarlarını güncelleyin
      await setGameDataAndSettings(game: game, userModel: userModel);

      onSuccess();
    } on FirebaseException catch (e) {
      onFail(e.toString());
    }
  }

  StreamSubscription? isPlayingStreamSubScription;

  // chech if the other player has joined
  void checkIfOpponentJoined({
    required UserModel userModel,
    required Function() onSuccess,
  }) async {
    // Oyuncu katılmışsa firestore akışını gerçekleştirin
    isPlayingStreamSubScription = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(userModel.uid)
        .snapshots()
        .listen((event) async {
      // oyunun mevcut olup olmadığını kontrol edin
      if (event.exists) {
        final DocumentSnapshot game = event;

        // chech if itsPlaying == true
        if (game[Constants.isPlaying]) {
          isPlayingStreamSubScription!.cancel();
          await Future.delayed(const Duration(milliseconds: 100));
          // Katıldığımız oyundan veri al
          _gameCreatorUid = game[Constants.gameCreatorUid];
          _gameCreatorName = game[Constants.gameCreatorName];
          _gameCreatorPhoto = game[Constants.birinci_kazanan];
          _userId = game[Constants.uid];
          _userName = game[Constants.name];
          _userPhoto = game[Constants.ikinci_kazanan];

          notifyListeners();

          onSuccess();
        }
      }
    });
  }

  // oyun verilerini ve ayarlarını belirle
  Future<void> setGameDataAndSettings({
    required DocumentSnapshot<Object?> game,
    required UserModel userModel,
  }) async {
    // get reference to the game we are joining
    final opponentsGame = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(game[Constants.gameCreatorUid]);

    // FireStore'da oluşturulan oyunu güncelleyin
    await opponentsGame.update({
      Constants.isPlaying: true,
      Constants.uid: userModel.uid,
      Constants.name: userModel.name,
      Constants.ikinci_kazanan: userModel.image,
      Constants.userRating: userModel.playerRating,
      Constants.whitesTime: _savedWhitesTime.toString(),
    });

    notifyListeners();
  }

}
