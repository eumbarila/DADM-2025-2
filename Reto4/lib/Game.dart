import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Screen.dart';

enum Difficulty { easy, medium, hard }

class Game extends StatefulWidget {
  const Game({super.key, required this.player1, required this.player2});

  final String player1;
  final String player2;


  @override
  State createState() => _GameState();
}

class _GameState extends State<Game> {

  final String player1val="X";
  final String player2val="O";
  List<String> board = List.filled(9, '');

  int winsPlayer1 = 0;
  int winsPlayer2 = 0;
  int draws = 0;

  String? currentPlayer;
  String? currentPlayerval;
  bool gameOver = false;

  Difficulty currentDifficulty = Difficulty.easy;

  LinearGradient linear=LinearGradient(
    colors: [Color(0xFF0DE0F3), Color(0xFF175965)],
    stops: [0.0,1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter
  );

  @override
  void initState() {
    super.initState();
    intializeGame();
  }

  GameOverMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Color(0xFF175965),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            actions: [
              Center(
                child: Text("$message", style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white
                ),),
              ),
              SizedBox(height: 40,),
              Center(
                child: Container(
                  width: 250.0,
                  height: 55.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Color(0xFFFEA02F),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      )
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {

                        intializeGame();
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.restart_alt,
                          size: 40.0,
                          color: Colors.white,),
                        Text('Nuevo juego', style: TextStyle(
                            fontSize: 27.0, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40,)
            ],
          ),
        );
      }
    );
  }



  void intializeGame(){
    if(currentPlayerval == player2val) {
      currentPlayer = '${widget.player1} (X)';
      currentPlayerval = player1val;
    } else {
      currentPlayer = '${widget.player2} (O)';
      currentPlayerval = player2val;
      _autoPlay();
    }
    gameOver=false;
    board=["","","","","","","","",""];
  }

  void _handleTap(int index) {
    if (board[index] != '' || gameOver) return;

    setState(() {
      board[index] = currentPlayerval!;
      if (_checkWinner(currentPlayerval!)) {
        gameOver = true;
        if (currentPlayerval == "X") {
          winsPlayer1++;
          GameOverMessage("${widget.player1} ganó (X)");
        } else {
          winsPlayer2++;
          GameOverMessage("${widget.player2} ganó (O)");
        }
      } else if (!board.contains('')) {
        gameOver = true;
        GameOverMessage("Empate :/");
        draws++;
      } else {
        currentPlayerval = currentPlayerval == "X" ? "O" : "X";
        currentPlayer = currentPlayer == '${widget.player1} (X)' ? '${widget.player2} (O)' : '${widget.player1} (X)';
        if (currentPlayerval == "O") {
          _autoPlay();
        }
      }
    });
  }

  void _autoPlay() async {
    await Future.delayed(Duration(milliseconds: 600));

    int? move;
    switch (currentDifficulty) {
      case Difficulty.easy:
        move = _randomMove();
        break;
      case Difficulty.medium:
        move = _mediumMove();
        break;
      case Difficulty.hard:
        move = _bestMove();
        break;
    }

    if (move != null) {
      _handleTap(move);
    }
  }

  int? _randomMove() {
    final empty = List.generate(board.length, (i) => i)
        .where((i) => board[i] == '')
        .toList();
    if (empty.isEmpty) return null;
    return empty[Random().nextInt(empty.length)];
  }

  int? _mediumMove() {
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = "O";
        if (_checkWinner("O")) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }

    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = "X";
        if (_checkWinner("X")) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }

    return _randomMove();
  }

  int? _bestMove() {
    int bestScore = -1000;
    int? move;

    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        board[i] = "O";
        int score = _minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }

    return move;
  }

  int _minimax(List<String> newBoard, int depth, bool isMaximizing) {
    if (_checkWinner("O")) return 10 - depth;
    if (_checkWinner("X")) return depth - 10;
    if (!newBoard.contains('')) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = "O";
          int score = _minimax(newBoard, depth + 1, false);
          newBoard[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = "X";
          int score = _minimax(newBoard, depth + 1, true);
          newBoard[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }


  bool _checkWinner(String player) {
    List<List<int>> winPositions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pos in winPositions) {
      if (board[pos[0]] == player &&
          board[pos[1]] == player &&
          board[pos[2]] == player) {
        return true;
      }
    }
    return false;
  }

  setSelectedRadioTile(int value) {
    setState(() {
    });
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF175965),
          title: Text("Seleccionar dificultad", style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white
          ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Difficulty>(
                activeColor: Color(0xFF0DE0F3),
                title: Text("Fácil", style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white
                ),),
                value: Difficulty.easy,
                groupValue: currentDifficulty,
                onChanged: (value) {
                  setState(() => currentDifficulty = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Difficulty>(
                activeColor: Color(0xFF0DE0F3),
                title: Text("Medio", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white
                ),),
                value: Difficulty.medium,
                groupValue: currentDifficulty,
                onChanged: (value) {
                  setState(() => currentDifficulty = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Difficulty>(
                activeColor: Color(0xFF0DE0F3),
                title: Text("Difícil", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white
                ),),
                value: Difficulty.hard,
                groupValue: currentDifficulty,
                onChanged: (value) {
                  setState(() => currentDifficulty = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }



  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: linear
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 95),
                Column(
                  children:[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                          "${widget.player1}: ${winsPlayer1} | Empate: ${draws} | ${widget.player2}: ${winsPlayer2}",
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Color(0xFFFEA02F),
                              fontWeight: FontWeight.w900,
                              fontSize: 23,

                            ),
                          )
                      ),
                    ]
                  ),

                    Text(
                      'Es el turno de:',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Color(0xFFFEA02F),
                          fontWeight: FontWeight.w900,
                          fontSize: 55,

                        ),
                      )
                    ),
                    Text(
                      currentPlayer!,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Color(0xFFFEA02F),
                          fontWeight: FontWeight.w900,
                          fontSize: 45,

                        ),
                      )
                    ),
                  ]
                ),
                SizedBox(height: 30,),
                Container(
                  width: MediaQuery.of(context).size.height / 2,
                  height: MediaQuery.of(context).size.height / 2,
                  margin:EdgeInsets.all(10),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3
                    ),
                    itemCount: board.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        onTap: () => _handleTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:Color(0xFF175965),
                          ),
                          margin: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              board[index],
                              style:GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Color(0xFFEBD9C8),
                                  fontSize: 65,
                                  fontWeight: FontWeight.bold,
                                )
                              )
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Screen()),
                        );
                      },
                      child: Text("Nuevo juego"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showDifficultyDialog(context);
                      },
                      child: Text("Dificultad"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: Text("Salir"),
                    ),
                  ],
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}