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
              "Tic Tac Toe ek fun strategy game hai jisme aap apne friend ke saath (2 Player Mode) ya computer ke against alag difficulty levels me khel sakte ho. Classic game modern design, sound effects aur confetti celebration ke saath enjoy karo!",
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

// ================= PART 3: GAME SCREEN =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;
  final AudioPlayer bgmPlayer;

  GameScreen(
      {required this.vsComputer,
      required this.playerSymbol,
      this.difficulty,
      required this.bgmPlayer});

  @override
  _GameScreenState createState() => _GameScreenState();
}

// ================= PART 3 CONTINUED =================
class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X";
  String winner = "";
  late String playerSymbol, computerSymbol;
  bool gameOver = false;
  late AudioPlayer sfxPlayer;
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();

    playerSymbol = widget.playerSymbol;
    computerSymbol = playerSymbol == "X" ? "O" : "X";
    currentPlayer = "X";

    sfxPlayer = AudioPlayer();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // If computer starts first
    if (widget.vsComputer && playerSymbol == "O") {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  @override
  void dispose() {
    sfxPlayer.dispose();
    confettiController.dispose();
    super.dispose();
  }

  void playSfx(String file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool sfxOn = prefs.getBool("sfxOn") ?? true;
    if (sfxOn) await sfxPlayer.play(AssetSource(file));
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      winner = "";
      gameOver = false;
      currentPlayer = "X";
    });

    if (widget.vsComputer && playerSymbol == "O") {
      Future.delayed(Duration(milliseconds: 500), computerMove);
    }
  }

  void makeMove(int index) {
    if (board[index] != "" || gameOver) return;

    if (widget.vsComputer && currentPlayer == computerSymbol) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("⚠ Warning"),
                content: Text("Wait! It's Computer's turn."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"))
                ],
              ));
      return;
    }

    setState(() {
      board[index] = currentPlayer;
      playSfx("Tap.mp3");
      checkWinner();

      if (!gameOver) {
        currentPlayer = currentPlayer == "X" ? "O" : "X";

        if (widget.vsComputer && currentPlayer == computerSymbol) {
          Future.delayed(Duration(milliseconds: 500), computerMove);
        }
      }
    });
  }

  void computerMove() {
    if (gameOver) return;

    List<int> emptyCells = [for (int i = 0; i < 9; i++) if (board[i] == "") i];
    if (emptyCells.isEmpty) return;

    int index;

    if (widget.difficulty == "Easy") {
      index = emptyCells[Random().nextInt(emptyCells.length)];
    } else if (widget.difficulty == "Medium") {
      index = mediumMove();
    } else if (widget.difficulty == "Hard") {
      index = hardMove();
    } else if (widget.difficulty == "Expert") {
      index = minimaxBestMove();
    } else {
      index = emptyCells[Random().nextInt(emptyCells.length)];
    }

    setState(() {
      board[index] = computerSymbol;
      playSfx("Tap.mp3");
      checkWinner();
      if (!gameOver) currentPlayer = playerSymbol;
    });
  }

  int mediumMove() {
    // Win if possible
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

    // Block player
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

    // Random move
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
        if (isMaximizing) {
          bestScore = max(score, bestScore);
        } else {
          bestScore = min(score, bestScore);
        }
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
      if (b[p[0]] == symbol && b[p[1]] == symbol && b[p[2]] == symbol) {
        return true;
      }
    }
    return false;
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
          playSfx("Celebration.mp3");
          confettiController.play();
        });
        saveScore(winner);
        return;
      }
    }

    if (!board.contains("")) {
      setState(() {
        winner = "Draw";
        gameOver = true;
        playSfx("draw.mp3");
      });
      saveScore("Draw");
    }
  }

  void saveScore(String result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (result == "Draw") {
      int draws = prefs.getInt("draws") ?? 0;
      prefs.setInt("draws", draws + 1);
    } else if (widget.vsComputer) {
      if (result == playerSymbol) {
        int pw = prefs.getInt("playerWins") ?? 0;
        prefs.setInt("playerWins", pw + 1);
      } else {
        int cw = prefs.getInt("computerWins") ?? 0;
        prefs.setInt("computerWins", cw + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.9;

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
                    end: Alignment.bottomRight)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  winner.isNotEmpty
                      ? (winner == "Draw" ? "It's a Draw!" : "$winner Wins!")
                      : "Turn: $currentPlayer",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  width: size,
                  height: size,
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetGame,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      minimumSize: Size(200, 50)),
                  child: Text("🔄 Reset Game",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                )
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
          )
        ],
      ),
    );
  }
}
