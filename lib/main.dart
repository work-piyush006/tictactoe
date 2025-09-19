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
    with SingleTickerProviderStateMixin {
  late AudioPlayer bgmPlayer;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> particles = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();

    // Background music
    bgmPlayer = AudioPlayer();
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
    bgmPlayer.play(AssetSource("bgm.mp3"));

    // Logo animation
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

    // Floating particles
    for (int i = 0; i < 50; i++) {
      particles.add(
          Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    }

    // Navigate to HomeScreen after delay
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.indigo.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
                  Image.asset(
                    "assets/logo.png",
                    width: 120,
                    height: 120,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "X & O\nUltimate Battle",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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
          text: random.nextBool() ? "X" : "O",
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
class HomeScreen extends StatelessWidget {
  final AudioPlayer bgmPlayer;
  HomeScreen({required this.bgmPlayer});

  void navigateToGame(BuildContext context, bool vsComputer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymbolSelectionScreen(
            vsComputer: vsComputer, bgmPlayer: bgmPlayer),
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
                colors: [Colors.deepPurple.shade800, Colors.purple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: FloatingXO(
                particles: List.generate(
                  40,
                  (index) => Offset(
                    Random().nextDouble() * 400,
                    Random().nextDouble() * 800,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose Mode to Start",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(2, 2))
                    ],
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => navigateToGame(context, true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(240, 55),
                    backgroundColor: Colors.greenAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Play vs Computer",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => navigateToGame(context, false),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(240, 55),
                    backgroundColor: Colors.blueAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Play with Friends",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        builder: (_) => DifficultyDialog(
          playerSymbol: playerSymbol,
          bgmPlayer: bgmPlayer,
        ),
      );
    } else {
      bgmPlayer.stop();
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
      backgroundColor: Colors.deepPurple.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose Your Symbol",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      blurRadius: 3,
                      color: Colors.black45,
                      offset: Offset(1, 1))
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => startGame(context, "X"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(100, 100),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("X", style: TextStyle(fontSize: 36)),
                ),
                SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () => startGame(context, "O"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(100, 100),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("O", style: TextStyle(fontSize: 36)),
                ),
              ],
            ),
          ],
        ),
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
      title: Text("Select Difficulty Level",
          style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          difficultyButton(context, "Easy"),
          difficultyButton(context, "Medium"),
          difficultyButton(context, "Hard"),
          difficultyButton(context, "Expert"),
          difficultyButton(context, "Super Expert"),
        ],
      ),
    );
  }

  Widget difficultyButton(BuildContext context, String difficulty) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purpleAccent.shade700,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          bgmPlayer.stop();
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(
                vsComputer: true,
                playerSymbol: playerSymbol,
                difficulty: difficulty,
              ),
            ),
          );
        },
        child: Text(difficulty, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ================= GAME SCREEN =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String difficulty;

  GameScreen({
    required this.vsComputer,
    required this.playerSymbol,
    required this.difficulty,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, "");
  String currentPlayer = "";
  Random random = Random();
  final AudioPlayer tapPlayer = AudioPlayer();

  int scoreX = 0;
  int scoreO = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    currentPlayer = "X";
    if (widget.vsComputer && widget.playerSymbol != "X") {
      Future.delayed(Duration(milliseconds: 500), () => computerMove());
    }
  }

  Future<void> playTapSound() async =>
      await tapPlayer.play(AssetSource("Tap.mp3"));

  void makeMove(int index) async {
    if (board[index] != "") return;
    await playTapSound();

    setState(() {
      board[index] = currentPlayer;
    });

    if (_checkWinner(board, currentPlayer)) {
      currentPlayer == "X" ? scoreX++ : scoreO++;
      showWinnerDialog("$currentPlayer Wins!");
      return;
    } else if (!board.contains("")) {
      draws++;
      showWinnerDialog("Draw");
      return;
    }

    if (widget.vsComputer) {
      currentPlayer = currentPlayer == "X" ? "O" : "X";
      if (currentPlayer != widget.playerSymbol) {
        Future.delayed(Duration(milliseconds: 500), () => computerMove());
      }
    } else {
      currentPlayer = currentPlayer == "X" ? "O" : "X";
    }
  }

  void computerMove() {
    int move = getComputerMove();
    makeMove(move);
  }

  int getComputerMove() {
    List<int> empty = [];
    for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);

    double smartChance;
    switch (widget.difficulty) {
      case "Easy":
        smartChance = 0.4;
        break;
      case "Medium":
        smartChance = 0.7;
        break;
      case "Hard":
        smartChance = 0.9;
        break;
      case "Expert":
        smartChance = 0.99;
        break;
      case "Super Expert":
        smartChance = 1.0;
        break;
      default:
        smartChance = 0.9;
    }

    String opponent = widget.playerSymbol;

    for (int i in empty) {
      List<String> temp = List.from(board);
      temp[i] = currentPlayer;
      if (_checkWinner(temp, currentPlayer)) return i;
    }

    for (int i in empty) {
      List<String> temp = List.from(board);
      temp[i] = opponent;
      if (_checkWinner(temp, opponent)) return i;
    }

    if (Random().nextDouble() < smartChance) {
      if (empty.contains(4)) return 4;
      List<int> corners = [0, 2, 6, 8];
      List<int> availCorners =
          empty.where((i) => corners.contains(i)).toList();
      if (availCorners.isNotEmpty)
        return availCorners[random.nextInt(availCorners.length)];
      List<int> sides = [1, 3, 5, 7];
      List<int> availSides = empty.where((i) => sides.contains(i)).toList();
      if (availSides.isNotEmpty)
        return availSides[random.nextInt(availSides.length)];
    }

    return empty[random.nextInt(empty.length)];
  }

  bool _checkWinner(List<String> b, String player) {
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
      if (b[line[0]] == player &&
          b[line[1]] == player &&
          b[line[2]] == player) return true;
    }
    return false;
  }

  void showWinnerDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade800,
        title: Text(title, style: TextStyle(color: Colors.white)),
        content: Text("Scoreboard:\nX: $scoreX | O: $scoreO | Draws: $draws",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                board = List.filled(9, "");
                currentPlayer = "X";
                if (widget.vsComputer && widget.playerSymbol != "X") {
                  Future.delayed(
                      Duration(milliseconds: 500), () => computerMove());
                }
              });
              Navigator.pop(context);
            },
            child: Text("Replay", style: TextStyle(color: Colors.greenAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => HomeScreen(bgmPlayer: AudioPlayer()..play(AssetSource("bgm.mp3")))));
            },
            child: Text("Home", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        title: Text("Tic Tac Toe"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        shrinkWrap: true,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: 9,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              makeMove(index);
            },
            child: Container(
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  board[index],
                  style: TextStyle(
                    fontSize: 64,
                    color: board[index] == "X"
                        ? Colors.redAccent
                        : Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
