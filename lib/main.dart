import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

// ================= MY APP =================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(fontFamily: "Roboto"),
      home: SplashScreen(),
    );
  }
}

// ================= SPLASH SCREEN =================
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AudioPlayer bgmPlayer;

  @override
  void initState() {
    super.initState();

    // Background Music
    bgmPlayer = AudioPlayer();
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
    bgmPlayer.play(AssetSource("bgm.mp3")); // ✅ lowercase name

    // Animation
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);

    // Move to Home after 3 sec
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(bgmPlayer: bgmPlayer), // ✅ pass bgmPlayer
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Transform.scale(
            scale: _animation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logo.png", width: 120, height: 120),
                SizedBox(height: 10),
                Text(
                  "Tic Tac Toe",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
SCREEN =================
class HomeScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  HomeScreen({required this.bgmPlayer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int playerWins = 0;
  int computerWins = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  void loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      playerWins = prefs.getInt("playerWins") ?? 0;
      computerWins = prefs.getInt("computerWins") ?? 0;
      draws = prefs.getInt("draws") ?? 0;
    });
  }

  void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => loadScores());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tic Tac Toe",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              SizedBox(height: 20),
              Text(
                "Player: $playerWins  |  Computer: $computerWins  |  Draws: $draws",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () => navigateTo(
                      context, ModeSelectionScreen(bgmPlayer: widget.bgmPlayer)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.greenAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("▶ Play Game",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => navigateTo(
                      context, TwoPlayerSymbolSelectionScreen()),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.blueAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("👥 2 Player Game",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => navigateTo(
                      context, SettingsScreen(bgmPlayer: widget.bgmPlayer)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.orangeAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("⚙ Settings",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => navigateTo(context, AboutScreen()),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.purpleAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("🏆 About",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= MODE SELECTION SCREEN =================
class ModeSelectionScreen extends StatelessWidget {
  final AudioPlayer bgmPlayer;
  ModeSelectionScreen({required this.bgmPlayer});

  void startGame(BuildContext context, String difficulty) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => SymbolSelectionScreen(
                vsComputer: true, difficulty: difficulty, bgmPlayer: bgmPlayer)));
  }

  @override
  Widget build(BuildContext context) {
    final List<String> modes = ["Easy", "Medium", "Hard", "Expert"];

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Difficulty"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: modes
              .map((mode) => Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () => startGame(context, mode),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.purpleAccent.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(mode, style: TextStyle(fontSize: 18)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ================= SYMBOL SELECTION SCREEN =================
class SymbolSelectionScreen extends StatelessWidget {
  final bool vsComputer;
  final String? difficulty;
  final AudioPlayer bgmPlayer;
  SymbolSelectionScreen(
      {required this.vsComputer, this.difficulty, required this.bgmPlayer});

  void startGame(BuildContext context, String playerSymbol) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => GameScreen(
                  vsComputer: vsComputer,
                  playerSymbol: playerSymbol,
                  difficulty: difficulty,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vsComputer
                    ? "Choose Your Symbol (Vs Computer)"
                    : "Player 1: Choose Your Symbol",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => startGame(context, "X"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(120, 120),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text("X", style: TextStyle(fontSize: 48))),
                  SizedBox(width: 40),
                  ElevatedButton(
                      onPressed: () => startGame(context, "O"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: Size(120, 120),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text("O", style: TextStyle(fontSize: 48))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 2 PLAYER SYMBOL SELECTION =================
class TwoPlayerSymbolSelectionScreen extends StatelessWidget {
  void startGame(BuildContext context, String playerSymbol) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                GameScreen(vsComputer: false, playerSymbol: playerSymbol)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Player 1: Choose Your Symbol",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => startGame(context, "X"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(120, 120),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text("X", style: TextStyle(fontSize: 48))),
                  SizedBox(width: 40),
                  ElevatedButton(
                      onPressed: () => startGame(context, "O"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: Size(120, 120),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text("O", style: TextStyle(fontSize: 48))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SETTINGS SCREEN =================
class SettingsScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  SettingsScreen({required this.bgmPlayer});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool bgmOn = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bgmOn = prefs.getBool("bgmOn") ?? true;
    });
    if (!bgmOn) widget.bgmPlayer.pause();
  }

  void toggleBgm(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bgmOn = value;
    });
    await prefs.setBool("bgmOn", bgmOn);
    if (bgmOn) {
      widget.bgmPlayer.resume();
    } else {
      widget.bgmPlayer.pause();
    }
  }

  void resetScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("playerWins", 0);
    await prefs.setInt("computerWins", 0);
    await prefs.setInt("draws", 0);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Scores Reset!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.deepPurple),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Background Music",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              value: bgmOn,
              onChanged: toggleBgm,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetScores,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50)),
              child: Text("Reset Scores",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ABOUT SCREEN =================
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About"), backgroundColor: Colors.deepPurple),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
          child: Text(
            "Tic Tac Toe Game\n\nDeveloped by Piyush Sharma\n\nEnjoy playing!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

// ================= FULL GAME SCREEN =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String symbol;
  final String difficulty;

  GameScreen({
    required this.vsComputer,
    required this.symbol,
    required this.difficulty,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  List<String> board = List.filled(9, '');
  String currentPlayer = "X";
  String? winner;
  int moveCount = 0;

  late String playerSymbol;
  late String computerSymbol;

  // Audio players
  AudioPlayer tapPlayer = AudioPlayer();
  AudioPlayer celebrationPlayer = AudioPlayer();

  // Animation
  late AnimationController _winnerController;
  late Animation<double> _winnerAnimation;

  @override
  void initState() {
    super.initState();
    playerSymbol = widget.symbol;
    computerSymbol = (playerSymbol == "X") ? "O" : "X";

    _winnerController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _winnerAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(
      parent: _winnerController,
      curve: Curves.easeInOut,
    ));

    // Computer first move if player chose O
    if (widget.vsComputer && playerSymbol == "O") {
      Future.delayed(Duration(milliseconds: 500 + Random().nextInt(200)),
          computerMove);
    }
  }

  @override
  void dispose() {
    _winnerController.dispose();
    super.dispose();
  }

  void playTapSound() async {
    await tapPlayer.play(AssetSource("Tap.mp3"));
  }

  void playCelebrationSound() async {
    await celebrationPlayer.play(AssetSource("Celebration.mp3"));
  }

  void handleTap(int index) async {
    if (board[index] != '' || winner != null) return;

    if (widget.vsComputer && currentPlayer != playerSymbol) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Wait for your turn!")));
      return;
    }

    setState(() {
      board[index] = currentPlayer;
      moveCount++;
      playTapSound();
      checkWinner();
      if (winner == null) switchTurn();
    });

    if (widget.vsComputer && currentPlayer == computerSymbol && winner == null) {
      Future.delayed(Duration(milliseconds: 400 + Random().nextInt(300)),
          computerMove);
    }
  }

  void switchTurn() {
    currentPlayer = (currentPlayer == "X") ? "O" : "X";
  }

  void checkWinner() async {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];

      if (a != '' && a == b && b == c) {
        setState(() {
          winner = a;
          _winnerController.repeat(reverse: true);
          playCelebrationSound();
        });
        await updateScores();
        return;
      }
    }

    if (moveCount == 9 && winner == null) {
      setState(() {
        winner = "Draw";
        playCelebrationSound();
      });
      await updateScores();
    }
  }

  Future<void> updateScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (winner == playerSymbol) {
      prefs.setInt("playerWins", (prefs.getInt("playerWins") ?? 0) + 1);
    } else if (winner == computerSymbol) {
      prefs.setInt("computerWins", (prefs.getInt("computerWins") ?? 0) + 1);
    } else if (winner == "Draw") {
      prefs.setInt("draws", (prefs.getInt("draws") ?? 0) + 1);
    }
  }

  void computerMove() {
    int move;
    if (widget.difficulty == "Easy") {
      move = getRandomMove();
    } else if (widget.difficulty == "Medium") {
      move = (Random().nextBool()) ? getBestMove() : getRandomMove();
    } else {
      move = getBestMove();
    }

    setState(() {
      board[move] = computerSymbol;
      moveCount++;
      playTapSound();
      checkWinner();
      if (winner == null) switchTurn();
    });
  }

  int getRandomMove() {
    List<int> available = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') available.add(i);
    }
    return available[Random().nextInt(available.length)];
  }

  int getBestMove() {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = computerSymbol;
        int score = minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int minimax(List<String> newBoard, int depth, bool isMaximizing) {
    String result = evaluateBoard();
    if (result != '') {
      if (result == computerSymbol) return 10 - depth;
      if (result == playerSymbol) return depth - 10;
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = computerSymbol;
          int score = minimax(newBoard, depth + 1, false);
          newBoard[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = playerSymbol;
          int score = minimax(newBoard, depth + 1, true);
          newBoard[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String evaluateBoard() {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];
      if (a != '' && a == b && b == c) return a;
    }

    if (!board.contains('')) return "Draw";
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic Tac Toe")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _winnerController,
            builder: (context, child) {
              return Transform.scale(
                scale: winner != null ? _winnerAnimation.value : 1.0,
                child: Text(
                  winner == null
                      ? "Turn: $currentPlayer"
                      : (winner == "Draw"
                          ? "It's a Draw!"
                          : "Winner: $winner"),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: winner == null
                        ? (currentPlayer == "X" ? Colors.red : Colors.green)
                        : Colors.yellowAccent,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            itemCount: 9,
            padding: EdgeInsets.symmetric(horizontal: 20),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => handleTap(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 3)
                    ],
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: board[index] == "X" ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                board = List.filled(9, '');
                currentPlayer = "X";
                winner = null;
                moveCount = 0;
              });

              if (widget.vsComputer && playerSymbol == "O") {
                Future.delayed(
                    Duration(milliseconds: 500 + Random().nextInt(200)),
                    computerMove);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(150, 50),
              backgroundColor: Colors.deepPurpleAccent,
            ),
            child: Text("Restart",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
