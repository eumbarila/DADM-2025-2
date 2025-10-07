import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'OnlineScreen.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

class OnlineGame extends StatefulWidget {
  final String roomCode;
  final bool isHost;
  final String playerName;

  const OnlineGame({
    Key? key,
    required this.roomCode,
    required this.isHost,
    required this.playerName,
  }) : super(key: key);

  @override
  State<OnlineGame> createState() => _OnlineGameState();
}

class _OnlineGameState extends State<OnlineGame> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String player1val = "X";
  final String player2val = "O";

  bool gameOver = false;

  LinearGradient linear = const LinearGradient(
    colors: [Color(0xFF0DE0F3), Color(0xFF175965)],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  void _playSound(String player) async {
    if (player == "X") {
      await _audioPlayer.play(AssetSource("x_tone.mp3"));
    } else if (player == "O") {
      await _audioPlayer.play(AssetSource("o_tone.mp3"));
    }
  }

  Future<void> makeMove(int index, List<dynamic> board, String currentTurn) async {
    if (gameOver) return;

    final roomRef = _firestore.collection('rooms').doc(widget.roomCode);
    final playerSymbol = widget.isHost ? player1val : player2val;

    // Validar turno y posición vacía
    if (currentTurn != playerSymbol || board[index] != '') return;

    board[index] = playerSymbol;
    _playSound(playerSymbol);

    final winner = _checkWinner(board, playerSymbol);
    final nextTurn = playerSymbol == 'X' ? 'O' : 'X';

    if (winner != null) {
      await roomRef.update({
        'board': board,
        'status': 'finished',
        'winner': winner,
      });
    } else if (!board.contains('')) {
      await roomRef.update({
        'board': board,
        'status': 'finished',
        'winner': 'draw',
      });
    } else {
      await roomRef.update({
        'board': board,
        'turn': nextTurn,
      });
    }
  }

  String? _checkWinner(List board, String player) {
    final List<List<int>> winPositions = [
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
        return player;
      }
    }
    return null;
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF175965),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Volver al menú", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }



  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final roomRef = _firestore.collection('rooms').doc(widget.roomCode);

    return Scaffold(
      appBar: AppBar(
        title: Text("Sala ${widget.roomCode}"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: linear),
        child: StreamBuilder<DocumentSnapshot>(
          stream: roomRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final board = List<String>.from(data['board']);
            final turn = data['turn'];
            final status = data['status'];
            final guest = data['guest'] ?? '';
            final host = data['host'];
            final winner = data['winner'] ?? '';

            if (status == 'finished' && !gameOver) {
              gameOver = true;
              Future.delayed(const Duration(milliseconds: 300), () {
                if (winner == 'draw') {
                  _showGameOverDialog("Empate :/");
                } else if (winner == "X"){
                  _showGameOverDialog("¡$host ganó!");
                } else {
                  _showGameOverDialog("¡$guest ganó!");
                }
              });
            }

            final playerSymbol = widget.isHost ? player1val : player2val;
            final isMyTurn = (turn == playerSymbol) && status != 'finished';

            return SingleChildScrollView(
              child: Center(
                child: isLandscape
                    ? _buildLandscapeLayout(
                  board: board,
                  isMyTurn: isMyTurn,
                  turn: turn,
                  status: status,
                  guest: guest,
                  host: host,
                  winner: winner,
                )
                    : _buildPortraitLayout(
                  board: board,
                  isMyTurn: isMyTurn,
                  turn: turn,
                  status: status,
                  guest: guest,
                  host: host,
                  winner: winner,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout({
    required List<String> board,
    required bool isMyTurn,
    required String turn,
    required String status,
    required String guest,
    required String host,
    required String winner,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            Text(
              status == 'waiting' ? "Esperando al otro jugador..." : 'Es el turno de:',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: Color(0xFFFEA02F),
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
            ),
            if (status != 'waiting')
              Text(
                turn == player1val ? host : guest,
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Color(0xFFFEA02F),
                    fontWeight: FontWeight.w900,
                    fontSize: 45,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          width: MediaQuery.of(context).size.height / 2,
          height: MediaQuery.of(context).size.height / 2,
          margin: const EdgeInsets.all(10),
          child: IgnorePointer(
            ignoring: !isMyTurn,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: board.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => makeMove(index, board, turn),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF175965),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        board[index],
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            color: Color(0xFFEBD9C8),
                            fontSize: 65,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (!isMyTurn && status != 'finished' && status != 'waiting')
          const Text(
            "Esperando tu turno...",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                OnlineScreen(player1: widget.playerName);
              },
              child: const Text("Nueva sala"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Salir"),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLandscapeLayout({
    required List<String> board,
    required bool isMyTurn,
    required String turn,
    required String status,
    required String guest,
    required String host,
    required String winner,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mitad izquierda: Puntajes y botones
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Puntajes
              Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    status == 'waiting' ? "Esperando al otro jugador..." : 'Es el turno de:',
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        color: Color(0xFFFEA02F),
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  if (status != 'waiting')
                    Text(
                      turn == player1val ? host : guest,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          color: Color(0xFFFEA02F),
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              if (!isMyTurn && status != 'finished' && status != 'waiting')
                const Text(
                  "Esperando tu turno...",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              const SizedBox(height: 40),
              // Botones en columna
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      OnlineScreen(player1: widget.playerName);
                    },
                    child: const Text("Nueva sala"),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Salir"),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Mitad derecha: Tablero de juego
        Expanded(
          child: Center(
            child: Container(
              width: 320,
              height: 320,
              margin: const EdgeInsets.all(10),
              child: IgnorePointer(
                ignoring: !isMyTurn,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: board.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => makeMove(index, board, turn),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF175965),
                        ),
                        margin: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            board[index],
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                color: Color(0xFFEBD9C8),
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
