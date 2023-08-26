import 'package:bachelor_flutter_crush/bloc/user_state_bloc/high_score_bloc/high_score_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/high_score_bloc/high_score_state.dart';
import 'package:bachelor_flutter_crush/persistence/high_score_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HighScoreBloc extends Bloc<HighScoreEvent, HighScoreState> {
  HighScoreBloc()
      : super(HighScoreState(HighScoreService.initialHighScore, HighScoreService.updateHighScore)) {
    on<LoadHighScoreEvent>(_onLoadHighScore);
    add(LoadHighScoreEvent());
  }

  void _onLoadHighScore(LoadHighScoreEvent event, Emitter<HighScoreState> emit) async {
    String highScore = await HighScoreService.getHighScore();
    String updateHighScore = "await HighScoreService.getHighScore()";
    emit(HighScoreState(highScore, updateHighScore));
  }
}
