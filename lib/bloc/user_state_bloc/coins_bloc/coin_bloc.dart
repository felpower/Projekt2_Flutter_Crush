import 'dart:math';

import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_event.dart';
import 'package:bachelor_flutter_crush/persistence/coin_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game_bloc.dart';
import 'coin_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final Random random = Random();

  CoinBloc(GameBloc gameBloc) : super(CoinState(1000)) {
    on<AddCoinsEvent>(_addCoins);
    on<RemoveCoinsEvent>(_removeCoins);
    on<LoadCoinsEvent>(_onLoadCoins);
    add(LoadCoinsEvent());
    gameBloc.gameIsOver.listen(_onGameOver);
  }

  void _onLoadCoins(LoadCoinsEvent event, Emitter<CoinState> emit) async {
    int amount = await CoinService.getCoins();
    emit(CoinState(amount));
  }

  void _removeCoins(RemoveCoinsEvent event, Emitter<CoinState> emit) async {
    int newAmount = await CoinService.removeCoins(event.amount);
    emit(CoinState(newAmount));
  }

  void _addCoins(AddCoinsEvent event, Emitter<CoinState> emit) async {
    int newAmount = await CoinService.addCoins(event.amount);
    emit(CoinState(newAmount, event.amount));
  }

  void _onGameOver(bool success) async {
    if (success) {
      add(AddCoinsEvent(random.nextInt(100)));
      // add(AddCoinsEvent(100000));
    } else {
      add(LoadCoinsEvent());
    }
  }
}
