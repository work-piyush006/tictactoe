// ================= 10/10 PROFESSIONAL TIC TAC TOE PART 1 =================
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(TicTacToePro());
}

// ================== MAIN APP ==================
class TicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tic Tac Toe",
      theme: ThemeData(fontFamily: "Roboto"),
      home: SplashScreen(),
    );
  }
}

// ================== SPLASH SCREEN ==================
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
    bgmPlayer.play(AssetSource("assets/bgm.mp3"));

    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
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
                end: Alignment.bottomRight)),
        child: Center(
          child: Transform.scale(
            scale: _animation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logo.png", width: 120, height: 120),
                SizedBox(height: 15),
                Text(
                  "Tic Tac Toe",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
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

// ================== HOME SCREEN ==================
class HomeScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  HomeScreen({required this.bgmPlayer});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int playerWins = 0, computerWins = 0, draws = 0;

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

  void navigateTo(Widget screen) {
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
                end: Alignment.bottomRight)),
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
              SizedBox(height: 25),
              Text(
                "Player: $playerWins  |  Computer: $computerWins  |  Draws: $draws",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => navigateTo(ModeSelectionScreen(
                  bgmPlayer: widget.bgmPlayer,
                )),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.greenAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  "▶ Play Game",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => navigateTo(TwoPlayerSymbolSelectionScreen()),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.blueAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  "👥 2 Player Game",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => navigateTo(SettingsScreen(
                  bgmPlayer: widget.bgmPlayer,
                )),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.orangeAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  "⚙ Settings",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => navigateTo(AboutScreen()),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.purpleAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  "🏆 About",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== MODE SELECTION ==================
class ModeSelectionScreen extends StatelessWidget {
  final AudioPlayer bgmPlayer;
  ModeSelectionScreen({required this.bgmPlayer});

  void startGame(BuildContext context, String difficulty) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => SymbolSelectionScreen(
                  vsComputer: true,
                  difficulty: difficulty,
                  bgmPlayer: bgmPlayer,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final List<String> modes = ["Easy", "Medium", "Hard", "Expert"];
    return Scaffold(
      appBar: AppBar(title: Text("Select Difficulty"), backgroundColor: Colors.deepPurple),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: modes.map((mode) => Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            child: ElevatedButton(
              onPressed: () => startGame(context, mode),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: Colors.purpleAccent.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(mode, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// ================= PART 1 – SYMBOL SELECTION ==================
class SymbolSelectionScreen extends StatelessWidget {
  final bool vsComputer;
  final String? difficulty;
  final AudioPlayer bgmPlayer;

  SymbolSelectionScreen({required this.vsComputer, this.difficulty, required this.bgmPlayer});

  void startGame(BuildContext context, String playerSymbol) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => GameScreen(
                  vsComputer: vsComputer,
                  playerSymbol: playerSymbol,
                  difficulty: difficulty,
                  bgmPlayer: bgmPlayer,
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
                vsComputer ? "Choose Your Symbol (Vs Computer)" : "Player 1: Choose Your Symbol",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: Text("X", style: TextStyle(fontSize: 48))),
                  SizedBox(width: 40),
                  ElevatedButton(
                      onPressed: () => startGame(context, "O"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: Size(120, 120),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
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
// ================= 10/10 PROFESSIONAL TIC TAC TOE PART 2 =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;
  final AudioPlayer? bgmPlayer;

  GameScreen({required this.vsComputer, required this.playerSymbol, this.difficulty, this.bgmPlayer});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> board;
  late String currentTurn;
  bool gameOver = false;
  String winner = "";
  late AudioPlayer sfxPlayer;
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    board = List.generate(9, (_) => "");
    currentTurn = "X";
    sfxPlayer = AudioPlayer();
    confettiController = ConfettiController(duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void playSfx(String file) {
    sfxPlayer.play(AssetSource("assets/$file"));
  }

  void makeMove(int index) {
    if (board[index] != "" || gameOver) return;
    setState(() {
      board[index] = currentTurn;
      playSfx("Tap.mp3");
      checkWinner();
      if (!gameOver) {
        currentTurn = currentTurn == "X" ? "O" : "X";
        if (widget.vsComputer && currentTurn != widget.playerSymbol) {
          Future.delayed(Duration(milliseconds: 500), () {
            computerMove();
          });
        }
      }
    });
  }

  void computerMove() {
    int move = getBestMove();
    makeMove(move);
  }

  int getBestMove() {
    List<int> empty = [];
    for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);

    if (widget.difficulty == "Easy") return empty[Random().nextInt(empty.length)];
    if (widget.difficulty == "Medium") if (Random().nextBool()) return empty[Random().nextInt(empty.length)];

    int bestScore = -1000;
    int bestMove = empty[0];
    for (int i in empty) {
      board[i] = currentTurn;
      int score = minimax(0, false);
      board[i] = "";
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  int minimax(int depth, bool isMaximizing) {
    String? result = checkWinnerMinimax();
    if (result != null) {
      if (result == widget.playerSymbol) return -10 + depth;
      if (result == (widget.playerSymbol == "X" ? "O" : "X")) return 10 - depth;
      if (result == "Draw") return 0;
    }

    List<int> empty = [];
    for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i in empty) {
        board[i] = currentTurn;
        int score = minimax(depth + 1, false);
        board[i] = "";
        bestScore = max(score, bestScore);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      String opponent = currentTurn == "X" ? "O" : "X";
      for (int i in empty) {
        board[i] = opponent;
        int score = minimax(depth + 1, true);
        board[i] = "";
        bestScore = min(score, bestScore);
      }
      return bestScore;
    }
  }

  String? checkWinnerMinimax() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] != "" &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }
    if (!board.contains("")) return "Draw";
    return null;
  }

  void checkWinner() {
    String? result = checkWinnerMinimax();
    if (result != null) {
      setState(() {
        gameOver = true;
        winner = result;
      });
      if (winner != "Draw") confettiController.play();
      playSfx(winner == "Draw" ? "draw.mp3" : "Celebration.mp3");
      updateScore();
      Future.delayed(Duration(seconds: 2), resetBoard);
    }
  }

  void updateScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (winner == widget.playerSymbol) {
      int wins = prefs.getInt("playerWins") ?? 0;
      prefs.setInt("playerWins", wins + 1);
    } else if (winner == (widget.playerSymbol == "X" ? "O" : "X")) {
      int loses = prefs.getInt("computerWins") ?? 0;
      prefs.setInt("computerWins", loses + 1);
    } else if (winner == "Draw") {
      int draws = prefs.getInt("draws") ?? 0;
      prefs.setInt("draws", draws + 1);
    }
  }

  void resetBoard() {
    setState(() {
      board = List.generate(9, (_) => "");
      gameOver = false;
      winner = "";
      currentTurn = "X";
    });
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => makeMove(index),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white70, width: 2)),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
                fontSize: 64,
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
                  winner == ""
                      ? "Turn: $currentTurn"
                      : winner == "Draw"
                          ? "Draw!"
                          : "$winner Wins!",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 320,
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemCount: 9,
                      itemBuilder: (_, index) => buildCell(index)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: resetBoard,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        minimumSize: Size(180, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text("Reset Board",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)))
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.yellow, Colors.red, Colors.green, Colors.blue],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
    );
  }
}
// ================= 10/10 PROFESSIONAL TIC TAC TOE PART 3 =================

// ================= SETTINGS SCREEN ==================
class SettingsScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  SettingsScreen({required this.bgmPlayer});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      musicOn = prefs.getBool("musicOn") ?? true;
    });
    if (!musicOn) widget.bgmPlayer.stop();
  }

  void toggleMusic(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      musicOn = value;
      prefs.setBool("musicOn", value);
      if (musicOn)
        widget.bgmPlayer.resume();
      else
        widget.bgmPlayer.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.deepPurple),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
          child: SwitchListTile(
            title: Text("Background Music", style: TextStyle(color: Colors.white, fontSize: 22)),
            value: musicOn,
            onChanged: toggleMusic,
            activeColor: Colors.greenAccent,
          ),
        ),
      ),
    );
  }
}

