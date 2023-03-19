abstract class ReportingEvent {}

class ReportAdvertisementTapEvent extends ReportingEvent {
  final double x;
  final double y;

  ReportAdvertisementTapEvent(this.x, this.y);
}

class ReportStartLevelEvent extends ReportingEvent {
  final int levelNumber;

  ReportStartLevelEvent(this.levelNumber);
}

class ReportCheckHighScoreEvent extends ReportingEvent {
  final DateTime time;

  ReportCheckHighScoreEvent(this.time);
}

class ReportStartAppEvent extends ReportingEvent {
  final DateTime time;

  ReportStartAppEvent(this.time);
}

class ReportCloseAppEvent extends ReportingEvent {
  final DateTime time;

  ReportCloseAppEvent(this.time);
}
