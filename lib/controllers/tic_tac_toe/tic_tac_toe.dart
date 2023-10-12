import 'dart:math';

import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<List<String>> matrix = List.generate(3, (i) => List.filled(3, ''));

  bool isPlayerTurn = true;

  bool _isWinner(String player) {
    // Check rows and columns
    for (int i = 0; i < 3; i++) {
      if ((matrix[i][0] == player && matrix[i][1] == player && matrix[i][2] == player) ||
          (matrix[0][i] == player && matrix[1][i] == player && matrix[2][i] == player)) {
        return true;
      }
    }

    // Check diagonals
    if ((matrix[0][0] == player && matrix[1][1] == player && matrix[2][2] == player) ||
        (matrix[0][2] == player && matrix[1][1] == player && matrix[2][0] == player)) {
      return true;
    }

    return false;
  }

  bool _isDraw() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (matrix[i][j] == '') {
          return false; // At least one cell is empty, so it's not a draw yet
        }
      }
    }
    return true; // All cells are filled
  }

  void _aiPlay() {
    // 1. Check if AI can win in next move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (matrix[i][j] == '') {
          matrix[i][j] = 'O';
          if (_isWinner('O')) return;
          matrix[i][j] = '';
        }
      }
    }

    // 2. Check if Player can win in next move, and block it
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (matrix[i][j] == '') {
          matrix[i][j] = 'X';
          if (_isWinner('X')) {
            matrix[i][j] = 'O';
            return;
          }
          matrix[i][j] = '';
        }
      }
    }

    // 3. Random move
    List<Offset> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (matrix[i][j] == '') {
          emptyCells.add(Offset(i.toDouble(), j.toDouble()));
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      final randomCell = emptyCells[Random().nextInt(emptyCells.length)];
      matrix[randomCell.dx.toInt()][randomCell.dy.toInt()] = 'O';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
        ),
        body: Center(
            child: SizedBox(
          width: MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.width : 600,
          child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0, // ensures the cells are square
            ),
            itemBuilder: (context, index) {
              int x, y;
              x = index ~/ 3;
              y = index % 3;
              return GestureDetector(
                onTap: () {
                  if (matrix[x][y] == '' && isPlayerTurn) {
                    setState(() {
                      matrix[x][y] = 'X';
                      if (_isWinner('X')) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Player X has won!'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () => {buildPop(context)}, child: const Text('Yes')),
                            ],
                          ),
                        );
                      } else if (_isDraw()) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('The game is a draw!'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () => {buildPop(context)}, child: const Text('Yes')),
                            ],
                          ),
                        );
                      } else {
                        isPlayerTurn = false;
                        _aiPlay();
                        if (_isWinner('O')) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Player O has won!'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () => {buildPop(context)}, child: const Text('Yes')),
                              ],
                            ),
                          );
                        } else if (_isDraw()) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('The game is a draw!'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () => {buildPop(context)}, child: const Text('Yes')),
                              ],
                            ),
                          );
                        }
                        isPlayerTurn = true;
                      }
                    });
                  }
                },
                child: GridTile(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        matrix[x][y],
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )));
  }
}

void buildPop(BuildContext context) {
  int count = 0;
  Navigator.of(context).popUntil((_) => count++ >= 2);
}
