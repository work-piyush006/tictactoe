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

// ================= Updated GameScreen =================
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
  List<int> winningPattern = [];

  int playerWins = 0, computerWins = 0, draws = 0;

  // Timer
  int seconds = 10;
  Timer? turnTimer;

  TextEditingController playerNameController = TextEditingController();
  late String computerName;

  // Confetti
  late ConfettiController confettiController;

  // Audio
  late AudioPlayer sfxPlayer;

  // Glow animation
  late AnimationController glowController;
  late Animation<double> glowAnimation;

  @override
  void initState() {
    super.initState();
    playerSymbol = widget.playerSymbol;
    computerSymbol = playerSymbol == "X" ? "O" : "X";
    currentPlayer = "X";

    computerName = widget.vsComputer ? "${widget.difficulty} AI" : "Player 2";
    playerNameController.text = "Player";

    sfxPlayer = AudioPlayer();
    confettiController = ConfettiController(duration: Duration(seconds: 2));

    glowController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 800));
    glowAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          glowController.reverse();
        else if (status == AnimationStatus.dismissed) glowController.forward();
      });
    glowController.forward();

    loadScores();
    startTurnTimer();

    widget.bgmPlayer.pause();

    if (widget.vsComputer && currentPlayer == computerSymbol) {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    glowController.dispose();
    confettiController.dispose();
    sfxPlayer.dispose();
    playerNameController.dispose();
    super.dispose();
  }

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

  // ------------------- Timer -------------------
  void startTurnTimer() {
    turnTimer?.cancel();
    setState(() => seconds = 10);

    turnTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      if (seconds <= 3 && seconds > 0) {
        await sfxPlayer.play(AssetSource('Tap.mp3'));
      }

      setState(() => seconds--);

      if (seconds <= 0) {
        nextTurn();
      }
    });
  }

  void resetTurnTimer() {
    turnTimer?.cancel();
    startTurnTimer();
  }

  void playSfx(String file) async {
    await sfxPlayer.play(AssetSource(file));
  }

  // ------------------- Game Logic -------------------
  void makeMove(int index) {
    if (gameOver || board[index] != "") return;
    if (widget.vsComputer && isAITurn) return;

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

  void computerMove() {
    if (gameOver) return;

    int index;
    switch (widget.difficulty) {
      case "Easy":
        List<int> empty = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
        index = empty[Random().nextInt(empty.length)];
        break;
      case "Medium":
        index = minimaxMove(depth: 1);
        break;
      case "Hard":
        index = minimaxMove(depth: 3);
        break;
      case "Expert":
        index = minimaxMove(depth: 9);
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

  int minimax(int currentDepth, bool isMax, int maxDepth) {
    String? result = evaluateBoard();
    if (result != null) {
      if (result == computerSymbol) return 10 - currentDepth;
      if (result == playerSymbol) return currentDepth - 10;
      if (result == "Draw") return 0;
    }
    if (currentDepth >= maxDepth) return 0;

    if (isMax) {
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
    List<List<int>> patterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var p in patterns) {
      if (board[p[0]] != "" &&
          board[p[0]] == board[p[1]] &&
          board[p[1]] == board[p[2])) return board[p[0]];
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
        else
          draws++;

        saveScores();
        if (winner != "Draw") playSfx('Celebration.mp3');
        else playSfx('draw.mp3');

        List<List<int>> patterns = [
          [0, 1, 2],
          [3, 4, 5],
          [6, 7, 8],
          [0, 3, 6],
          [1, 4, 7],
          [2, 5, 8],
          [0, 4, 8],
          [2, 4, 6]
        ];
        winningPattern = patterns.firstWhere(
            (p) =>
                board[p[0]] == winner &&
                board[p[1]] == winner &&
                board[p[2]] == winner,
            orElse: () => []);
      });
      turnTimer?.cancel();
      confettiController.play();
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
      seconds = 10;
    });
    resetTurnTimer();

    if (widget.vsComputer && currentPlayer == computerSymbol) {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  Widget scoreCard(String name, int score) {
    return Column(
      children: [
        Text(name, style: TextStyle(color: Colors.white, fontSize: 16)),
        Text("$score",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
      ],
    );
  }

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
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Player rename + opponent
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: playerNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Player Name',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      computerName,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
              ),

              // Scores
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    scoreCard(playerNameController.text, playerWins),
                    scoreCard('Draw', draws),
                    scoreCard(computerName, computerWins),
                  ],
                ),
              ),

              // Hourglass + Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Turn: ${currentPlayer == playerSymbol ? playerNameController.text : computerName}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SmoothHourglass(secondsLeft: seconds),
                      SizedBox(height: 5),
                      Text(
                        '$seconds s',
                        style: TextStyle(
                          color: seconds <= 3 ? Colors.red : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Game Board
              Container(
                width: boardSize,
                height: boardSize,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    bool isWinningCell = winningPattern.contains(index);
                    return GestureDetector(
                      onTap: () => makeMove(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isWinningCell
                              ? Colors.yellowAccent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2))
                          ],
                        ),
                        child: Center(
                          child: ScaleTransition(
                            scale: glowAnimation,
                            child: Text(
                              board[index],
                              style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: board[index] == "X"
                                      ? Colors.deepPurple
                                      : Colors.pinkAccent),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // Reset Button
              ElevatedButton.icon(
                onPressed: resetGame,
                icon: Icon(Icons.refresh),
                label: Text("Restart Game"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple),
              ),

              // Confetti
              ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [Colors.yellow, Colors.red, Colors.green, Colors.blue],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Smooth Animated Hourglass Painter =================
class SmoothHourglass extends StatefulWidget {
  final int secondsLeft; // 0-10
  const SmoothHourglass({Key? key, required this.secondsLeft}) : super(key: key);

  @override
  _SmoothHourglassState createState() => _SmoothHourglassState();
}

class _SmoothHourglassState extends State<SmoothHourglass> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool flipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          flipped = !flipped;
          _controller.forward(from: 0);
        }
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SmoothHourglass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secondsLeft != widget.secondsLeft) {
      // Optional: could sync animation if needed
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        if (flipped) progress = 1 - progress;
        return CustomPaint(
          painter: SmoothHourglassPainter(progress: progress),
          child: SizedBox(width: 60, height: 100),
        );
      },
    );
  }
}