// ================= ABOUT SCREEN ==================
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About"), backgroundColor: Colors.deepPurple),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Tic Tac Toe \n\nVersion 6.1.0.0\n\nDeveloped by  PixelPlay\n\nTry To win Against Our Expert AI & ENJOY PLAYING !",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= TWO PLAYER GAME SCREEN ==================
class TwoPlayerGameScreen extends StatefulWidget {
  final String player1Symbol;
  final String player2Symbol;

  TwoPlayerGameScreen({required this.player1Symbol, required this.player2Symbol});

  @override
  _TwoPlayerGameScreenState createState() => _TwoPlayerGameScreenState();
}

class _TwoPlayerGameScreenState extends State<TwoPlayerGameScreen> {
  late List<String> board;
  late String currentTurn;
  bool gameOver = false;
  String winner = "";
  late AudioPlayer sfxPlayer;
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    board = List.generate(9, (_) => "");
    currentTurn = widget.player1Symbol;
    sfxPlayer = AudioPlayer();
    confettiController = ConfettiController(duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void playSfx(String file) {
    sfxPlayer.play(AssetSource("assets/$file"));
  }

  void makeMove(int index) {
    if (board[index] != "" || gameOver) return;
    setState(() {
      board[index] = currentTurn;
      playSfx("Tap.mp3");
      checkWinner();
      if (!gameOver) {
        currentTurn = currentTurn == widget.player1Symbol
            ? widget.player2Symbol
            : widget.player1Symbol;
      }
    });
  }

  String? checkWinnerMinimax() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] != "" &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }
    if (!board.contains("")) return "Draw";
    return null;
  }

  void checkWinner() {
    String? result = checkWinnerMinimax();
    if (result != null) {
      setState(() {
        gameOver = true;
        winner = result;
      });
      if (winner != "Draw") confettiController.play();
      playSfx(winner == "Draw" ? "draw.mp3" : "Celebration.mp3");
      Future.delayed(Duration(seconds: 2), resetBoard);
    }
  }

  void resetBoard() {
    setState(() {
      board = List.generate(9, (_) => "");
      gameOver = false;
      winner = "";
      currentTurn = widget.player1Symbol;
    });
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => makeMove(index),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white70, width: 2)),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: board[index] == widget.player1Symbol ? Colors.red : Colors.blue),
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
                  winner == ""
                      ? "Turn: $currentTurn"
                      : winner == "Draw"
                          ? "Draw!"
                          : "$winner Wins!",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                Container(
                  width: 320,
                  height: 320,
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemCount: 9,
                      itemBuilder: (_, index) => buildCell(index)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: resetBoard,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        minimumSize: Size(180, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text("Reset Board",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)))
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.yellow, Colors.red, Colors.green, Colors.blue],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
    );
  }
}
