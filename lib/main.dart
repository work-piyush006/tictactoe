import 'dart:math';
import 'package:flutter/material.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
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
          Positioned.fill(child: CustomPaint(painter: FloatingXO())),
          Center(
            child: Text(
              "X & O\nUltimate Battle ⚡",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
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
  final Random random = Random();
  List<Offset> positions = [];
  List<String> symbols = [];

  FloatingXO() {
    for (int i = 0; i < 30; i++) {
      positions.add(Offset(random.nextDouble() * 400, random.nextDouble() * 800));
      symbols.add(random.nextBool() ? "X" : "O");
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < positions.length; i++) {
      TextPainter tp = TextPainter(
        text: TextSpan(
            text: symbols[i],
            style: TextStyle(
                fontSize: 20,
                color: symbols[i] == "X" ? Colors.red.shade200 : Colors.blue.shade200,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, positions[i]);
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
          Positioned.fill(child: CustomPaint(painter: FloatingXO())),
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
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text("Arena Coming Soon 🔐"),
                              content: Text(
                                  "This mode will be available in future updates."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"),
                                )
                              ],
                            ));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(220, 50),
                    backgroundColor: Colors.grey,
                  ),
                  icon: Icon(Icons.lock),
                  label: Text("🔐 Arena (SOON)"),
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
                  vsComputer: false, playerSymbol: playerSymbol, difficulty: "Easy")));
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
                      backgroundColor: Colors.redAccent, minimumSize: Size(100, 100)),
                  child: Text("X", style: TextStyle(fontSize: 36)),
                ),
                SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () => startGame(context, "O"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, minimumSize: Size(100, 100)),
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
          difficultyButton(context, "Super Expert"), // 👈 New Added
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

  @override
  void initState() {
    super.initState();
    currentPlayer = "X";
    if (widget.vsComputer && widget.playerSymbol != "X") {
      Future.delayed(Duration(milliseconds: 500), () => computerMove());
    }
  }

  void makeMove(int index) {
    if (board[index] != "") return;

    setState(() {
      board[index] = currentPlayer;
    });

    if (_checkWinner(board, currentPlayer)) {
      showWinnerDialog("$currentPlayer Wins!");
      return;
    } else if (!board.contains("")) {
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

    String comp = currentPlayer;
    String human = widget.playerSymbol;

    switch (widget.difficulty) {
      case "Easy":
        return empty[random.nextInt(empty.length)];

      case "Medium":
        // block human winning move
        for (int i in empty) {
          board[i] = human;
          if (_checkWinner(board, human)) {
            board[i] = "";
            return i;
          }
          board[i] = "";
        }
        return empty[random.nextInt(empty.length)];

      case "Hard":
        // win if possible
        for (int i in empty) {
          board[i] = comp;
          if (_checkWinner(board, comp)) {
            board[i] = "";
            return i;
          }
          board[i] = "";
        }
        // block human
        for (int i in empty) {
          board[i] = human;
          if (_checkWinner(board, human)) {
            board[i] = "";
            return i;
          }
          board[i] = "";
        }
        return empty[random.nextInt(empty.length)];

      case "Expert":
        int bestScore = -1000;
        int bestMove = empty[0];
        for (int i in empty) {
          board[i] = comp;
          int score = minimax(board, 0, false, comp, human);
          board[i] = "";
          if (score > bestScore) {
            bestScore = score;
            bestMove = i;
          }
        }
        return bestMove;

      case "Super Expert":
        if (random.nextInt(100) == 0) {
          // 1% random
          return empty[random.nextInt(empty.length)];
        } else {
          int bestScore = -1000;
          int bestMove = empty[0];
          for (int i in empty) {
            board[i] = comp;
            int score = minimax(board, 0, false, comp, human);
            board[i] = "";
            if (score > bestScore) {
              bestScore = score;
              bestMove = i;
            }
          }
          return bestMove;
        }

      default:
        return empty[random.nextInt(empty.length)];
    }
  }

  int minimax(List<String> b, int depth, bool isMax, String ai, String human) {
    if (_checkWinner(b, ai)) return 10 - depth; // AI wins
    if (_checkWinner(b, human)) return depth - 10; // Human wins
    if (!b.contains("")) return 0; // Draw

    int bestScore = isMax ? -1000 : 1000;

    for (int i = 0; i < 9; i++) {
      if (b[i] == "") {
        b[i] = isMax ? ai : human;
        int score = minimax(b, depth + 1, !isMax, ai, human);
        b[i] = "";
        if (isMax) {
          bestScore = max(score, bestScore);
        } else {
          bestScore = min(score, bestScore);
        }
      }
    }
    return bestScore;
  }

  bool _checkWinner(List<String> b, String player) {
    List<List<int>> wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
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

  void showWinnerDialog(String title) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      board = List.filled(9, "");
                      currentPlayer = "X";
                      if (widget.vsComputer && widget.playerSymbol != "X") {
                        Future.delayed(Duration(milliseconds: 500),
                            () => computerMove());
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Replay"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  child: Text("Home"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.vsComputer
                  ? "Your Turn: $currentPlayer"
                  : "Player: $currentPlayer",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              child: GridView.builder(
                  itemCount: 9,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => makeMove(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                        ),
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                                color: board[index] == "X"
                                    ? Colors.redAccent
                                    : Colors.blueAccent,
                                fontSize: 48,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
