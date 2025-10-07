import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reto4/Game.dart';
import 'package:reto4/OnlineScreen.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State createState() => _ScreenState();
}

class _ScreenState extends State {

  String? player1;

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
                    SizedBox(height: 50),

                    Text(
                      'Inserta tu nombre:',
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
                      maxLength: 7,
                      onChanged: (value){
                        setState(() {
                          player1 = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Nombre',
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
                        onPressed: () async{
                          if ((player1 ?? "").isNotEmpty) {
                            await _audioPlayer.play(
                                AssetSource("new_game.mp3"));
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) =>
                                Game(
                                  player1: player1!,
                                  player2: "Android",
                                )));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(50)),
                            backgroundColor: Color(0xFFFEA02F),
                            foregroundColor:Color(0xFFFFFFFF)
                        ),
                        child: Text(
                            'Nuevo juego',
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
                        onPressed: () async{
                          if ((player1 ?? "").isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) =>
                                OnlineScreen(
                                  player1: player1!,
                                )));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(50)),
                            backgroundColor: Color(0xFFFEA02F),
                            foregroundColor:Color(0xFFFFFFFF)
                        ),
                        child: Text(
                            'Modo online',
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



class HeadingText extends StatelessWidget {
  const HeadingText({super.key, required this.name});


  final String name;
  @override
  Widget build(BuildContext context) {
    return  Text(
        name,
        style:GoogleFonts.openSans(
            textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 25
            )
        )
    );
  }
}