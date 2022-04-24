import 'package:bachelor_flutter_crush/controllers/game_controller.dart';
import 'package:bachelor_flutter_crush/game_widgets/stream_moves_left_counter.dart';
import 'package:flutter/material.dart';

import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';

class GameMovesLeftPanel extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final GameBloc gameBloc = BlocProvider.of<GameBloc>(context);
    final Orientation orientation = MediaQuery.of(context).orientation;
    final EdgeInsets paddingTop = EdgeInsets.only(top: (orientation == Orientation.portrait ? 10.0 : 0.0));

    return StreamBuilder<GameController>(
      initialData: gameBloc.gameController,
      stream: gameBloc.streamGameController,
      builder: (BuildContext context, AsyncSnapshot<GameController> snapshot) {
        if (snapshot.hasData) {

        return Padding(
          padding: paddingTop,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300]?.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(width: 5.0, color: Colors.black.withOpacity(0.5)),
            ),
            width: 100.0,
            height: 80.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Level: ${snapshot.data?.level.index}',
                      style: const TextStyle(fontSize: 14.0, color: Colors.black,)
                  ),
                ),
                StreamMovesLeftCounter(),
              ],
            ),
          ),
        );
        } else {
          return Container();
        }
      },
    );

  }
}