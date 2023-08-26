class XpState {
  final int amount;
  int addedAmount;

  XpState(this.amount, [this.addedAmount = 0]);
}

class MultipliedXpState extends XpState {
  final int multiplier;

  MultipliedXpState(int amount, this.multiplier, [addedAmount = 0]) : super(amount, addedAmount);
}
