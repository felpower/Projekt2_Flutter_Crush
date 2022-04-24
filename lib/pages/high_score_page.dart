import 'dart:math';

import 'package:bachelor_flutter_crush/persistence/daystreak_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int xp = 0;
String lastLogin = "notSet";

class HighScorePage extends StatefulWidget {
  const HighScorePage({Key? key}) : super(key: key);

  @override
  HighScoreState createState() => HighScoreState();
}

class HighScoreState extends State<HighScorePage> {
  List<Map> users = [
    {'place': 0, 'name': 'Best Player Ever', 'xp': 0},
    {'place': 0, 'name': 'Some Random Dude', 'xp': 10},
    {'place': 0, 'name': 'Huckleberry Finn', 'xp': 9},
    {'place': 0, 'name': 'Star Wars Fan Guy', 'xp': 7},
    {'place': 0, 'name': 'League Player', 'xp': 5},
    {'place': 0, 'name': 'I am not very good at this', 'xp': 4},
    {'place': 0, 'name': 'I do not even know who i am', 'xp': 3},
    {'place': 0, 'name': 'The best ever', 'xp': 1},
  ];
  int _currentSortColumn = 0;
  bool _isSortAsc = true;

  @override
  void initState() {
    super.initState();
    _loadXP();
  }

  _loadXP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      xp = (prefs.getInt('xp') ?? 0);
      lastLogin = (prefs.getString('last_login') ?? 'notSet');
    });
    print("XP: " + xp.toString());
    print("Last Login: " + DateTime.parse(lastLogin).toString());
    // if (!DayStreakService.alreadyLoggedInToday(DateTime.parse(lastLogin))) {
    Random random = Random();
    int randomNumber = random.nextInt(xp) + 1;
    users[0]['xp'] = randomNumber + xp;
    for (var i = 1; i < users.length; i++) {
      randomNumber = random.nextInt(xp) + 1;
      users[i]['xp'] = xp - randomNumber;
    }
    // }
    users.add({'place': 4, 'name': 'Patrick', 'xp': xp});
    users.sort((m1, m2) {
      var r = m2["xp"].compareTo(m1["xp"]);
      return r;
    });
    for (var i = 0; i < users.length; i++) {
      users[i]['place'] = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('High Score'),
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
      rows: _createRows(),
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
              users.sort((a, b) => b['xp'].compareTo(a['xp']));
            } else {
              users.sort((a, b) => a['xp'].compareTo(b['xp']));
            }
            _isSortAsc = !_isSortAsc;
          });
        },
      )
    ];
  }

  List<DataRow> _createRows() {
    return users
        .map((book) => DataRow(
                color: MaterialStateColor.resolveWith(
                    (states) => Colors.yellowAccent),
                cells: [
                  DataCell(Text('#' + book['place'].toString())),
                  DataCell(Text(book['name'])),
                  DataCell(Text(book['xp'].toString()))
                ]))
        .toList();
  }
}
