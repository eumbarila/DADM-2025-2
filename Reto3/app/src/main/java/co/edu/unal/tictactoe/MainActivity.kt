 package co.edu.unal.tictactoe

import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import co.edu.unal.tictactoe.databinding.ActivityMainBinding
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

 class MainActivity : AppCompatActivity() {

    enum class Turn{
        O,
        X
    }

    private var firstTurn = Turn.X
    private var actualTurn = Turn.X
    private var xscore = 0
    private var oscore = 0
    private var tiescore = 0
    private lateinit var binding: ActivityMainBinding

    private var boardList = mutableListOf<Button>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        initboard()
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
    }

    private fun initboard() {
        boardList.add(binding.a1)
        boardList.add(binding.a2)
        boardList.add(binding.a3)
        boardList.add(binding.b1)
        boardList.add(binding.b2)
        boardList.add(binding.b3)
        boardList.add(binding.c1)
        boardList.add(binding.c2)
        boardList.add(binding.c3)
    }

     private fun cpuMove() {
         lifecycleScope.launch {
             delay(1000)

             for (button in boardList.filter { it.text == "" }) {
                 if (makeMove(button, O)) return@launch
                 button.text = ""
             }

             for (button in boardList.filter { it.text == "" }) {
                 button.text = X
                 if (checkForVictory(X)) {
                     button.text = ""
                     makeMove(button, O)
                     return@launch
                 }
                 button.text = ""
             }

             val emptyButtons = boardList.filter { it.text == "" }
             if (emptyButtons.isNotEmpty()) {
                 makeMove(emptyButtons.random(), O)
             }
         }
     }

     private fun fullBoard(): Boolean {
         for(button in boardList){
             if(button.text == "")
                 return false
         }
         return true
     }

     fun boardTapped(view: View) {
         if (actualTurn == Turn.O) return
         if (view !is Button) return

         if (makeMove(view, X)) return

         if (actualTurn == Turn.O) {
             cpuMove()
         }
     }


     private fun makeMove(button: Button, symbol: String): Boolean {
         if (button.text != "") return false

         button.text = symbol

         if (checkForVictory(symbol)) {
             if (symbol == X) xscore++ else oscore++
             result("¡¡¡$symbol gana!!!")
             return true
         }

         if (fullBoard()) {
             tiescore++
             result("Empate :/")
             return true
         }

         actualTurn = if (symbol == X) Turn.O else Turn.X
         setTurnLabel()

         return false
     }


     private fun checkForVictory(s: String): Boolean {
         if(match(binding.a1,s) && match(binding.a2, s) && match(binding.a3, s))
             return true
         if(match(binding.b1,s) && match(binding.b2, s) && match(binding.b3, s))
             return true
         if(match(binding.c1,s) && match(binding.c2, s) && match(binding.c3, s))
             return true

         if(match(binding.a1,s) && match(binding.b1, s) && match(binding.c1, s))
             return true
         if(match(binding.a2,s) && match(binding.b2, s) && match(binding.c2, s))
             return true
         if(match(binding.a3,s) && match(binding.b3, s) && match(binding.c3, s))
             return true

         if(match(binding.a1,s) && match(binding.b2, s) && match(binding.c3, s))
             return true
         if(match(binding.a3,s) && match(binding.b2, s) && match(binding.c1, s))
             return true

         return false
     }

     private fun match(button: Button, symbol: String): Boolean = button.text == symbol

     private fun result(title: String) {
         AlertDialog.Builder(this)
             .setTitle(title)
             .setPositiveButton("Nuevo juego"){
                 _,_ ->
                 resetBoard()
             }
             .setCancelable(false)
             .show()
     }

     private fun resetBoard(){
         for(button in boardList){
             button.text = ""
         }

         firstTurn = if (firstTurn == Turn.X) Turn.O else Turn.X
         actualTurn = firstTurn

         setTurnLabel()

         if (actualTurn == Turn.O) {
             cpuMove()
         }
     }

     private fun setTurnLabel() {
         var turnText = ""
         var scoreText = "Humano: $xscore  Empates: $tiescore  Android: $oscore"

         if(actualTurn == Turn.X)
             turnText = "Es turno de $X"
         else if(actualTurn == Turn.O)
             turnText = "Es turno de $O"

         binding.overallScore.text = scoreText
         binding.turnTV.text = turnText
     }

     companion object{
         const val X = "X"
         const val O = "O"
     }
 }