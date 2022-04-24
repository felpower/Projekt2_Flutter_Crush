class LevelEvent {}

class AddLevelEvent extends LevelEvent{
  final int levelnumber;

  AddLevelEvent(this.levelnumber);
}

class UpdateLevelsEvent extends LevelEvent{}
