import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/persistence/dark_patterns_service.dart';
import 'package:bachelor_flutter_crush/services/local_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DarkPatternsBloc extends Bloc<DarkPatternsEvent, DarkPatternsState> {
  DarkPatternsBloc() : super(WaitingForInitializationState()) {
    on<LoadDarkPatternsEvent>(_loadDarkPatterns);
    add(LoadDarkPatternsEvent());
  }

  void _loadDarkPatterns(LoadDarkPatternsEvent event, Emitter<DarkPatternsState> emit) async {
    bool shouldDarkPatternsBeDisplayed = await DarkPatternsService.shouldDarkPatternsBeVisible();
    if (!shouldDarkPatternsBeDisplayed) {
      LocalNotificationService().disableNotification();
    }
    if (shouldDarkPatternsBeDisplayed) {
      emit(DarkPatternsActivatedState());
    } else {
      emit(DarkPatternsDeactivatedState());
    }
  }
}
