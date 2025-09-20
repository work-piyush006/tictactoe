import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(MyApp());
}

// ================= MY APP =================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe Pro',
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
    bgmPlayer.play(AssetSource("bgm.mp3"));

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
            builder: (_) => HomeScreen(bgmPlayer: bgmPlayer),
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
                  "Tic Tac Toe Pro",
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
                "Tic Tac Toe Pro",
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
            "Tic Tac Toe Game Pro\n\nDeveloped by Piyush Sharma\n\nEnjoy playing!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
// ================= GAME SCREEN =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;
  GameScreen(
      {required this.vsComputer, required this.playerSymbol, this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, "");
  bool playerTurn = true;
  late String computerSymbol;
  late AudioPlayer sfxPlayer;
  late ConfettiController confettiController;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    computerSymbol = widget.playerSymbol == "X" ? "O" : "X";
    sfxPlayer = AudioPlayer();
    confettiController =
        ConfettiController(duration: Duration(seconds: 2));
  }

  void playSfx(String file) {
    sfxPlayer.play(AssetSource(file));
  }

  void resetBoard() {
    setState(() {
      board = List.filled(9, "");
      playerTurn = true;
      gameOver = false;
    });
  }

  void makeMove(int index) async {
    if (board[index] != "" || gameOver) return;

    setState(() {
      board[index] = playerTurn ? widget.playerSymbol : computerSymbol;
      playerTurn = !playerTurn;
    });
    playSfx("tap.mp3");

    String winner = checkWinner();
    if (winner != "") {
      handleWin(winner);
      return;
    }

    if (widget.vsComputer && !playerTurn && !gameOver) {
      await Future.delayed(Duration(milliseconds: 500));
      int aiMove = getBestMove();
      makeMove(aiMove);
    }
  }

  void handleWin(String winner) async {
    setState(() => gameOver = true);
    if (winner == "Draw") {
      playSfx("draw.mp3");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("It's a Draw!")));
      await saveScore(draw: true);
    } else {
      playSfx("Celebration.mp3");
      confettiController.play();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$winner Wins!")));
      await saveScore(playerWin: winner == widget.playerSymbol);
    }
  }

  Future<void> saveScore({bool playerWin = false, bool draw = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int playerWins = prefs.getInt("playerWins") ?? 0;
    int computerWins = prefs.getInt("computerWins") ?? 0;
    int draws = prefs.getInt("draws") ?? 0;

    if (draw) draws++;
    else if (playerWin) playerWins++;
    else computerWins++;

    await prefs.setInt("playerWins", playerWins);
    await prefs.setInt("computerWins", computerWins);
    await prefs.setInt("draws", draws);
  }

  String checkWinner() {
    List<List<int>> lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var line in lines) {
      if (board[line[0]] != "" &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        return board[line[0]];
      }
    }

    if (!board.contains("")) return "Draw";
    return "";
  }

  int getBestMove() {
    if (widget.difficulty == "Easy") {
      // Random move
      List<int> empty = [];
      for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);
      return empty[Random().nextInt(empty.length)];
    } else {
      // Minimax for Medium, Hard, Expert
      return minimax(board, computerSymbol).index;
    }
  }

  Move minimax(List<String> newBoard, String currentPlayer) {
    String winner = checkWinnerBoard(newBoard);
    if (winner == widget.playerSymbol) return Move(score: -10);
    if (winner == computerSymbol) return Move(score: 10);
    if (!newBoard.contains("")) return Move(score: 0);

    List<Move> moves = [];

    for (int i = 0; i < 9; i++) {
      if (newBoard[i] == "") {
        String backup = newBoard[i];
        newBoard[i] = currentPlayer;

        int score = minimax(newBoard,
                currentPlayer == computerSymbol ? widget.playerSymbol : computerSymbol)
            .score;
        moves.add(Move(index: i, score: score));

        newBoard[i] = backup;
      }
    }

    Move bestMove = moves[0];
    if (currentPlayer == computerSymbol) {
      for (var m in moves) if (m.score > bestMove.score) bestMove = m;
    } else {
      for (var m in moves) if (m.score < bestMove.score) bestMove = m;
    }

    return bestMove;
  }

  String checkWinnerBoard(List<String> b) {
    List<List<int>> lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    for (var line in lines) {
      if (b[line[0]] != "" &&
          b[line[0]] == b[line[1]] &&
          b[line[1]] == b[line[2]]) return b[line[0]];
    }
    if (!b.contains("")) return "Draw";
    return "";
  }

  @override
  void dispose() {
    sfxPlayer.dispose();
    confettiController.dispose();
    super.dispose();
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => makeMove(index),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.deepPurple.shade200),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: board[index] == "X" ? Colors.red : Colors.blue),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.vsComputer
                      ? "Vs Computer (${widget.difficulty})"
                      : "2 Player Mode",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 320,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemCount: 9,
                    itemBuilder: (_, i) => buildCell(i),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetBoard,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      minimumSize: Size(180, 50)),
                  child: Text("🔄 Restart",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
              numberOfParticles: 20,
            ),
          )
        ],
      ),
    );
  }
}

class Move {
  final int index;
  final int score;
  Move({this.index = -1, this.score = 0});
}
