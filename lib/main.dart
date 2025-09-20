import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(MyApp());
}

// ================= MY APP =================
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe Pro',
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
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(bgmPlayer: bgmPlayer),
          ),
        );
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
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Transform.scale(
            scale: _animation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logo.png", width: 120, height: 120),
                SizedBox(height: 10),
                Text(
                  "Tic Tac Toe Pro",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
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

// ================= HOME SCREEN =================
class HomeScreen extends StatefulWidget {
  final AudioPlayer bgmPlayer;
  HomeScreen({required this.bgmPlayer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int playerWins = 0;
  int computerWins = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  void loadScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      playerWins = prefs.getInt("playerWins") ?? 0;
      computerWins = prefs.getInt("computerWins") ?? 0;
      draws = prefs.getInt("draws") ?? 0;
    });
  }

  void navigateTo(BuildContext context, Widget screen) {
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
              end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tic Tac Toe Pro",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              SizedBox(height: 20),
              Text(
                "Player: $playerWins  |  Computer: $computerWins  |  Draws: $draws",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () => navigateTo(
                      context, ModeSelectionScreen(bgmPlayer: widget.bgmPlayer)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.greenAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("▶ Play Game",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () =>
                      navigateTo(context, TwoPlayerSymbolSelectionScreen()),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.blueAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("👥 2 Player Game",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => navigateTo(
                      context, SettingsScreen(bgmPlayer: widget.bgmPlayer)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.orangeAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("⚙ Settings",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => navigateTo(context, AboutScreen()),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(220, 50),
                      backgroundColor: Colors.purpleAccent.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("🏆 About",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= MODE SELECTION SCREEN =================
class ModeSelectionScreen extends StatelessWidget {
  final AudioPlayer bgmPlayer;
  ModeSelectionScreen({required this.bgmPlayer});

  void startGame(BuildContext context, String difficulty) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => SymbolSelectionScreen(
                vsComputer: true, difficulty: difficulty, bgmPlayer: bgmPlayer)));
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
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () => startGame(context, mode),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.purpleAccent.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(mode, style: TextStyle(fontSize: 18)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ================= SYMBOL SELECTION SCREEN =================
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

// ================= 2 PLAYER SYMBOL SELECTION =================
class TwoPlayerSymbolSelectionScreen extends StatelessWidget {
  void startGame(BuildContext context, String playerSymbol) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                GameScreen(vsComputer: false, playerSymbol: playerSymbol)));
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
                      fontWeight: FontWeight.bold)),
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

// ================= GAME SCREEN =================
class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final String playerSymbol;
  final String? difficulty;
  final AudioPlayer? bgmPlayer;

  GameScreen(
      {required this.vsComputer,
      required this.playerSymbol,
      this.difficulty,
      this.bgmPlayer});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, "");
  bool playerTurn = true;
  late String aiSymbol;
  late String humanSymbol;
  ConfettiController? confettiController;
  bool sfxOn = true;

  @override
  void initState() {
    super.initState();
    humanSymbol = widget.playerSymbol;
    aiSymbol = (humanSymbol == "X") ? "O" : "X";
    confettiController = ConfettiController(duration: Duration(seconds: 2));
    loadSFXSetting();
  }

  void loadSFXSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sfxOn = prefs.getBool("sfxOn") ?? true;
    });
  }

  @override
  void dispose() {
    confettiController?.dispose();
    super.dispose();
  }

  void makeMove(int index) async {
    if (board[index] == "") {
      setState(() {
        board[index] = playerTurn ? humanSymbol : (widget.vsComputer ? aiSymbol : "O");
      });

      // Play tap sound
      playSFX("Tap.mp3");

      if (checkWinner(board[index])) {
        // Play celebration sound
        playSFX("Celebration.mp3");
        confettiController?.play();
        saveScore(board[index]);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (!board.contains("")) {
        // Play draw sound
        playSFX("draw.mp3");
        saveScore("Draw");
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        if (widget.vsComputer && !playerTurn) {
          Future.delayed(Duration(milliseconds: 500), () => computerMove());
        }
        playerTurn = !playerTurn;
      }
    }
  }

  void computerMove() {
    List<int> empty = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") empty.add(i);
    }
    if (empty.isNotEmpty) {
      int move = empty[Random().nextInt(empty.length)];
      makeMove(move);
    }
  }

  bool checkWinner(String symbol) {
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
    for (var w in wins) {
      if (board[w[0]] == symbol &&
          board[w[1]] == symbol &&
          board[w[2]] == symbol) return true;
    }
    return false;
  }

  void saveScore(String winner) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (winner == humanSymbol) {
      int val = prefs.getInt("playerWins") ?? 0;
      prefs.setInt("playerWins", val + 1);
    } else if (winner == aiSymbol) {
      int val = prefs.getInt("computerWins") ?? 0;
      prefs.setInt("computerWins", val + 1);
    } else {
      int val = prefs.getInt("draws") ?? 0;
      prefs.setInt("draws", val + 1);
    }
  }

  Future<void> playSFX(String filename) async {
    if (!sfxOn) return;
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource(filename));
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
                  "Tic Tac Toe Pro",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                buildBoard(),
              ],
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController!,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [Colors.yellow, Colors.red, Colors.green, Colors.blue],
              ))
        ],
      ),
    );
  }

  Widget buildBoard() {
    return Container(
      width: 300,
      height: 300,
      child: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: 9,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => makeMove(index),
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(board[index],
                        style: TextStyle(
                            color: board[index] == "X"
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            fontSize: 48,
                            fontWeight: FontWeight.bold))),
              ),
            );
          }),
    );
  }
}
// ================= SETTINGS SCREEN =================
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

  void toggleBGM(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bgmOn = value;
      prefs.setBool("bgmOn", bgmOn);
      if (bgmOn) {
        widget.bgmPlayer.resume();
      } else {
        widget.bgmPlayer.pause();
      }
    });
  }

  void toggleSFX(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sfxOn = value;
      prefs.setBool("sfxOn", sfxOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Background Music",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              value: bgmOn,
              onChanged: toggleBGM,
            ),
            SwitchListTile(
              title: Text("Sound Effects",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              value: sfxOn,
              onChanged: toggleSFX,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.purpleAccent.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("Back",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

// ================= ABOUT SCREEN =================
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        backgroundColor: Colors.deepPurple,
      ),
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
            Text(
              "Tic Tac Toe Pro",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Version: 1.0.0",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Developed by Quantum Games",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              "Tic Tac Toe Pro is a fun and challenging game where you can:",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "- Play vs Computer (Easy, Medium, Hard, Expert)\n"
              "- Play 2 Player Mode with friends\n"
              "- Enjoy sound effects & background music\n"
              "- Celebrate wins with confetti\n"
              "- Track your scores",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Thank you for playing! 🎉",
              style: TextStyle(color: Colors.yellowAccent, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= OPTIONAL GLOBAL SFX FUNCTION =================
Future<void> playSFX(String filename) async {
  AudioPlayer player = AudioPlayer();
  await player.play(AssetSource(filename));
}
