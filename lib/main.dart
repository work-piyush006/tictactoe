// ================= PART 1: IMPORTS & MAIN APP =================
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(TicTacToeApp());
}

// ================== MAIN APP ==================
class TicTacToeApp extends StatelessWidget {
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

// ================= PART 2: SPLASH SCREEN & HOME SCREEN =================

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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int playerWins = 0, computerWins = 0, draws = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadScores();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.bgmPlayer.pause(); // App minimized / background
    } else if (state == AppLifecycleState.resumed) {
      // Agar user ne BGM ON kiya hua tha
      widget.bgmPlayer.resume();
    }
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
// ================= PART 2: MODE & SYMBOL SELECTION =================

// ================== MODE SELECTION SCREEN ==================
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
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () => startGame(context, mode),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 55),
                          backgroundColor: Colors.purpleAccent.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text(mode,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ================== SYMBOL SELECTION SCREEN ==================
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

// ================== 2 PLAYER SYMBOL SELECTION ==================
class TwoPlayerSymbolSelectionScreen extends StatelessWidget {
  void startTwoPlayerGame(BuildContext context, String player1Symbol) {
    String player2Symbol = player1Symbol == "X" ? "O" : "X";
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => TwoPlayerGameScreen(
                  player1Symbol: player1Symbol,
                  player2Symbol: player2Symbol,
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
                "Player 1: Choose Your Symbol",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => startTwoPlayerGame(context, "X"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(120, 120),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text("X", style: TextStyle(fontSize: 48))),
                  SizedBox(width: 40),
                  ElevatedButton(
                      onPressed: () => startTwoPlayerGame(context, "O"),
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
// ================== GAME SCREEN (Vs Computer) ==================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;

  GameScreen({
    required this.vsComputer,
    required this.playerSymbol,
    this.difficulty,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late List<String> board;
  late String currentTurn;
  bool gameOver = false;
  String winner = "";
  late AudioPlayer sfxPlayer;
  int timer = 10;
  Timer? turnTimer;
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = List.generate(9, (_) => "");
    currentTurn = "X";
    sfxPlayer = AudioPlayer();
    confettiController = ConfettiController(duration: Duration(seconds: 2));
    startTurnTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    confettiController.dispose();
    turnTimer?.cancel();
    sfxPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      sfxPlayer.pause(); // minimize / background
    }
  }

  void startTurnTimer() {
    turnTimer?.cancel();
    timer = 10;
    turnTimer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() => timer--);

      if (timer <= 5 && timer > 0) playSfx("Tap.mp3");

      if (timer <= 0) {
        turnTimer?.cancel();
        switchTurn();
      }
    });
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
      if (!gameOver) switchTurn();
    });
  }

  void switchTurn() {
    if (gameOver) return;
    currentTurn = currentTurn == "X" ? "O" : "X";
    startTurnTimer();
    if (widget.vsComputer && currentTurn != widget.playerSymbol) {
      Future.delayed(Duration(milliseconds: 500), () => computerMove());
    }
  }

  void computerMove() {
    if (gameOver) return;

    List<int> empty = [];
    for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);

    int move;
    double chance = Random().nextDouble();

    switch (widget.difficulty) {
      case "Easy":
        move = chance < 0.2 ? findWinningMove(opponent()) : empty[Random().nextInt(empty.length)];
        break;
      case "Medium":
        move = chance < 0.5 ? findWinningMove(opponent()) : empty[Random().nextInt(empty.length)];
        break;
      case "Hard":
        if (chance < 0.8) {
          move = findWinningMove(opponent());
          if (move == -1) move = findBlockingMove(widget.playerSymbol);
          if (move == -1) move = empty[Random().nextInt(empty.length)];
        } else {
          move = empty[Random().nextInt(empty.length)];
        }
        break;
      case "Expert":
        move = findBestMove();
        break;
      default:
        move = empty[Random().nextInt(empty.length)];
    }

    makeMove(move);
  }

  String opponent() => widget.playerSymbol == "X" ? "O" : "X";

  int findWinningMove(String sym) {
    for (var p in [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ]) {
      int count = 0, emptyIndex = -1;
      for (var i in p) {
        if (board[i] == sym) count++;
        if (board[i] == "") emptyIndex = i;
      }
      if (count == 2 && emptyIndex != -1) return emptyIndex;
    }
    return -1;
  }

  int findBlockingMove(String playerSym) => findWinningMove(playerSym);

  int findBestMove() {
    int move = findWinningMove(opponent());
    if (move != -1) return move;
    move = findBlockingMove(widget.playerSymbol);
    if (move != -1) return move;
    if (board[4] == "") return 4;
    List<int> empty = [];
    for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);
    return empty[Random().nextInt(empty.length)];
  }

  void checkWinner() {
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
    for (var p in winPatterns) {
      if (board[p[0]] != "" &&
          board[p[0]] == board[p[1]] &&
          board[p[1]] == board[p[2]]) {
        gameOver = true;
        winner = board[p[0]];
        confettiController.play();
        playSfx("Celebration.mp3");
        turnTimer?.cancel();
        return;
      }
    }
    if (!board.contains("")) {
      gameOver = true;
      winner = "Draw";
      playSfx("draw.mp3");
      turnTimer?.cancel();
    }
  }

  void resetBoard() {
    setState(() {
      board = List.generate(9, (_) => "");
      currentTurn = "X";
      gameOver = false;
      winner = "";
      startTurnTimer();
    });
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => makeMove(index),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.white70, width: 2)),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: board[index] == "X" ? Colors.red : Colors.blue,
            ),
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
                  "$timer ⏳",
                  style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: timer > 5
                          ? Colors.greenAccent
                          : Colors.redAccent),
                ),
                SizedBox(height: 20),
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
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
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
                            fontSize: 22, fontWeight: FontWeight.bold))),
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

