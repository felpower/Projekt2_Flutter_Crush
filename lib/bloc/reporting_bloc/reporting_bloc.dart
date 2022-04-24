import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../persistence/reporting_service.dart';

class ReportingBloc extends Bloc<ReportingEvent, ReportingState> {
  ReportingBloc() : super(WaitingForReportingEvents()) {
    on<ReportAdvertisementTapEvent>(_onReportAdvertisementTapEvent);
    on<ReportStartLevelEvent>(_onReportStartLevelEvent);
    on<ReportStartAppEvent>(_onStartAppEvent);
    on<ReportCloseAppEvent>(_onCloseAppEvent);

    add(ReportStartAppEvent(DateTime.now()));
  }

  void _onReportAdvertisementTapEvent(
      ReportAdvertisementTapEvent event, Emitter<ReportingState> emit) {
    ReportingService.addAdvertisementTap(event.x, event.y);
  }

  void _onReportStartLevelEvent(
      ReportStartLevelEvent event, Emitter<ReportingState> emit) {
    ReportingService.addStartOfLevel(event.levelNumber);
  }

  void _onStartAppEvent(
      ReportStartAppEvent event, Emitter<ReportingState> emit) {
    ReportingService.addStartApp(event.time);
  }

  void _onCloseAppEvent(ReportCloseAppEvent event, Emitter<ReportingState> emit){
    ReportingService.addCloseApp(event.time);
  }
}
