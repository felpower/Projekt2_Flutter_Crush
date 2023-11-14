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

class ReportFinishLevelEvent extends ReportingEvent {
  final int levelNumber;
  final bool won;

  ReportFinishLevelEvent(this.levelNumber, this.won);
}

class ReportCheckHighScoreEvent extends ReportingEvent {
  final DateTime time;

  ReportCheckHighScoreEvent(this.time);
}

class ReportPaidForRemovingAddsEvent extends ReportingEvent {
  final bool removed;

  ReportPaidForRemovingAddsEvent(this.removed);
}

class ReportStartAppEvent extends ReportingEvent {
  final DateTime time;

  ReportStartAppEvent(this.time);
}

class ReportCloseAppEvent extends ReportingEvent {
  final DateTime time;

  ReportCloseAppEvent(this.time);
}
