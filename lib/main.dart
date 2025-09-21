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
    bgmPlayer.play(AssetSource("bgm.mp3"));

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
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

    // Ensure BGM plays immediately when HomeScreen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.bgmPlayer.resume();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
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
        .then((_) {
      widget.bgmPlayer.resume();
      loadScores();
    });
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
              Text("Tic Tac Toe",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              SizedBox(height: 25),
              Text(
                "Player: $playerWins  |  Computer: $computerWins  |  Draws: $draws",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => navigateTo(
                    ModeSelectionScreen(bgmPlayer: widget.bgmPlayer)),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.greenAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("▶ Play Game",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    navigateTo(TwoPlayerSymbolSelectionScreen(
                        bgmPlayer: widget.bgmPlayer)),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.blueAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("👥 2 Player Game",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    navigateTo(SettingsScreen(bgmPlayer: widget.bgmPlayer)),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.orangeAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("⚙ Settings",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => navigateTo(AboutScreen()),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 55),
                    backgroundColor: Colors.purpleAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("🏆 About",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PART 1: SETTINGS + ABOUT =================
class SettingsScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  final bool vsComputerMode;
  final bool playWithFriendsMode;

  SettingsScreen({
    required this.bgmPlayer,
    this.vsComputerMode = false,
    this.playWithFriendsMode = false,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool bgmOn = true;

  @override
  void initState() {
    super.initState();
    // VS Computer aur Play with Friends → BGM automatically off
    if (widget.vsComputerMode || widget.playWithFriendsMode) {
      bgmOn = false;
      widget.bgmPlayer.pause();
    }
  }

  void toggleBGM(bool value) {
    setState(() {
      bgmOn = value;
      if (bgmOn) {
        widget.bgmPlayer.resume();
      } else {
        widget.bgmPlayer.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Background Music (BGM)"),
              value: bgmOn,
              onChanged: (widget.vsComputerMode || widget.playWithFriendsMode)
                  ? null // disable toggle in these modes
                  : toggleBGM,
            ),
            SizedBox(height: 20),
            Text(
              widget.vsComputerMode || widget.playWithFriendsMode
                  ? "BGM is disabled in this mode"
                  : "",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About"), backgroundColor: Colors.deepPurple),
      body: SingleChildScrollView(   // 👈 yeh lagao
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🎮 Tic Tac Toe",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            SizedBox(height: 12),
            Text(
              "🎮 Tic Tac Toe is a classic strategy game where you can play against your friend in 2-player mode or challenge the computer at multiple difficulty levels. Enjoy a clean, modern design with smooth animations and exciting sound effects. Tap X or O to make your move and try to outsmart your opponent. Celebrate your wins with confetti and keep track of scores across games. Perfect for quick matches or long gaming sessions, Tic Tac Toe offers endless fun for all ages. Sharpen your mind, plan your moves, and become the ultimate Tic Tac Toe champion!",
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Colors.deepPurple),
              title: Text("Version"),
              subtitle: Text("1.0.0"),
            ),
            ListTile(
              leading: Icon(Icons.developer_mode, color: Colors.deepPurple),
              title: Text("Developed by"),
              subtitle: Text("PixelPlay"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= PART 2: MODE & SYMBOL SELECTION =================
class ModeSelectionScreen extends StatelessWidget {
  final AudioPlayer bgmPlayer;
  ModeSelectionScreen({required this.bgmPlayer});

  void startGame(BuildContext context, String difficulty) {
    bgmPlayer.pause();
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
          title: Text("Select Difficulty"), backgroundColor: Colors.deepPurple),
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

// ================= PART 2: SYMBOL SELECTION =================
class SymbolSelectionScreen extends StatelessWidget {
  final bool vsComputer;
  final String? difficulty;
  final AudioPlayer bgmPlayer;

  SymbolSelectionScreen(
      {required this.vsComputer, this.difficulty, required this.bgmPlayer});

  void startGame(BuildContext context, String playerSymbol) async {
    // Settings check for BGM
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool bgmOn = prefs.getBool("bgmOn") ?? true;

    // VS Computer mode → BGM off regardless of Settings
    if (vsComputer || difficulty != null || !bgmOn) {
      bgmPlayer.pause();
    }

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

class TwoPlayerSymbolSelectionScreen extends StatelessWidget {
  final AudioPlayer bgmPlayer;
  TwoPlayerSymbolSelectionScreen({required this.bgmPlayer});

  void startTwoPlayerGame(BuildContext context, String player1Symbol) async {
    // Settings check for BGM
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool bgmOn = prefs.getBool("bgmOn") ?? true;

    // 2 Player mode → always pause BGM
    if (!bgmOn) bgmPlayer.pause();
    else bgmPlayer.pause(); // Ensure BGM off

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => GameScreen(
                  vsComputer: false,
                  playerSymbol: player1Symbol,
                  difficulty: null,
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
              Text("Player 1: Choose Your Symbol",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
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

// =================== GAME SCREEN WITH AI MINIMAX + TIMER SOUNDS ===================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;
  final AudioPlayer bgmPlayer;

  GameScreen({
    required this.vsComputer,
    required this.playerSymbol,
    this.difficulty,
    required this.bgmPlayer,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  late String currentPlayer;
  late String playerSymbol, computerSymbol;
  bool gameOver = false;
  String winner = "";
  bool isAITurn = false;

  Timer? turnTimer;
  final int turnDuration = 10; // seconds per turn
  late AnimationController hourglassController;

  late AudioPlayer sfxPlayer;
  late ConfettiController confettiController;

  late AnimationController glowController;
  late Animation<double> glowAnimation;

  int playerWins = 0;
  int computerWins = 0;
  int draws = 0;

  List<int> winningPattern = [];

  @override
  void initState() {
    super.initState();
    playerSymbol = widget.playerSymbol;
    computerSymbol = playerSymbol == "X" ? "O" : "X";
    currentPlayer = "X";

    sfxPlayer = AudioPlayer();
    confettiController = ConfettiController(duration: Duration(seconds: 2));

    // Glow animation
    glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    glowAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          glowController.reverse();
        else if (status == AnimationStatus.dismissed) glowController.forward();
      });
    glowController.forward();

    // Hourglass animation
    hourglassController = AnimationController(
      vsync: this,
      duration: Duration(seconds: turnDuration),
    );

    loadScores();
    startTurnTimer();

    // VS Computer → pause BGM
    widget.bgmPlayer.pause();

    // If AI starts first
    if (widget.vsComputer && currentPlayer == computerSymbol) {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    glowController.dispose();
    hourglassController.dispose();
    confettiController.dispose();
    sfxPlayer.dispose();
    super.dispose();
  }

  // ------------------- Score Management -------------------
  Future<void> loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      playerWins = prefs.getInt("playerWins") ?? 0;
      computerWins = prefs.getInt("computerWins") ?? 0;
      draws = prefs.getInt("draws") ?? 0;
    });
  }

  Future<void> saveScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("playerWins", playerWins);
    prefs.setInt("computerWins", computerWins);
    prefs.setInt("draws", draws);
  }

  // ------------------- Turn Timer -------------------
  void startTurnTimer() {
    turnTimer?.cancel();
    hourglassController.forward(from: 0);

    turnTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (hourglassController.value >= 0.7 && hourglassController.value < 1.0) {
        // last 3 seconds warning (0.7 ~ 1.0)
        playSfx('Tap.mp3');
      }
      if (hourglassController.value >= 1.0) {
        nextTurn();
      }
    });
  }

  void resetTurnTimer() {
    turnTimer?.cancel();
    hourglassController.reset();
    if (!gameOver) startTurnTimer();
  }

  // ------------------- Sound Effects -------------------
  void playSfx(String file) async {
    if (!mounted) return;
    await sfxPlayer.play(AssetSource(file));
  }

  // ------------------- Game Logic -------------------
  void makeMove(int index) {
    if (gameOver || board[index] != "" || (widget.vsComputer && isAITurn)) return;

    setState(() {
      board[index] = currentPlayer;
      playSfx('Tap.mp3');
      checkWinner();
      if (!gameOver) {
        currentPlayer = currentPlayer == "X" ? "O" : "X";
        glowController.forward(from: 0);
        if (widget.vsComputer && currentPlayer == computerSymbol) {
          isAITurn = true;
          Future.delayed(Duration(milliseconds: 500), computerMove);
        } else {
          isAITurn = false;
        }
      }
    });

    resetTurnTimer();
  }

  void nextTurn() {
    if (gameOver) return;
    setState(() {
      currentPlayer = currentPlayer == "X" ? "O" : "X";
      glowController.forward(from: 0);
      if (widget.vsComputer && currentPlayer == computerSymbol) {
        isAITurn = true;
        Future.delayed(Duration(milliseconds: 500), computerMove);
      } else {
        isAITurn = false;
      }
    });
    resetTurnTimer();
  }

  // ------------------- AI Move -------------------
  void computerMove() {
    if (gameOver) return;

    int index;
    switch (widget.difficulty) {
      case "Easy":
        List<int> emptyCells = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
        index = emptyCells[Random().nextInt(emptyCells.length)];
        break;
      case "Medium":
        index = minimaxMove(depth: 1);
        break;
      case "Hard":
        index = minimaxMove(depth: 3);
        break;
      case "Expert":
        index = minimaxMove(depth: 9); // unbeatable
        break;
      default:
        index = Random().nextInt(9);
    }

    setState(() {
      board[index] = computerSymbol;
      playSfx('Tap.mp3');
      checkWinner();
      if (!gameOver) currentPlayer = playerSymbol;
      isAITurn = false;
    });
    resetTurnTimer();
  }

  // ------------------- Minimax AI -------------------
  int minimaxMove({int depth = 9}) {
    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = computerSymbol;
        int score = minimax(0, false, depth);
        board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }

    return move;
  }

  int minimax(int currentDepth, bool isMaximizing, int maxDepth) {
    String? result = evaluateBoard();
    if (result != null) {
      if (result == computerSymbol) return 10 - currentDepth;
      if (result == playerSymbol) return currentDepth - 10;
      if (result == "Draw") return 0;
    }
    if (currentDepth >= maxDepth) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = computerSymbol;
          int score = minimax(currentDepth + 1, false, maxDepth);
          board[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = playerSymbol;
          int score = minimax(currentDepth + 1, true, maxDepth);
          board[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String? evaluateBoard() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
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
    String? result = evaluateBoard();
    if (result != null) {
      setState(() {
        winner = result;
        gameOver = true;
        if (winner == playerSymbol)
          playerWins++;
        else if (winner == computerSymbol)
          computerWins++;
        else {
          draws++;
          playSfx('draw.mp3'); // Draw sound
        }
        saveScores();
        if (winner != "Draw") playSfx('Celebration.mp3');
        confettiController.play();

        // Highlight winning pattern
        if (winner != "Draw") {
          List<List<int>> winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6],
          ];
          winningPattern = winPatterns.firstWhere(
              (p) => board[p[0]] == winner && board[p[1]] == winner && board[p[2]] == winner,
              orElse: () => []);
        }
      });
      turnTimer?.cancel();
    }
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      gameOver = false;
      winner = "";
      winningPattern = [];
      isAITurn = false;
    });
    resetTurnTimer();

    if (widget.vsComputer && currentPlayer == computerSymbol) {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    double boardSize = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tic Tac Toe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scores
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                scoreCard('You', playerWins),
                scoreCard('Draw', draws),
                scoreCard('AI', computerWins),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Board
          Container(
            width: boardSize,
            height: boardSize,
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5),
              itemBuilder: (context, index) {
                bool highlight = winningPattern.contains(index);
                return GestureDetector(
                  onTap: () => makeMove(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: highlight ? Colors.yellow.shade300 : Colors.white,
                      border: Border.all(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: glowAnimation,
                        child: Text(
                          board[index],
                          style: TextStyle(
                              fontSize: boardSize / 5,
                              fontWeight: FontWeight.bold,
                              color: board[index] == playerSymbol
                                  ? Colors.deepPurple
                                  : Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Turn & Hourglass
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gameOver
                    ? winner == "Draw"
                        ? "It's a Draw!"
                        : "$winner Wins!"
                    : "$currentPlayer's Turn",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 40,
                height: 80,
                child: AnimatedBuilder(
                  animation: hourglassController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: HourglassPainter(
                          progress: hourglassController.value, flipped: false),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),

          // Reset Button
          ElevatedButton.icon(
            onPressed: resetGame,
            icon: Icon(Icons.refresh),
            label: Text('Restart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      // Confetti
      floatingActionButton: ConfettiWidget(
        confettiController: confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: [Colors.purple, Colors.red, Colors.yellow, Colors.blue],
        numberOfParticles: 20,
        maxBlastForce: 10,
        minBlastForce: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget scoreCard(String title, int value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        SizedBox(height: 5),
        Text(
          value.toString(),
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
      ],
    );
  }
}

// =================== HOURGLASS PAINTER ===================
class HourglassPainter extends CustomPainter {
  final double progress; // 0 → 1
  final bool flipped;

  HourglassPainter({required this.progress, required this.flipped});

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final sandPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    double midY = size.height / 2;

    // Top triangle
    Path top = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, midY)
      ..close();

    // Bottom triangle
    Path bottom = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, midY)
      ..close();

    // Draw outlines
    canvas.drawPath(top, outlinePaint);
    canvas.drawPath(bottom, outlinePaint);

    if (!flipped) {
      // Sand draining from top → bottom
      double upperHeight = (1 - progress) * midY;
      double lowerHeight = progress * midY;

      // Top fill
      canvas.save();
      canvas.clipPath(top);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, upperHeight), sandPaint);
      canvas.restore();

      // Bottom fill
      canvas.save();
      canvas.clipPath(bottom);
      canvas.drawRect(
          Rect.fromLTWH(0, size.height - lowerHeight, size.width, lowerHeight),
          sandPaint);
      canvas.restore();
    } else {
      // Flipped mode
      double upperHeight = progress * midY;
      double lowerHeight = (1 - progress) * midY;

      // Top fill
      canvas.save();
      canvas.clipPath(top);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, upperHeight), sandPaint);
      canvas.restore();

      // Bottom fill
      canvas.save();
      canvas.clipPath(bottom);
      canvas.drawRect(
      Rect.fromLTWH(0, size.height -
      lowerHeight, size.width, lowerHeight),
      sandPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant HourglassPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.flipped != flipped;
}
