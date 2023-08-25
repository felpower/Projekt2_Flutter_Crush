import 'dart:math';

import 'package:bachelor_flutter_crush/persistence/high_score_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/reporting_bloc/reporting_bloc.dart';
import '../bloc/reporting_bloc/reporting_event.dart';
import '../model/user.dart';
import '../services/local_notification_service.dart';

int xp = 0;
String updateHighScore = "what?";
String highScore = "notSet";
List<User> users = List.empty();

class HighScorePage extends StatefulWidget {
  const HighScorePage({Key? key}) : super(key: key);

  @override
  HighScoreState createState() => HighScoreState();
}

class HighScoreState extends State<HighScorePage> {
  int _currentSortColumn = 0;
  bool _isSortAsc = true;

  @override
  void initState() {
    super.initState();

    _loadHighScore();
  }

  _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = DateTime.now();
    setState(() {
      highScore = (prefs.getString('highScore') ?? 'notSet');
      if (highScore == 'notSet') {
        highScore = HighScoreService.initialHighScore;
      }
      xp = (prefs.getInt('xp') ?? 0);
      updateHighScore = (prefs.getString('updateHighScore') ?? now.toString());
      prefs.setString('updateHighScore', updateHighScore);
    });
    bool update = checkIfUpdateNeeded(now, prefs);
    final ReportingBloc reportingBloc =
        flutter_bloc.BlocProvider.of<ReportingBloc>(context);
    reportingBloc.add(ReportCheckHighScoreEvent(DateTime.now()));
    users = User.decode(highScore);
    sortList();
    randomizeHighScore(prefs, update);
    updateUserAndHighScore(prefs);
    sortList();
    scheduleNotification();
  }

  bool checkIfUpdateNeeded(DateTime now, SharedPreferences prefs) {
    var parse = DateTime.parse(updateHighScore);
    var passedTime = parse.add(const Duration(minutes: 1));
    var update = false;
    if (now.compareTo(passedTime) > 0) {
      prefs.setString('updateHighScore', now.toString());
      updateHighScore = now.toString();
      update = true;
    }
    return update;
  }

  void updateUserAndHighScore(SharedPreferences prefs) {
    var patrick = User(place: 1, name: 'Patrick', xp: xp, isUser: true);
    users[users.indexWhere((element) => element.isUser == true)] = patrick;
    prefs.setString("highScore", User.encode(users));
  }

  void sortList() {
    users.sort((m1, m2) {
      var r = m2.xp.compareTo(m1.xp);
      return r;
    });
    for (var i = 0; i < users.length; i++) {
      users[i].place = i + 1;
    }
  }

  void randomizeHighScore(SharedPreferences prefs, bool update) {
    if (update && users[0].isUser == true) {
      Random random = Random();
      int randomNumber = random.nextInt(15) + 1;
      users[1].xp = randomNumber + xp;
      for (var i = 2; i < users.length; i++) {
        users[i].xp = users[i].xp +
            random.nextInt(xp - users[i].xp); //Make user not loose points
      }
      prefs.setString("highScore", User.encode(users));
    }
  }

  void scheduleNotification() {
    if (users[0].isUser) {
      print("Notification scheduled for: " +
          DateTime.now().add(const Duration(minutes: 1)).toString());
      LocalNotificationService().scheduleHighScoreNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('High Score'),
              leading: BackButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                  image: AssetImage('assets/images/background/background2.jpg'),
                  fit: BoxFit.cover,
                ))),
                ListView(
                  children: [_createDataTable()],
                )
              ],
            )));
  }

  DataTable _createDataTable() {
    return DataTable(
      columns: _createColumns(),
      rows: createRow(),
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: Text('Place')),
      const DataColumn(label: Text('Name')),
      DataColumn(
        label: const Text('XP'),
        onSort: (columnIndex, _) {
          setState(() {
            _currentSortColumn = columnIndex;
            if (_isSortAsc) {
              users.sort((a, b) => b.xp.compareTo(a.xp));
            } else {
              users.sort((a, b) => a.xp.compareTo(b.xp));
            }
            _isSortAsc = !_isSortAsc;
          });
        },
      )
    ];
  }

  // }

  List<DataRow> createRow() {
    List<DataRow> rows = [];
    for (User user in users) {
      if (user.name == "Patrick") {
        rows.add(DataRow(
            color: MaterialStateColor.resolveWith((states) => Colors.redAccent),
            cells: [
              DataCell(Text('#' + user.place.toString())),
              DataCell(Text(user.name)),
              DataCell(Text(user.xp.toString()))
            ]));
      } else {
        rows.add(DataRow(
            color:
                MaterialStateColor.resolveWith((states) => Colors.yellowAccent),
            cells: [
              DataCell(Text('#' + user.place.toString())),
              DataCell(Text(user.name)),
              DataCell(Text(user.xp.toString()))
            ]));
      }
    }
    return rows;
  }
}
