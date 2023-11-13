import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_state.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportingBloc extends Bloc<ReportingEvent, ReportingState> {
  ReportingBloc() : super(WaitingForReportingEvents()) {
    on<ReportAdvertisementTapEvent>(_onReportAdvertisementTapEvent);
    on<ReportStartLevelEvent>(_onReportStartLevelEvent);
    on<ReportStartAppEvent>(_onStartAppEvent);
    on<ReportCheckHighScoreEvent>(_onCheckHighScoreEvent);
    on<ReportPaidForRemovingAddsEvent>(_onPaidForRemovingAddsEvent);
    on<ReportCloseAppEvent>(_onCloseAppEvent);

    add(ReportStartAppEvent(DateTime.now()));
  }

  void _onReportAdvertisementTapEvent(
      ReportAdvertisementTapEvent event, Emitter<ReportingState> emit) {
    FirebaseStore.addAdvertisementTap(event.x, event.y);
  }

  void _onReportStartLevelEvent(ReportStartLevelEvent event, Emitter<ReportingState> emit) {
    FirebaseStore.addStartOfLevel(event.levelNumber);
  }

  void _onCheckHighScoreEvent(ReportCheckHighScoreEvent event, Emitter<ReportingState> emit) {
    FirebaseStore.checkHighScore(event.time);
  }

  void _onPaidForRemovingAddsEvent(
      ReportPaidForRemovingAddsEvent event, Emitter<ReportingState> emit) {
    FirebaseStore.removeAdds(event.removed);
  }

  void _onStartAppEvent(ReportStartAppEvent event, Emitter<ReportingState> emit) {
    FirebaseStore.addStartApp(event.time);
  }

  void _onCloseAppEvent(ReportCloseAppEvent event, Emitter<ReportingState> emit) {
    FirebaseStore.addCloseApp(event.time);
  }
}
