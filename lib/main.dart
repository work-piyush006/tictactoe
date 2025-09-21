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
  SettingsScreen({required this.bgmPlayer});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool bgmOn = true;
  bool sfxOn = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bgmOn = prefs.getBool("bgmOn") ?? true;
      sfxOn = prefs.getBool("sfxOn") ?? true;
    });
  }

  void toggleBgm(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => bgmOn = value);
    prefs.setBool("bgmOn", value);
    if (value) {
      widget.bgmPlayer.resume();
    } else {
      widget.bgmPlayer.pause();
    }
  }

  void toggleSfx(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => sfxOn = value);
    prefs.setBool("sfxOn", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.deepPurple),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Background Music"),
            value: bgmOn,
            onChanged: toggleBgm,
          ),
          SwitchListTile(
            title: Text("Sound Effects"),
            value: sfxOn,
            onChanged: toggleSfx,
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About"), backgroundColor: Colors.deepPurple),
      body: Padding(
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

  void startGame(BuildContext context, String playerSymbol) {
    bgmPlayer.pause();
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

  void startTwoPlayerGame(BuildContext context, String player1Symbol) {
    bgmPlayer.pause();
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

// =================== GAME SCREEN ===================
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

  // Timer
  Timer? turnTimer;
  int elapsedSeconds = 0;
  final int turnDuration = 10;

  // Sound
  late AudioCache sfxCache;

  // Confetti
  late ConfettiController confettiController;

  // Animation for turn highlight
  late AnimationController glowController;
  late Animation<double> glowAnimation;

  // Hourglass animation
  late AnimationController hourglassController;

  @override
  void initState() {
    super.initState();
    playerSymbol = widget.playerSymbol;
    computerSymbol = playerSymbol == "X" ? "O" : "X";
    currentPlayer = "X";

    sfxCache = AudioCache(prefix: 'assets/');
    sfxCache.loadAll(['Tap.mp3', 'Celebration.mp3', 'draw.mp3']);

    confettiController = ConfettiController(duration: Duration(seconds: 2));

    glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    glowAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: glowController,
      curve: Curves.easeInOut,
    ))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              glowController.reverse();
            else if (status == AnimationStatus.dismissed) glowController.forward();
          });
    glowController.forward();

    hourglassController = AnimationController(
      vsync: this,
      duration: Duration(seconds: turnDuration),
    );

    startTurnTimer();

    if (widget.vsComputer && currentPlayer == computerSymbol) {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    confettiController.dispose();
    glowController.dispose();
    hourglassController.dispose();
    super.dispose();
  }

  void startTurnTimer() {
    turnTimer?.cancel();
    elapsedSeconds = 0;
    hourglassController.forward(from: 0);

    turnTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      setState(() {});

      if (elapsedSeconds > turnDuration - 3) playTap();

      if (elapsedSeconds >= turnDuration) {
        timer.cancel();
        nextTurn();
      }
    });
  }

  void resetTurnTimer() {
    turnTimer?.cancel();
    hourglassController.reset();
    startTurnTimer();
  }

  void playTap() => sfxCache.play('Tap.mp3');

  void showWarning(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void makeMove(int index) {
    if (board[index] != "") {
      showWarning("Box already filled!");
      return;
    }

    if (widget.vsComputer && isAITurn) {
      showWarning("Wait for your turn!");
      return;
    }

    setState(() {
      board[index] = currentPlayer;
      playTap();
      checkWinner();
      resetTurnTimer();

      if (!gameOver) {
        currentPlayer = currentPlayer == "X" ? "O" : "X";
        glowController.forward(from: 0.0);

        if (widget.vsComputer && currentPlayer == computerSymbol) {
          isAITurn = true;
          Future.delayed(Duration(milliseconds: 500), computerMove);
        } else {
          isAITurn = false;
        }
      }
    });
  }

  void nextTurn() {
    if (gameOver) return;

    setState(() {
      currentPlayer = currentPlayer == "X" ? "O" : "X";
      glowController.forward(from: 0.0);

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

    List<int> emptyCells = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
    if (emptyCells.isEmpty) return;

    int index;
    switch (widget.difficulty) {
      case "Easy":
        index = emptyCells[Random().nextInt(emptyCells.length)];
        break;
      case "Medium":
        index = mediumMove();
        break;
      case "Hard":
        index = hardMove();
        break;
      case "Expert":
        index = minimaxBestMove();
        break;
      default:
        index = emptyCells[Random().nextInt(emptyCells.length)];
    }

    setState(() {
      board[index] = computerSymbol;
      playTap();
      checkWinner();

      if (!gameOver) {
        currentPlayer = playerSymbol;
        glowController.forward(from: 0.0);
      }

      isAITurn = false;
    });

    resetTurnTimer();
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      gameOver = false;
      winner = "";
      isAITurn = false;
    });

    resetTurnTimer();

    if (widget.vsComputer && currentPlayer == computerSymbol) {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
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
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] != "" &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        setState(() {
          winner = board[pattern[0]];
          gameOver = true;
          playSfx('Celebration.mp3');
          confettiController.play();
        });
        turnTimer?.cancel();
        return;
      }
    }

    if (!board.contains("")) {
      setState(() {
        winner = "Draw";
        gameOver = true;
        playSfx('draw.mp3');
      });
      turnTimer?.cancel();
    }
  }

  void playSfx(String file) => sfxCache.play(file);

  int mediumMove() {
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = computerSymbol;
        if (checkWinnerForMinimax(board, computerSymbol)) {
          board[i] = "";
          return i;
        }
        board[i] = "";
      }
    }
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = playerSymbol;
        if (checkWinnerForMinimax(board, playerSymbol)) {
          board[i] = "";
          return i;
        }
        board[i] = "";
      }
    }
    List<int> emptyCells = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
    return emptyCells[Random().nextInt(emptyCells.length)];
  }

  int hardMove() {
    int move = mediumMove();
    if (Random().nextBool()) {
      List<int> emptyCells = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
      move = emptyCells[Random().nextInt(emptyCells.length)];
    }
    return move;
  }

  int minimaxBestMove() {
    int bestScore = -1000;
    int move = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = computerSymbol;
        int score = minimax(board, false);
        board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  int minimax(List<String> newBoard, bool isMaximizing) {
    if (checkWinnerForMinimax(newBoard, computerSymbol)) return 10;
    if (checkWinnerForMinimax(newBoard, playerSymbol)) return -10;
    if (!newBoard.contains("")) return 0;

    int bestScore = isMaximizing ? -1000 : 1000;

    for (int i = 0; i < 9; i++) {
      if (newBoard[i] == "") {
        newBoard[i] = isMaximizing ? computerSymbol : playerSymbol;
        int score = minimax(newBoard, !isMaximizing);
        newBoard[i] = "";
        bestScore = isMaximizing ? max(score, bestScore) : min(score, bestScore);
      }
    }
    return bestScore;
  }

  bool checkWinnerForMinimax(List<String> b, String symbol) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var p in winPatterns) {
      if (b[p[0]] == symbol && b[p[1]] == symbol && b[p[2]] == symbol)
        return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.9;

    int remainingSeconds = turnDuration - elapsedSeconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vsComputer ? "Vs Computer" : "2 Player"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: glowAnimation,
                  child: Text(
                    winner.isNotEmpty
                        ? (winner == "Draw" ? "It's a Draw!" : "$winner Wins!")
                        : "Turn: $currentPlayer",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 15),
                // Hourglass Timer
                CustomPaint(
                  size: Size(70, 120),
                  painter: HourglassPainter(progress: hourglassController.value),
                ),
                SizedBox(height: 20),
                Container(
                  width: size,
                  height: size,
                  child: AbsorbPointer(
                    absorbing: isAITurn,
                    child: GridView.builder(
                      itemCount: 9,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, childAspectRatio: 1),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => makeMove(index),
                        child: Container(
                          margin: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(board[index],
                                style: TextStyle(
                                    color: board[index] == "X"
                                        ? Colors.redAccent
                                        : Colors.blueAccent,
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetGame,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      minimumSize: Size(200, 50)),
                  child: Text("🔄 Reset Game",
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
            ),
          ),
        ],
      ),
    );
  }
}

// =================== HOURGLASS PAINTER ===================
class HourglassPainter extends CustomPainter {
  final double progress;

  HourglassPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintFrame = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintSand = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    // Draw sand top triangle
    Path topSand = Path();
    double sandHeight = size.height / 2 * (1 - progress);
    topSand.moveTo(0, 0);
    topSand.lineTo(size.width, 0);
    topSand.lineTo(size.width / 2, size.height / 2 - sandHeight);
    topSand.close();
    canvas.drawPath(topSand, paintSand);

    // Draw sand bottom triangle
    Path bottomSand = Path();
    double sandFill = size.height / 2 * progress;
    bottomSand.moveTo(0, size.height);
    bottomSand.lineTo(size.width, size.height);
    bottomSand.lineTo(size.width / 2, size.height / 2 + sandFill);
    bottomSand.close();
    canvas.drawPath(bottomSand, paintSand);

    // Draw hourglass outline
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paintFrame);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paintFrame);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paintFrame);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paintFrame);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paintFrame);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
