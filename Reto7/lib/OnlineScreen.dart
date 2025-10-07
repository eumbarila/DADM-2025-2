import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reto4/OnlineGame.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({super.key, required this.player1});

  final String player1;

  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();

  Future<void> createRoom() async {
    final code = (Random().nextInt(9000) + 1000).toString(); // Código 4 dígitos
    final roomRef = _firestore.collection('rooms').doc(code);

    await roomRef.set({
      'host': '${widget.player1}',
      'guest': null,
      'board': List.filled(9, ''),
      'turn': 'X',
      'status': 'waiting',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sala creada con código $code')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineGame(playerName: '${widget.player1}', roomCode: code, isHost: true),
      ),
    );

  }

  Future<void> joinRoom() async {
    final code = _codeController.text.trim();
    final roomRef = _firestore.collection('rooms').doc(code);
    final room = await roomRef.get();

    if (!room.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No existe una sala con ese código')),
      );
      return;
    }

    final data = room.data();
    if (data?['guest'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La sala ya está llena')),
      );
      return;
    }

    await roomRef.update({'guest': '${widget.player1}', 'status': 'playing'});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Te uniste a la sala $code')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineGame(playerName: '${widget.player1}', roomCode: code, isHost: false),
      ),
    );

  }

  Future<List<Map<String, dynamic>>> fetchAvailableRooms() async {
    final query = await _firestore
        .collection('rooms')
        .where('status', isEqualTo: 'waiting')
        .get();

    return query.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> exploreRooms() async {
    final rooms = await fetchAvailableRooms();

    if (rooms.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('No hay salas disponibles'),
          content: Text('Por ahora no hay ninguna sala esperando jugador.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎮 Salas disponibles'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text('Sala ${room['id']}'),
                  subtitle: Text('Host: ${room['host'] ?? 'Desconocido'}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _firestore
                          .collection('rooms')
                          .doc(room['id'])
                          .update({'guest': '${widget.player1}', 'status': 'playing'});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                            Text('Te uniste a la sala ${room['id']}')),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnlineGame(playerName: '${widget.player1}', roomCode: '${room['id']}', isHost: false),
                        ),
                      );
                    },
                    child: const Text('Unirse'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  LinearGradient linear=LinearGradient(
      colors: [Color(0xFF0DE0F3), Color(0xFF175965)],
      stops: [0.0,1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient:linear
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child:Center(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIC-TAC-UN',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Color(0xFFE66D21),
                          fontWeight: FontWeight.w900,
                          fontSize: 55,
                        ),
                      ),
                    ),
                    Text(
                      '(Online)',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Color(0xFFE66D21),
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    Text(
                      'Código de sala:',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Color(0xFFFEA02F),
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    TextField(
                      maxLength: 4,
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: 'Ej: 1234',
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Color(0xFFFEA02F),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFE66D21),    // Border color when focused/tapped
                            width: 4.0,                  // Border width
                          ),
                        ),
                        hintStyle: TextStyle(
                            color: Colors.black45
                        ),
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 45),
                    Container(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: joinRoom,
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(50)),
                            backgroundColor: Color(0xFFFEA02F),
                            foregroundColor:Color(0xFFFFFFFF)
                        ),
                        child: Text(
                            'Unirse a sala',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900
                                )
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: createRoom,
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(50)),
                            backgroundColor: Color(0xFFFEA02F),
                            foregroundColor:Color(0xFFFFFFFF)
                        ),
                        child: Text(
                            'Crear sala',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900
                                )
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: exploreRooms,
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(50)),
                            backgroundColor: Color(0xFFFEA02F),
                            foregroundColor:Color(0xFFFFFFFF)
                        ),
                        child: Text(
                            'Explorar salas',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900
                                )
                            )
                        ),
                      ),
                    )
                  ]
              ),
            ),
          ) ,
        ),
      ),
    );
  }
}