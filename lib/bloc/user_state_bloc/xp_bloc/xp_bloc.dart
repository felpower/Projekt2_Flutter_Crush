import 'package:bachelor_flutter_crush/bloc/game_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_event.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_state.dart';
import 'package:bachelor_flutter_crush/persistence/xp_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class XpBloc extends Bloc<XpEvent, XpState> {
  XpBloc(GameBloc gameBloc) : super(XpState(0)) {
    on<AddXpEvent>(_onAddXp);
    on<LoadXpEvent>(_onLoadXp);
    add(LoadXpEvent());
    gameBloc.gameIsOver.listen(_onGameIsOver);
  }

  void _onAddXp(AddXpEvent event, Emitter<XpState> emit) async {
    bool doubleXpActive = await XpService.isDoubleXpActive();
    int multiplier = await XpService.getCurrentMultiplier();
    int amountToBeAdded =
        doubleXpActive ? event.amount * multiplier : event.amount;
    int amount = await XpService.addXp(amountToBeAdded);

    doubleXpActive
        ? emit(MultipliedXpState(amount, multiplier, event.amount))
        : emit(XpState(amount, event.amount));
  }

  void _onLoadXp(LoadXpEvent event, Emitter<XpState> emit) async {
    int amount = await XpService.getXp();
    emit(XpState(amount));
  }

  void _onGameIsOver(int xp) async {
    if (xp > 0) {
      add(AddXpEvent(xp));
    } else {
      add(LoadXpEvent());
    }
  }
}
