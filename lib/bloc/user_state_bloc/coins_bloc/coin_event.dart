class CoinEvent {}

class LoadCoinsEvent extends CoinEvent {}

class AddCoinsEvent extends CoinEvent {
  final int amount;
  AddCoinsEvent(this.amount);
}

class RemoveCoinsEvent extends CoinEvent {
  final int amount;
  RemoveCoinsEvent(this.amount);
}