// ================== TWO PLAYER GAME SCREEN ==================
class TwoPlayerGameScreen extends StatefulWidget {
  final String player1Symbol;
  final String player2Symbol;

  TwoPlayerGameScreen({
    required this.player1Symbol,
    required this.player2Symbol,
  });

  @override
  _TwoPlayerGameScreenState createState() => _TwoPlayerGameScreenState();
}

class _TwoPlayerGameScreenState extends State<TwoPlayerGameScreen> with WidgetsBindingObserver {
  late List<String> board;
  late String currentTurn;
  bool gameOver = false;
  String winner = "";
  late AudioPlayer sfxPlayer;
  int timer = 10;
  Timer? turnTimer;
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = List.generate(9, (_) => "");
    currentTurn = widget.player1Symbol;
    sfxPlayer = AudioPlayer();
    confettiController = ConfettiController(duration: Duration(seconds: 2));
    startTurnTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    confettiController.dispose();
    turnTimer?.cancel();
    sfxPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      sfxPlayer.pause();
    }
  }

  void startTurnTimer() {
    turnTimer?.cancel();
    timer = 10;
    turnTimer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() => timer--);

      if (timer <= 5 && timer > 0) playSfx("Tap.mp3");

      if (timer <= 0) {
        turnTimer?.cancel();
        switchTurn();
      }
    });
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
      if (!gameOver) switchTurn();
    });
  }

  void switchTurn() {
    if (gameOver) return;
    currentTurn = currentTurn == widget.player1Symbol
        ? widget.player2Symbol
        : widget.player1Symbol;
    startTurnTimer();
  }

  void checkWinner() {
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

    for (var p in winPatterns) {
      if (board[p[0]] != "" &&
          board[p[0]] == board[p[1]] &&
          board[p[1]] == board[p[2]]) {
        gameOver = true;
        winner = board[p[0]];
        confettiController.play();
        playSfx("Celebration.mp3");
        turnTimer?.cancel();
        return;
      }
    }

    if (!board.contains("")) {
      gameOver = true;
      winner = "Draw";
      playSfx("draw.mp3");
      turnTimer?.cancel();
    }
  }

  void resetBoard() {
    setState(() {
      board = List.generate(9, (_) => "");
      currentTurn = widget.player1Symbol;
      gameOver = false;
      winner = "";
      startTurnTimer();
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
                color: board[index] == widget.player1Symbol
                    ? Colors.red
                    : Colors.blue),
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
                  "$timer ⏳",
                  style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color:
                          timer > 5 ? Colors.greenAccent : Colors.redAccent),
                ),
                SizedBox(height: 20),
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
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
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
                            fontSize: 22, fontWeight: FontWeight.bold))),
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
// ================= PART 5: SETTINGS & ABOUT SCREENS ==================

// ================== SETTINGS SCREEN ==================
class SettingsScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  SettingsScreen({required this.bgmPlayer});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  bool sfxOn = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      musicOn = prefs.getBool("musicOn") ?? true;
      sfxOn = prefs.getBool("sfxOn") ?? true;
    });
  }

  void toggleMusic(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("musicOn", value);
    setState(() => musicOn = value);
    if (musicOn) {
      widget.bgmPlayer.resume();
    } else {
      widget.bgmPlayer.pause();
    }
  }

  void toggleSfx(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("sfxOn", value);
    setState(() => sfxOn = value);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: Text("Background Music", style: TextStyle(color: Colors.white, fontSize: 22)),
              value: musicOn,
              onChanged: toggleMusic,
              activeColor: Colors.greenAccent,
            ),
            SwitchListTile(
              title: Text("Sound Effects", style: TextStyle(color: Colors.white, fontSize: 22)),
              value: sfxOn,
              onChanged: toggleSfx,
              activeColor: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }
}

// ================== ABOUT SCREEN ==================
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tic Tac Toe Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            Text(
                "Version: 1.0.0\n\n"
                "Developed by: Your Name\n\n"
                "Features:\n"
                "- Single Player (Vs AI) with 4 difficulty modes\n"
                "- Two Player Mode with 10 sec turn timer\n"
                "- Tap sound on every move & countdown sound\n"
                "- Big grid display\n"
                "- Confetti & celebration effect on win\n"
                "- Settings for music & sound effects",
                style: TextStyle(fontSize: 18, color: Colors.white70)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    minimumSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("Back", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
