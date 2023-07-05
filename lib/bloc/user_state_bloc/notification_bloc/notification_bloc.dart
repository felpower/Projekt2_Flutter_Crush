import 'package:bachelor_flutter_crush/bloc/user_state_bloc/notification_bloc/notification_state.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_bloc.dart';
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/xp_bloc/xp_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final XpBloc xpBloc;

  NotificationBloc(this.xpBloc) : super(AwaitingNotificationClicksState()) {
    on<ClickNotificationEvent>(_onClickNotificationEvent);
  }

  void _onClickNotificationEvent(
      ClickNotificationEvent event, Emitter<NotificationState> emitter) {
    xpBloc.add(AddXpEvent(5));
  }
}
