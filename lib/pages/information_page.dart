import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Information'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const SingleChildScrollView(
            child:
                // Container(
                //     decoration: const BoxDecoration(
                //         image: DecorationImage(
                //   image: AssetImage('assets/images/background/background2.jpg'),
                //   fit: BoxFit.cover,
                // ))),
                Center(
                    child: Column(
          children: <Widget>[
            Text("This game is a so called Match-3 puzzle game.\n"
                "A player may slide 1 tile of one cell at a time, horizontally or vertically.\n"
                "The goal is to finish the objectives presented at the start of the game.\n"
                "The player only has a certain number of moves available to finish the objectives.\n"
                "The user may also chain more than 3 blocks together to receive a combo.\n"),
            Text(
                "A combo of  4 tiles. All tiles of the chains are removed and the common tile is replaced by a TNT:\n"),
            Image(
              image: AssetImage(
                'assets/images/bombs/tnt.png',
              ),
              height: 30,
            ),
            Text("A TNT removes the tiles right next to the TNT\n"
                "A combo of  5 tiles. All tiles of the chains are removed and the common tile is replaced by a BOMB:\n"),
            Image(
              image: AssetImage(
                'assets/images/bombs/mine.png',
              ),
              height: 30,
            ),
            Text("A BOMB removes the tiles up to 2 cells around the BOMB\n"
                "A combo of 6 tiles. All tiles of the chains are removed and the common tile is replaced by a WRAPPED:\n"),
            Image(
              image: AssetImage(
                'assets/images/bombs/multi_color.png',
              ),
              height: 30,
            ),
            Text(
                "A WRAPPED removes the tiles up to 3 cells around the WRAPPED\n"
                "A combo of 7 tiles. All tiles of the chains are removed and the common tile is replaced by a FIREBALL:\n"),
            Image(
              image: AssetImage(
                'assets/images/bombs/fireball.png',
              ),
              height: 30,
            ),
            Text(
              "A FIREBALL removes the tiles up to 3 cells around the FIREBALL\n"
              "A combo of  8 tiles. All tiles of the chains are removed and the common tile is replaced by a ROCKET:",
            ),
            Image(
              image: AssetImage(
                'assets/images/bombs/rocket.png',
              ),
              height: 30,
            ),
            Text("A ROCKET” removes all the tiles on the screen\n")
          ],
        ))));
  }
}
