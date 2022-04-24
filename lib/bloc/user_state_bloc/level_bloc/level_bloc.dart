import 'package:bachelor_flutter_crush/bloc/user_state_bloc/level_bloc/level_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_state.dart';
import 'package:bachelor_flutter_crush/persistence/level_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'level_event.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  LevelBloc(XpBloc xpBloc) : super(LevelState([])) {
    on<UpdateLevelsEvent>(_onUpdateLevel);
    on<AddLevelEvent>(_onAddLevel);
    xpBloc.stream.listen(_onXpChange);
    add(UpdateLevelsEvent());
  }

  void _onUpdateLevel(UpdateLevelsEvent event, Emitter<LevelState> emit) async {
    emit(LevelState(await LevelService.getLevels()));
  }

  void _onAddLevel(AddLevelEvent event, Emitter<LevelState> emit) async {
    await LevelService.addLevel(event.levelnumber);
    emit(LevelState(await LevelService.getLevels()));
  }

  void _onXpChange(XpState state) async {
    LevelService.updateLevels(state.amount);
    add(UpdateLevelsEvent());
  }
}
