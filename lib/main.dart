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

    bgmPlayer = AudioPlayer();
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
    bgmPlayer.play(AssetSource("Bgm.mp3"));

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => HomeScreen(bgmPlayer: bgmPlayer)));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    bgmPlayer.dispose();
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

// ================= HOME SCREEN =================
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

// ================= GAME SCREEN (Expert AI) =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;

  GameScreen({required this.vsComputer, required this.playerSymbol, this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late List<String> board;
  late String currentTurn;
  late String opponentSymbol;
  bool gameOver = false;
  String resultMessage = "";
  final AudioPlayer tapPlayer = AudioPlayer();
  final AudioPlayer celebratePlayer = AudioPlayer();
  List<int> winningLine = [];
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    board = List.filled(9, "");
    currentTurn = "X";
    opponentSymbol = widget.playerSymbol == "X" ? "O" : "X";

    _tapController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _tapAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    if (widget.vsComputer && widget.playerSymbol == "O") {
      Future.delayed(Duration(milliseconds: 400), () => computerMove());
    }
  }

  void playTap() async {
    await tapPlayer.play(AssetSource("Tap.mp3"), mode: PlayerMode.lowLatency);
    _tapController.forward().then((_) => _tapController.reverse());
  }

  void playCelebrate() async {
    await celebratePlayer.play(AssetSource("Celebration.mp3"));
  }

  void handleTap(int index) {
    if (gameOver) return;
    if (widget.vsComputer && currentTurn != widget.playerSymbol) return;
    if (board[index] != "") return;

    setState(() {
      board[index] = currentTurn;
      playTap();
      checkWinner();
      if (!gameOver) {
        currentTurn = currentTurn == "X" ? "O" : "X";
        if (widget.vsComputer && currentTurn == opponentSymbol) {
          Future.delayed(Duration(milliseconds: 400), () => computerMove());
        }
      }
    });
  }

  void computerMove() {
    if (gameOver) return;

    int move;
    if (widget.difficulty == "Expert") {
      move = getBestMove();
    } else {
      // fallback simple AI for Easy/Medium
      List<int> empty = [];
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") empty.add(i);
      }
      move = empty[DateTime.now().millisecondsSinceEpoch % empty.length];
    }

    handleTap(move);
  }

  int getBestMove() {
    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = opponentSymbol;
        int score = minimax(board, 0, false);
        board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  int minimax(List<String> b, int depth, bool isMaximizing) {
    String? winner = evaluateWinner(b);
    if (winner != null) {
      if (winner == opponentSymbol) return 10 - depth;
      if (winner == widget.playerSymbol) return depth - 10;
      if (winner == "Draw") return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (b[i] == "") {
          b[i] = opponentSymbol;
          int score = minimax(b, depth + 1, false);
          b[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (b[i] == "") {
          b[i] = widget.playerSymbol;
          int score = minimax(b, depth + 1, true);
          b[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String? evaluateWinner(List<String> b) {
    List<List<int>> wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var line in wins) {
      if (b[line[0]] != "" &&
          b[line[0]] == b[line[1]] &&
          b[line[1]] == b[line[2]]) {
        winningLine = line;
        return b[line[0]];
      }
    }
    if (!b.contains("")) return "Draw";
    return null;
  }

  void checkWinner() async {
    String? winner = evaluateWinner(board);
    if (winner != null) {
      gameOver = true;
      if (winner == "Draw") {
        resultMessage = "Draw!";
      } else if (winner == widget.playerSymbol) {
        resultMessage = "You Win!";
        playCelebrate();
      } else {
        resultMessage = "You Lose!";
        playCelebrate();
      }
      updateScores(winner);
      setState(() {});
    }
  }

  void updateScores(String winner) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pw = prefs.getInt("playerWins") ?? 0;
    int cw = prefs.getInt("computerWins") ?? 0;
    int dr = prefs.getInt("draws") ?? 0;

    if (winner == widget.playerSymbol) pw++;
    if (winner == opponentSymbol) cw++;
    if (winner == "Draw") dr++;

    await prefs.setInt("playerWins", pw);
    await prefs.setInt("computerWins", cw);
    await prefs.setInt("draws", dr);
  }

  Widget buildCell(int index) {
    bool highlight = winningLine.contains(index);
    return GestureDetector(
      onTap: () => handleTap(index),
      child: AnimatedScale(
        scale: _tapAnimation.value,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: highlight ? Colors.greenAccent : Colors.transparent),
          child: Center(
            child: Text(
              board[index],
              style: TextStyle(
                  color: board[index] == "X" ? Colors.red : Colors.blue,
                  fontSize: 48,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentTurn = "X";
      winningLine = [];
      gameOver = false;
      resultMessage = "";
      if (widget.vsComputer && widget.playerSymbol == "O") {
        Future.delayed(Duration(milliseconds: 400), () => computerMove());
      }
    });
  }

  @override
  void dispose() {
    _tapController.dispose();
    tapPlayer.dispose();
    celebratePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vsComputer ? "Vs Computer" : "2 Player"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Column(
          children: [
            SizedBox(height: 20),
            if (gameOver)
              Text(resultMessage,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (_, index) => buildCell(index)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: resetGame,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    minimumSize: Size(double.infinity, 50)),
                child: Text("Restart Game",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
