import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';

class DeviceToken extends StatefulWidget {
  const DeviceToken({Key? key}) : super(key: key);

  @override
  State<DeviceToken> createState() => _DeviceTokenState();
}

class _DeviceTokenState extends State<DeviceToken> {
  String text = "";
  TextEditingController authorizationStatus = TextEditingController();
  final PageController _pageController = PageController();

  int _currentPage = 0; // Add this line
  @override
  Widget build(BuildContext context) {
    final DarkPatternsState darkPatternsState =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context).state;
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Instruktionen zum Spiel')),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    const SingleChildScrollView(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('''1.	Spielbrett und Jellies: ''',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '''Das Spielbrett ist ein Gitter mit verschiedenen farbigen Jellies. Jedes Jelly hat eine einzigartige Farbe und Form. (siehe Bild)
          '''),
                          Image(
                              image: AssetImage('assets/instructions/ins_1.png'),
                              fit: BoxFit.cover),
                        ],
                      ),
                    ),
                    const SingleChildScrollView(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('''2.	Spielzüge:''', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '''Tausche zwei benachbarte Jellies, um eine Reihe oder Spalte von mindestens drei gleichfarbigen Jellies zu bilden.
              '''),
                          Image(
                              image: AssetImage('assets/instructions/ins_2.png'),
                              fit: BoxFit.cover),
                        ],
                      ),
                    ),
                    const SingleChildScrollView(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("3.	Kombinationen und Boni:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              // Adjust the value for the desired indent
                              child: Text(
                                  '''•	Kombiniere 4 Jellies, um ein Sonderjelly zu erhalten, das eine ganze Reihe (horizontal gestreift, Bild links) oder Spalte (vertikal gestreift, Bild rechts) löschen kann. ''')),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image(
                                  image: AssetImage('assets/images/bombs/jelly_gelb_vertical'
                                      '.png'),
                                  height: 50),
                              Image(
                                  image: AssetImage('assets/images/bombs/jelly_gelb_horizontal'
                                      '.png'),
                                  height: 50),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              // Adjust the value for the desired indent
                              child: Text('''
  •	Kombiniere 5 Jellies in einem T- oder L-Form, um ein Regenbogen-Jelly zu bekommen, das alle Jellies einer bestimmten Farbe vom Brett entfernt (die Richtung der Streifen ist dabei egal).''')),
                          Image(
                              image: AssetImage('assets/images/bombs/jelly_bunt.png'), height: 50),
                          Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              // Adjust the value for the desired indent
                              child: Text(
                                  '''Du kannst Sonderjellies auch im Shop oder direkt vor dem Levelstart kaufen. Pro Level kann nur ein Sonderjelly zu Beginn platziert werden, indem du auf das Jelly klickst, dass ersetzt werden soll. Die Sonderjellies können dir helfen schwierige Level zu meistern.
''')),
                        ],
                      ),
                    ),
                    const SingleChildScrollView(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("4.	Levelziele:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '''Jedes Level hat spezifische Ziele, wie das Erreichen einer bestimmten Punktzahl, das Sammeln einer Anzahl von bestimmten Jellies oder das Entfernen von Hindernissen. Das jeweilige Ziel wird in dem Kasten rechts oben auf dem Bildschirm angezeigt. (1). Die Sterne am unteren Bildrand (2) zeigen dir deinen Fortschritt an – sobald du einen Stern erreicht hast, gilt das Level als geschafft. Je mehr Sterne du jedoch erreichst, umso höher ist der Gewinn durch das absolvierte Level.
              '''),
                          Image(
                              image: AssetImage('assets/instructions/ins_3.png'),
                              fit: BoxFit.cover),
                        ],
                      ),
                    ),
                    const SingleChildScrollView(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("5.	Bewegungsbegrenzung und Zeitlimit: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '''Einige Level haben eine begrenzte Anzahl von Zügen oder ein Zeitlimit, um die Ziele zu erreichen. Dies wird in dem Kasten links oben auf dem Bildschirm angezeigt.
          '''),
                          Image(
                              image: AssetImage('assets/instructions/ins_4.png'),
                              fit: BoxFit.cover),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text("6.	Startbildschirm: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          if (darkPatternsState is DarkPatternsActivatedState)
                            const Text(
                                '''Im Hauptmenü siehst du welche Level du bereits freigespielt hast (Kästchen hat eine deckende Farbe (1)). In den oberen Kästchen siehst du einerseits deine aktuelle Anzahl an Münzen (2) (diese kannst du nutzen um Sonderjellies zu kaufen) und, wie viele XP du hast (3) (diese bestimmen deine Position im Ranking der Highscore-Tafel (4). Die Highscore-Tafel (4) zeigt dir an, wie gut du dich im Vergleich zu anderen Spielern schlägst. Im Menü (5) kannst du diese Instruktionen jederzeit erneut durchlesen, solltest du etwas vergessen haben. 
                                ''')
                          else if (darkPatternsState is DarkPatternsDeactivatedState || darkPatternsState is DarkPatternsRewardsState || darkPatternsState is DarkPatternsAppointmentState)
                            const Text(
                                '''Im Hauptmenü siehst du welche Level du bereits freigespielt hast (Kästchen hat eine deckende Farbe (1)) und wie viele Münzen du hast (2) (diese kannst du nutzen um Sonderjellies zu kaufen). Im Menü (3) kannst du diese Instruktionen jederzeit erneut durchlesen, solltest du etwas vergessen haben
                                ''')
                          else if (darkPatternsState is DarkPatternsCompetitionState)
                            const Text(
                                '''Im Hauptmenü siehst du welche Level du bereits freigespielt hast (Kästchen hat eine deckende Farbe (1)). In den oberen Kästchen siehst du einerseits deine aktuelle Anzahl an Münzen (2) (diese kannst du nutzen um Sonderjellies zu kaufen) und, wie viele XP du hast (3) (diese bestimmen deine Position im Ranking der Highscore-Tafel (4). Die Highscore-Tafel (4) zeigt dir an, wie gut du dich im Vergleich zu anderen Spielern schlägst. Im Menü (5) kannst du diese Instruktionen jederzeit erneut durchlesen, solltest du etwas vergessen haben. 
                                ''')
                          else if (darkPatternsState is DarkPatternsFoMoState)
                            const Text(
                                '''Im Hauptmenü siehst du welche Level du bereits freigespielt hast (Kästchen hat eine deckende Farbe (1)) und wie viele Münzen du hast (2) (diese kannst du nutzen um Sonderjellies zu kaufen). Im Menü (3) kannst du diese Instruktionen jederzeit erneut durchlesen, solltest du etwas vergessen haben.
                                '''),
                          //Images:
                          if (darkPatternsState is DarkPatternsActivatedState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_activated.png'),
                                fit: BoxFit.cover)
                          else if (darkPatternsState is DarkPatternsDeactivatedState || darkPatternsState is DarkPatternsRewardsState || darkPatternsState is DarkPatternsAppointmentState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_deactivated.png'),
                                fit: BoxFit.cover)
                          else if (darkPatternsState is DarkPatternsCompetitionState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_competition.png'),
                                fit: BoxFit.cover)
                          else if (darkPatternsState is DarkPatternsFoMoState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_FoMo.png'),
                                fit: BoxFit.cover),
                          const SizedBox(height: 10),
                          //Menü Text
                          if (darkPatternsState is DarkPatternsActivatedState)
                            const Text(
                                '''Außerdem gibt es im Menü noch zwei weitere spannende Features für dich: Im Shop (1) kannst du mit den erspielten Münzen Sonderjellies kaufen. Außerdem wartet täglich eine neue Belohnung darauf von dir abgeholt zu werden (2). Die Musik kann ebenfalls im Menü ein- und ausgeschalten werden (3).
                                ''')
                          else if (darkPatternsState is DarkPatternsDeactivatedState || darkPatternsState is DarkPatternsRewardsState || darkPatternsState is DarkPatternsAppointmentState)
                            const Text(
                                '''Außerdem gibt es im Menü noch ein weiters spannendes Feature für dich: Im Shop (1) kannst du mit den erspielten Münzen Sonderjellies kaufen. Die Musik kann ebenfalls im Menü ein- und ausgeschalten werden (2).
                                ''')
                          else if (darkPatternsState is DarkPatternsCompetitionState)
                            const Text(
                                '''Außerdem gibt es im Menü noch ein weiters spannendes Feature für dich: Im Shop (1) kannst du mit den erspielten Münzen Sonderjellies kaufen. Die Musik kann ebenfalls im Menü ein- und ausgeschalten werden (2).
                                ''')
                          else if (darkPatternsState is DarkPatternsFoMoState)
                            const Text(
                                '''Außerdem gibt es im Menü noch zwei weitere spannende Features für dich: Im Shop (1) kannst du mit den erspielten Münzen Sonderjellies kaufen. Außerdem wartet täglich eine neue Belohnung darauf von dir abgeholt zu werden (2). Die Musik kann ebenfalls im Menü ein- und ausgeschalten werden (3)
                                '''),
                          if (darkPatternsState is DarkPatternsActivatedState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_1_activated.png'),
                                fit: BoxFit.cover)
                          else if (darkPatternsState is DarkPatternsDeactivatedState || darkPatternsState is DarkPatternsRewardsState || darkPatternsState is DarkPatternsAppointmentState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_1_deactivated.png'),
                                fit: BoxFit.cover)
                          else if (darkPatternsState is DarkPatternsCompetitionState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_1_competition.png'),
                                fit: BoxFit.cover)
                          else if (darkPatternsState is DarkPatternsFoMoState)
                            const Image(
                                image: AssetImage('assets/instructions/ins_6_1_FoMo.png'),
                                fit: BoxFit.cover),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text("7.	Fortschritt und Herausforderungen: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text(
                              '''Schalte neue Level und Herausforderungen frei, indem du im Spiel fortschreitest. Wenn du einmal keine Möglichkeit mehr für einen Spielzug hast (weil es keine Jellies gibt, die getauscht werden können um eine 3er Folge zu erzielen) kannst du die Option „shuffle“ für 50\$ nutzen um die Jellies auf dem Brett neu zu verteilen. Nutze Sonderjellies, um schwierige Level zu meistern.'''),
                          const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              // Adjust the value for the desired indent
                              child: Text('''
•	Plane deine Züge voraus, um die effektivsten Kombinationen zu erstellen.
•	Nutze die speziellen Jellies strategisch, um schwierige Bereiche zu meistern.
•	Halte Ausschau nach unerwarteten Kettenreaktionen.
''')),
                          const Text('''Viel Spaß beim Spielen!
          ''', style: TextStyle(fontWeight: FontWeight.bold)),
                          ElevatedButton(
                              child: const Text('Spiel jetzt starten', textAlign: TextAlign.center),
                              //
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                    ),
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_pageController.hasClients && _pageController.page! > 0) {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }
                  },
                ),
                Text('${_currentPage + 1} / 7'),
                ElevatedButton(
                  child: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (_pageController.hasClients &&
                        _pageController.page! < _pageController.position.maxScrollExtent) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
