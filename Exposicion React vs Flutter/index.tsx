import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';

const initialBoard = Array(9).fill(null);

const TicTacToeGame = () => {
  const [board, setBoard] = useState(initialBoard);
  const [isPlayerTurn, setIsPlayerTurn] = useState(true);
  const [winner, setWinner] = useState<'X' | 'O' | 'draw' | null>(null);

  useEffect(() => {
    checkWinner();
  }, [board]);

  const checkWinner = () => {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (let i = 0; i < lines.length; i++) {
      const [a, b, c] = lines[i];
      if (board[a] && board[a] === board[b] && board[a] === board[c]) {
        setWinner(board[a]);
        return;
      }
    }

    if (board.every((square) => square)) {
      setWinner('draw');
    }
  };

  const handleSquarePress = (index: any) => {
    if (!board[index] && !winner) {
      const newBoard = [...board];
      newBoard[index] = isPlayerTurn ? 'X' : 'O';
      setBoard(newBoard);
      setIsPlayerTurn(!isPlayerTurn);
    }
  };

  const handleReset = () => {
    setBoard(initialBoard);
    setIsPlayerTurn(true);
    setWinner(null);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Tic Tac Toe</Text>
      <Text style={styles.title}>React Native</Text>
      <View style={styles.board}>
        {[0, 1, 2, 3, 4, 5, 6, 7, 8].map((index) => (
          <TouchableOpacity
            key={index}
            style={styles.square}
            onPress={() => handleSquarePress(index)}
            disabled={board[index] !== null || winner !== null}
          >
            <Text
              style={[
                styles.squareText,
                { color: board[index] === 'X' ? '#435585' : '#E5C3A6' },
              ]}
            >
              {board[index] ? board[index].toString() : ''}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
      <Text style={styles.result}>
        {winner
          ? winner === 'draw'
            ? "Empate :/"
            : `El jugador ${winner} ganó!`
          : `Es el turno de ${isPlayerTurn ? 'X' : 'O'}`}
      </Text>
      <TouchableOpacity style={styles.button} onPress={handleReset}>
        <Text style={styles.buttonText}>Nuevo juego</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  title: {
    color: '#fff',
    fontSize: 36,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 10,
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000000ff',
  },
  board: {
    width: 320,
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  square: {
    width: '30%',
    height: "30%",
    aspectRatio: 1,
    borderWidth: 2,
    borderColor: '#363062',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  squareText: {
    fontSize: 36,
    fontWeight: 'bold',
  },
  result: {
    marginTop: 10,
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#363062',
    marginBottom: 20,
  },
  button: {
    backgroundColor: '#363062',
    paddingHorizontal: 40,
    paddingVertical: 15,
    marginHorizontal: 60,
    borderRadius: 5,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'semibold',
    textAlign: 'center',
  },
});

export default TicTacToeGame;
