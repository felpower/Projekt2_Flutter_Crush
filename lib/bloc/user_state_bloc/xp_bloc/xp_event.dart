class XpEvent {}

class LoadXpEvent extends XpEvent {}

class AddXpEvent extends XpEvent {
  final int amount;

  AddXpEvent(this.amount);
}
