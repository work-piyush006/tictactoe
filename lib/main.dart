import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AudioPlayer bgmPlayer;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> particles = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    bgmPlayer = AudioPlayer();
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
    bgmPlayer.play(AssetSource("bgm.mp3"));

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation =
        Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
          ..addListener(() {
            setState(() {});
          });
    _controller.repeat(reverse: true);

    for (int i = 0; i < 50; i++) {
      particles.add(
          Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    }

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
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // App lifecycle events
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      bgmPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          gradientBg(),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(painter: FloatingXO(particles: particles));
            },
          ),
          Center(
            child: Transform.scale(
              scale: _animation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/logo.png", width: 120, height: 120),
                  SizedBox(height: 10),
                  Text(
                    "T i c T a c T o e",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= FLOATING X/O PAINTER =================
class FloatingXO extends CustomPainter {
  final List<Offset> particles;
  Random random = Random();
  FloatingXO({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var pos in particles) {
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: random.nextBool() ? "❌" : "⭕",
          style: TextStyle(
            fontSize: 20,
            color: random.nextBool()
                ? Colors.red.shade200.withOpacity(0.7)
                : Colors.blue.shade200.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ================= HOME SCREEN =================
class HomeScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  HomeScreen({required this.bgmPlayer});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  List<Offset> particles = [];
  Random random = Random();
  bool isBgmOn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..repeat(reverse: true);

    for (int i = 0; i < 40; i++) {
      particles.add(Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    }

    widget.bgmPlayer.resume();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed && isBgmOn) {
      widget.bgmPlayer.resume();
    }
  }

  void toggleBgm() {
    setState(() {
      isBgmOn = !isBgmOn;
      if (isBgmOn) {
        widget.bgmPlayer.resume();
      } else {
        widget.bgmPlayer.pause();
      }
    });
  }

  void navigateToGame(bool vsComputer) {
    widget.bgmPlayer.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymbolSelectionScreen(vsComputer: vsComputer, bgmPlayer: widget.bgmPlayer),
      ),
    ).then((_) {
      if (isBgmOn) widget.bgmPlayer.resume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          gradientBg(),
          Positioned.fill(child: CustomPaint(painter: FloatingXO(particles: particles))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose Your Mode To Play 🎮",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => navigateToGame(true),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.greenAccent.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Play vs Computer",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => navigateToGame(false),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.blueAccent.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Play with Friends",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isBgmOn ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                  onPressed: toggleBgm,
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              backgroundColor: Colors.deepPurple.shade800,
                              title: Text("About", style: TextStyle(color: Colors.white)),
                              content: Text(
                                  "Made by G A PRODUCTION\nVersion 1.0.0\nTips: Tap cells to play",
                                  style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Close"))
                              ],
                            ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ================= SYMBOL SELECTION =================
class SymbolSelectionScreen extends StatelessWidget {
  final bool vsComputer;
  final AudioPlayer bgmPlayer;
  SymbolSelectionScreen({required this.vsComputer, required this.bgmPlayer});

  void startGame(BuildContext context, String playerSymbol) {
    if (vsComputer) {
      showDialog(
        context: context,
        builder: (_) =>
            DifficultyDialog(playerSymbol: playerSymbol, bgmPlayer: bgmPlayer),
      );
    } else {
      bgmPlayer.pause();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            vsComputer: false,
            playerSymbol: playerSymbol,
            difficulty: "Easy",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          gradientBg(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Choose Your Symbol",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => startGame(context, "X"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: Size(100, 100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("X", style: TextStyle(fontSize: 36)),
                    ),
                    SizedBox(width: 40),
                    ElevatedButton(
                      onPressed: () => startGame(context, "O"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: Size(100, 100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("O", style: TextStyle(fontSize: 36)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DIFFICULTY DIALOG =================
class DifficultyDialog extends StatelessWidget {
  final String playerSymbol;
  final AudioPlayer bgmPlayer;
  DifficultyDialog({required this.playerSymbol, required this.bgmPlayer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.deepPurple.shade800,
      title: Text("Select Difficulty Level", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ["Easy", "Medium", "Hard", "Expert", "Super Expert"]
            .map((diff) => Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      bgmPlayer.pause();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                              vsComputer: true,
                              playerSymbol: playerSymbol,
                              difficulty: diff),
                        ),
                      );
                    },
                    child: Text(diff, style: TextStyle(fontSize: 18)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ================= GAME SCREEN =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String difficulty;

  GameScreen(
      {required this.vsComputer,
      required this.playerSymbol,
      required this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late List<String> board;
  late String currentTurn;
  late String opponentSymbol;
  bool gameOver = false;
  String resultMessage = "";
  int playerScore = 0;
  int opponentScore = 0;

  final AudioPlayer tapPlayer = AudioPlayer();
  final AudioPlayer celebratePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    board = List.filled(9, "");
    currentTurn = "X";
    opponentSymbol = widget.playerSymbol == "X" ? "O" : "X";
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tapPlayer.dispose();
    celebratePlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App minimized, close game
      Navigator.pop(context);
    }
  }

  void playTapSound() async {
    await tapPlayer.play(AssetSource("Tap.mp3"));
  }

  void playCelebrateSound() async {
    await celebratePlayer.play(AssetSource("Celebration.mp3"));
  }

  void resetBoard() {
    setState(() {
      board = List.filled(9, "");
      currentTurn = "X";
      gameOver = false;
      resultMessage = "";
    });
  }

  void handleTap(int index) {
    if (gameOver) return;
    if (board[index] != "") return;

    if ((widget.vsComputer && currentTurn != widget.playerSymbol)) {
      _showTurnDialog();
      return;
    }

    setState(() {
      board[index] = currentTurn;
      playTapSound();
      checkWinner();
      if (!gameOver) switchTurn();
    });

    if (widget.vsComputer && !gameOver && currentTurn == opponentSymbol) {
      Future.delayed(Duration(milliseconds: 700), () {
        computerMove();
      });
    }
  }

  void switchTurn() {
    currentTurn = currentTurn == "X" ? "O" : "X";
  }

  void computerMove() {
    int move = getBestMove(widget.difficulty);
    setState(() {
      board[move] = currentTurn;
      playTapSound();
      checkWinner();
      if (!gameOver) switchTurn();
    });
  }

  int getBestMove(String diff) {
    List<int> empty = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") empty.add(i);
    }
    if (diff == "Easy") return empty[Random().nextInt(empty.length)];
    if (diff == "Medium") {
      if (Random().nextBool()) return empty[Random().nextInt(empty.length)];
      return findWinningMove(currentTurn) ?? empty[0];
    }
    if (diff == "Hard") {
      return findWinningMove(currentTurn) ??
          findWinningMove(widget.playerSymbol) ??
          empty[Random().nextInt(empty.length)];
    }
    return empty[0];
  }

  int? findWinningMove(String symbol) {
    List<List<int>> wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    for (var line in wins) {
      if (board[line[0]] == symbol &&
          board[line[1]] == symbol &&
          board[line[2]] == "") return line[2];
      if (board[line[0]] == symbol &&
          board[line[2]] == symbol &&
          board[line[1]] == "") return line[1];
      if (board[line[1]] == symbol &&
          board[line[2]] == symbol &&
          board[line[0]] == "") return line[0];
    }
    return null;
  }

  void checkWinner() {
    List<List<int>> wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var line in wins) {
      if (board[line[0]] != "" &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        gameOver = true;
        resultMessage = "${board[line[0]]} Wins!";
        playCelebrateSound();
        if (board[line[0]] == widget.playerSymbol) {
          playerScore++;
        } else {
          opponentScore++;
        }
        showEndDialog(resultMessage);
        return;
      }
    }

    if (!board.contains("")) {
      gameOver = true;
      resultMessage = "It's a Draw!";
      playCelebrateSound();
      showEndDialog(resultMessage);
    }
  }

  void showEndDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.deepPurple.shade800,
              title: Text(message,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetBoard();
                  },
                  child: Text("Play Again"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // back to home
                  },
                  child: Text("Home"),
                ),
              ],
            ));
  }

  void _showTurnDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade700,
        title: Text("Wait for your turn 💢",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
        ),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
              fontSize: 48,
              color: board[index] == "X" ? Colors.redAccent : Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // close game on back button
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.vsComputer ? "Vs Computer" : "2 Players"),
          backgroundColor: Colors.deepPurple,
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  "${playerScore} : ${opponentScore}",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            gradientBg(),
            Center(
              child: Container(
                width: 320,
                height: 320,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (_, index) => buildCell(index),
                  itemCount: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ================= GRADIENT BG =================
Widget gradientBg() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade900],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );
}
