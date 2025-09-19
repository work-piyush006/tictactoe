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

    // BGM player start
    bgmPlayer = AudioPlayer();
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
    bgmPlayer.play(AssetSource("bgm.mp3"));

    // Floating animation
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

    // Particles
    for (int i = 0; i < 50; i++) {
      particles.add(
          Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    }

    // Navigate to Home
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> particles = [];
  Random random = Random();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
          ..addListener(() {
            setState(() {});
          });
    _controller.repeat(reverse: true);

    for (int i = 0; i < 40; i++) {
      particles.add(
          Offset(random.nextDouble() * 400, random.nextDouble() * 800));
    }

    // Resume BGM if coming back
    widget.bgmPlayer.resume();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToGame(bool vsComputer) {
    widget.bgmPlayer.stop(); // Game mein music band
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              SymbolSelectionScreen(vsComputer: vsComputer, bgmPlayer: widget.bgmPlayer)),
    ).then((_) {
      // Wapas aate hi music resume
      widget.bgmPlayer.play(AssetSource("bgm.mp3"));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _homeTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/logo.png", width: 120, height: 120),
        SizedBox(height: 10),
        Text(
          "T i c T a c T o e",
          style: TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
        SizedBox(height: 50),
        ElevatedButton(
          onPressed: () => navigateToGame(true),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(220, 50),
            backgroundColor: Colors.greenAccent.shade700,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Play vs Computer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => navigateToGame(false),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(220, 50),
            backgroundColor: Colors.blueAccent.shade700,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Play with Friends",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _aboutTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/logo.png", width: 100, height: 100),
          SizedBox(height: 10),
          Text("Made by G A PRODUCTION",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          SizedBox(height: 4),
          Text("New Update will Come Soon",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 4),
          Text("Multiplayer (online)",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 10),
          Text("Version 1.0.0", style: TextStyle(color: Colors.white54, fontSize: 12)),
          Text("Tips: Tap cells to play", style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _tabs = [_homeTab(), _aboutTab()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text("Home"),
        actions: [
          IconButton(
              icon: Text("🚪", style: TextStyle(fontSize: 24)),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: FloatingXO(particles: particles),
            ),
          ),
          _tabs[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
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
                  shadows: [Shadow(blurRadius: 3, color: Colors.black45, offset: Offset(1, 1))]),
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
        children: ["Easy","Medium","Hard","Expert","Super Expert"]
            .map((diff) => Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

  GameScreen({
    required this.vsComputer,
    required this.playerSymbol,
    required this.difficulty,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X";
  Random random = Random();
  final AudioPlayer tapPlayer = AudioPlayer();
  final AudioPlayer celebrationPlayer = AudioPlayer();
  int scoreX = 0;
  int scoreO = 0;
  int draws = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.vsComputer && widget.playerSymbol != "X") {
      Future.delayed(Duration(milliseconds: 500), () => computerMove());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> playTapSound() async =>
      await tapPlayer.play(AssetSource("Tap.mp3"));

  Future<void> playCelebration() async =>
      await celebrationPlayer.play(AssetSource("Celebration.mp3"));

  void makeMove(int index) async {
    if (gameOver || board[index] != "") return;

    if (widget.vsComputer && currentPlayer != widget.playerSymbol) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("💢 Wait for your turn"),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Okay"))
                ],
              ));
      return;
    }

    await playTapSound();
    setState(() => board[index] = currentPlayer);

    if (_checkWinner(board, currentPlayer)) {
      currentPlayer == "X" ? scoreX++ : scoreO++;
      gameOver = true;
      await playCelebration();
      showWinnerDialog("$currentPlayer Wins!");
      return;
    } else if (!board.contains("")) {
      draws++;
      gameOver = true;
      await playCelebration();
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
    if (gameOver) return;
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
      List<int> availCorners = empty.where((i) => corners.contains(i)).toList();
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
      [2, 4, 6],
    ];
    for (var line in wins) {
      if (b[line[0]] == player &&
          b[line[1]] == player &&
          b[line[2]] == player) {
        return true;
      }
    }
    return false;
  }

  void showWinnerDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade800,
        title: Center(
            child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 22),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Score X: $scoreX  |  O: $scoreO  |  Draws: $draws",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                resetBoard();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700),
              child: Text("Play Again"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Back to Home
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700),
              child: Text("Home"),
            )
          ],
        ),
      ),
    );
  }

  void resetBoard() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      gameOver = false;
      if (widget.vsComputer && widget.playerSymbol != "X") {
        Future.delayed(Duration(milliseconds: 500), () => computerMove());
      }
    });
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => makeMove(index),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white70),
            color: Colors.deepPurple.shade700),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
                fontSize: 50,
                color: board[index] == "X" ? Colors.red : Colors.blue),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Home pe jaate hi BGM resume
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.vsComputer
              ? "Tic Tac Toe vs Computer"
              : "Tic Tac Toe vs Friend"),
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Current Turn: $currentPlayer",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (_, index) => buildCell(index),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Score X: $scoreX  |  O: $scoreO  |  Draws: $draws",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade900,
      ),
    );
  }
}