class SmoothHourglassPainter extends CustomPainter {
  final double progress;

  SmoothHourglassPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Outline paint
    final Paint outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw hourglass frame
    Path frame = Path();
    frame.moveTo(0, 0);
    frame.lineTo(w, 0);
    frame.lineTo(0, h);
    frame.lineTo(w, h);
    frame.close();
    canvas.drawPath(frame, outline);
    canvas.drawLine(Offset(0, 0), Offset(w, h), outline);
    canvas.drawLine(Offset(w, 0), Offset(0, h), outline);

    // Draw falling sand with gradient
    Paint sandPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.yellow, Colors.orange, Colors.redAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Top sand
    Path topSand = Path();
    topSand.moveTo(0, 0);
    topSand.lineTo(w, 0);
    topSand.lineTo(w/2, h/2 * (1 - progress));
    topSand.close();
    canvas.drawPath(topSand, sandPaint);

    // Bottom sand
    Path bottomSand = Path();
    bottomSand.moveTo(0, h);
    bottomSand.lineTo(w, h);
    bottomSand.lineTo(w/2, h/2 + h/2 * progress);
    bottomSand.close();
    canvas.drawPath(bottomSand, sandPaint);

    // Falling stream
    Paint streamPaint = Paint()..color = Colors.orangeAccent;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w/2, h/2),
        width: 4,
        height: 20 * progress,
      ),
      streamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SmoothHourglassPainter oldDelegate) => true;
}
