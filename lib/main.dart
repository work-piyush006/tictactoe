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
  AudioPlayer? bgmPlayer;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> particles = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();

    // Background music
    bgmPlayer = AudioPlayer();
    bgmPlayer!.setReleaseMode(ReleaseMode.loop);
    bgmPlayer!.play(AssetSource("assets/bgm.mp3"));

    // Logo animation
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);

    // Floating particles
    for (int i = 0; i < 50; i++) {
      particles.add(Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    }

    // Navigate to HomeScreen after delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  void dispose() {
    bgmPlayer?.stop();
    bgmPlayer?.dispose();
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
          CustomPaint(painter: FloatingXO(particles: particles)),
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
                    "X & O\nUltimate Battle ⚡",
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
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================= HOME SCREEN =================
class HomeScreen extends StatelessWidget {
  void navigateToGame(BuildContext context, bool vsComputer) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SymbolSelectionScreen(vsComputer: vsComputer)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.black],
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
                            Random().nextDouble() * 800))))),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose Mode to Start 🎮",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => navigateToGame(context, true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 50),
                    backgroundColor: Colors.greenAccent,
                  ),
                  child: Text("🤖 Play vs Computer"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => navigateToGame(context, false),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 50),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text("👬 Play with Friends"),
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
  SymbolSelectionScreen({required this.vsComputer});

  void startGame(BuildContext context, String playerSymbol) {
    if (vsComputer) {
      showDialog(
        context: context,
        builder: (_) => DifficultyDialog(playerSymbol: playerSymbol),
      );
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => GameScreen(
                  vsComputer: false,
                  playerSymbol: playerSymbol,
                  difficulty: "Easy")));
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
                      minimumSize: Size(100, 100)),
                  child: Text("X", style: TextStyle(fontSize: 36)),
                ),
                SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () => startGame(context, "O"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(100, 100)),
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
  DifficultyDialog({required this.playerSymbol});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Difficulty Level"),
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
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => GameScreen(
                    vsComputer: true,
                    playerSymbol: playerSymbol,
                    difficulty: difficulty)));
      },
      child: Text(difficulty),
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

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, "");
  String currentPlayer = "";
  Random random = Random();
  AudioPlayer tapPlayer = AudioPlayer();
  AudioPlayer celebrationPlayer = AudioPlayer();

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

  void playTapSound() => tapPlayer.play(AssetSource("assets/Tap.mp3"));
  void playCelebration() =>
      celebrationPlayer.play(AssetSource("assets/Celebration.mp3"));

  void makeMove(int index) {
    if (board[index] != "") return;
    playTapSound();

    setState(() {
      board[index] = currentPlayer;
    });

    if (_checkWinner(board, currentPlayer)) {
      playCelebration();
      if (currentPlayer == "X")
        scoreX++;
      else
        scoreO++;
      showWinnerDialog("$currentPlayer Wins!");
      return;
    } else if (!board.contains("")) {
      draws++;
      showWinnerDialog("Draw 🤝");
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
      if (b[line[0]] == player && b[line[1]] == player && b[line[2]] == player)
        return true;
    }
    return false;
  }

  void showWinnerDialog(String title) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(
                  "Scoreboard:\nX: $scoreX | O: $scoreO | Draws: $draws"),
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
                  child: Text("Replay"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  child: Text("Home"),
                ),
              ],
            ));
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: GridView.builder(
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
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                            fontSize: 64,
                            color: board[index] == "X"
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
