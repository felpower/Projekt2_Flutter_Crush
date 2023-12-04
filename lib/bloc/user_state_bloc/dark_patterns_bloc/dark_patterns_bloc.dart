import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/persistence/dark_patterns_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DarkPatternsBloc extends Bloc<DarkPatternsEvent, DarkPatternsState> {
  DarkPatternsBloc() : super(WaitingForInitializationState()) {
    on<LoadDarkPatternsEvent>(_loadDarkPatterns);
    add(LoadDarkPatternsEvent());
  }

  void _loadDarkPatterns(LoadDarkPatternsEvent event, Emitter<DarkPatternsState> emit) async {
    int shouldDarkPatternsBeDisplayed = await DarkPatternsService.shouldDarkPatternsBeVisible();
    if (shouldDarkPatternsBeDisplayed == 0) {
      emit(DarkPatternsDeactivatedState());
      return;
    } else if (shouldDarkPatternsBeDisplayed == 1) {
      emit(DarkPatternsActivatedState());
      return;
    } else if (shouldDarkPatternsBeDisplayed == 2) {
      emit(DarkPatternsFoMoState());
      return;
    } else if (shouldDarkPatternsBeDisplayed == 3) {
      emit(DarkPatternsRewardsState());
      return;
    } else if (shouldDarkPatternsBeDisplayed == 4) {
      emit(DarkPatternsCompetitionState());
      return;
    } else if (shouldDarkPatternsBeDisplayed == 5) {
      emit(DarkPatternsAppointmentState());
      return;
    } else if (shouldDarkPatternsBeDisplayed == 6) {
      emit(DarkPatternsCollectionState());
      return;
    }
  }
}
