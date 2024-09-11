// ignore_for_file: avoid_print
import 'dart:math';

import 'package:bachelor_flutter_crush/helpers/app_colors.dart';
import 'package:bachelor_flutter_crush/persistence/high_score_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/reporting_bloc/reporting_bloc.dart';
import '../bloc/reporting_bloc/reporting_event.dart';
import '../model/user.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _showUsernameDialog());
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
    flutter_bloc.BlocProvider.of<ReportingBloc>(context)
        .add(ReportCheckHighScoreEvent(DateTime.now()));
    users = User.decode(highScore);
    sortList();
    randomizeHighScore(prefs, update);
    updateUserAndHighScore(prefs);
    sortList();
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

  void _showUsernameDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    var darkPatternsInfoScore = prefs.getBool('darkPatternsInfoScore');
    if (username == null || username.isEmpty) {
      final TextEditingController usernameController = TextEditingController();
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Username eingeben'),
            content: TextField(
              controller: usernameController,
              decoration: const InputDecoration(hintText: "Username"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    users[users.indexWhere((element) => element.isUser == true)]
                        .name = usernameController.text;
                    prefs.setString('username', usernameController.text);
                  });
                  Navigator.of(context).pop();
                  _showDarkPatternsInfo();
                },
              ),
            ],
          );
        },
      );
    }
    if (darkPatternsInfoScore == null || darkPatternsInfoScore == false) {
      _showDarkPatternsInfo();
    }
  }

  void _showDarkPatternsInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Das war gerade ein Dark Pattern!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Manchmal nutzen Spiele eine gefälschte Highscore-Liste, um Spieler glauben zu lassen, sie treten gegen echte Menschen an.'),
                  if (isExpanded)
                    const Text(
                      'Diese Listen zeigen beeindruckend hohe Punktzahlen, die scheinbar von anderen Spielern erreicht wurden. Doch in Wirklichkeit werden diese Zahlen oft vom Spiel selbst generiert, um dich dazu zu bringen, weiterzuspielen. Der Gedanke, „nur noch ein paar Punkte“ zu machen, um an die Spitze zu kommen, sorgt dafür, dass du immer wieder versuchst, deinen Platz in der Rangliste zu verbessern – obwohl die Konkurrenz gar nicht echt ist.',
                    ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isExpanded ? "" : 'Mehr erfahren'),
                        isExpanded
                            ? const Icon(Icons.expand_less)
                            : const Icon(Icons.expand_more),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    prefs.setBool('darkPatternsInfoScore', true);
                    Navigator.of(context).pop();
                    },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateUserAndHighScore(SharedPreferences prefs) {
    var username = prefs.getString("username") ?? "Nicht gesetzt";
    var player = User(place: 1, name: username, xp: xp, isUser: true);
    users[users.indexWhere((element) => element.isUser == true)] = player;
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
                  image:
                      AssetImage('assets/images/background/background_new.png'),
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
      const DataColumn(label: Text('Rang')),
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

  List<DataRow> createRow() {
    List<DataRow> rows = [];
    for (User user in users) {
      rows.add(DataRow(
          color: user.isUser
              ? WidgetStateColor.resolveWith(
                  (states) => AppColors.getColorFromHex("#e52012"))
              : WidgetStateColor.resolveWith(
                  (states) => AppColors.getColorFromHex(("#80c9e2"))),
          cells: [
            DataCell(Text('#${user.place}')),
            DataCell(Text(user.name)),
            DataCell(Text(user.xp.toString()))
          ]));
    }
    return rows;
  }

  Future<void> setUsername(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", text);
  }
}
