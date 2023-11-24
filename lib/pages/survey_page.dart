import 'package:bachelor_flutter_crush/pages/under_18_page.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:survey_kit/survey_kit.dart';

import 'info_page.dart';

class SurveyPage extends StatefulWidget {
  final String title;

  const SurveyPage({Key? key, required this.title}) : super(key: key);

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: FutureBuilder<Task>(
            future: widget.title == "Start" ? buildStartSurvey() : buildEndSurvey(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data != null) {
                final task = snapshot.data!;
                return SurveyKit(
                  onResult: (SurveyResult result) {
                    List<String> resultString = [];
                    for (var stepResult in result.results) {
                      for (var questionResult in stepResult.results) {
                        if (questionResult.result != null && questionResult.result != "") {
                          resultString.add(questionResult.valueIdentifier.toString());
                        }
                      }
                    }
                    FirebaseStore.sendSurvey(resultString);
                    Navigator.pop(context);
                    if (int.parse(resultString[0]) >= 18) {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const DeviceToken()));
                    } else {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const Under18Page()));
                    }
                  },
                  task: task,
                  showProgress: true,
                  localizations: const {
                    'cancel': '',
                    'next': 'Weiter',
                  },
                  themeData: Theme.of(context).copyWith(
                    primaryColor: Colors.cyan,
                    appBarTheme: const AppBarTheme(
                      color: Colors.white,
                      iconTheme: IconThemeData(
                        color: Colors.cyan,
                      ),
                      titleTextStyle: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                    iconTheme: const IconThemeData(
                      color: Colors.cyan,
                    ),
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Colors.cyan,
                      selectionColor: Colors.cyan,
                      selectionHandleColor: Colors.cyan,
                    ),
                    cupertinoOverrideTheme: const CupertinoThemeData(
                      primaryColor: Colors.cyan,
                    ),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          const Size(150.0, 60.0),
                        ),
                        side: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> state) {
                            if (state.contains(MaterialState.disabled)) {
                              return const BorderSide(
                                color: Colors.grey,
                              );
                            }
                            return const BorderSide(
                              color: Colors.cyan,
                            );
                          },
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        textStyle: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> state) {
                            if (state.contains(MaterialState.disabled)) {
                              return Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.grey,
                                  );
                            }
                            return Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.cyan,
                                );
                          },
                        ),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.cyan,
                              ),
                        ),
                      ),
                    ),
                    textTheme: const TextTheme(
                      displayMedium: TextStyle(
                        fontSize: 28.0,
                        color: Colors.black,
                      ),
                      headlineSmall: TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                      bodyMedium: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      titleMedium: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    inputDecorationTheme: const InputDecorationTheme(
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: Colors.cyan,
                    )
                        .copyWith(
                          onPrimary: Colors.white,
                        )
                        .copyWith(background: Colors.white),
                  ),
                  surveyProgressbarConfiguration: SurveyProgressConfiguration(
                    backgroundColor: Colors.white,
                  ),
                );
              }
              return const CircularProgressIndicator.adaptive();
            },
          ),
        ),
      ),
    );
  }

  Future<Task> buildStartSurvey() {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
        InstructionStep(
          title: 'Willkommen!',
          text:
              'Wenn Sie über 18 Jahre alt sind und an der Studie teilnehmen möchten, klicken Sie bitte auf „Ich bin mit der Studienteilnahme einverstanden.“ und bestätigen so Ihr Einverständnis für die Studienteilnahme. ',
          buttonText: 'Ich bin mit der Studienteilnahme einverstanden.',
        ),
        InstructionStep(
          title: 'Sehr geehrte Studienteilnehmer:innen,',
          text: 'vielen Dank für die Teilnahme an unserer Studie. \n'
              'Im Rahmen der Studie möchten wir das Spielverhalten auf Handy oder Tablet von '
              'Erwachsenen (über 18 Jahre) möglichst realistisch erheben. Daher bitten wir Sie, '
              'auch wenn das Spiel Teil einer Studie ist, dieses genauso zu behandeln, wie jedes '
              'andere Spiel, das Sie auf Ihrem Gerät installiert haben.',
          buttonText: 'weiter',
        ),
        InstructionStep(
          title: 'Homescreen/Startbildschirm',
          text: 'Bitte fügen Sie dazu diese Seite auf Ihren Homescreen/Startbildschirm hinzu, '
              'danach können Sie das Spiel wie jede andere App handhaben. Die Installation '
              'funktioniert wie folgt: \n'
              'für Android (alle Handys außer iPhone): Drücken Sie '
              'auf die drei kleinen Punkte rechts oben auf dem Bildschirm -> App installieren'
              '\n'
              'für Apple (iPhone): Drücken Sie auf den „Teilen“-Button (kleines Viereck mit '
              'dem Pfeil nach oben) -> Option -> zum Home-Bildschirm',
          buttonText: 'weiter',
        ),
        InstructionStep(
          title: 'Vor dem Spielstart',
          text: 'Vor dem Spielstart werden Ihnen noch ein paar Fragen zu Ihrer Person und Ihrem '
              'üblichen Spielverhalten gestellt. \n'
              'Bitte beantworten Sie diese ehrlich. Alle Ihre Daten'
              ' werden auf einem Server, der in der EU (entsprechend DSGVO) gehostet wird, '
              'anonymisiert (d.h. ohne einen möglichen Rückschluss auf Ihre Person; es werden keine personenbezogenen Daten '
              'erfasst) gespeichert und anschließend für wissenschaftliche Zwecke ausgewertet.\n'
              'Sie können jederzeit die Studienteilnahme beenden.',
          buttonText: 'weiter',
        ),
        QuestionStep(
          title: 'Wie alt sind Sie?',
          stepIdentifier: StepIdentifier(id: '1'),
          answerFormat: const IntegerAnswerFormat(
            defaultValue: 18,
            hint: 'Bitte geben Sie ihr Alter ein',
          ),
          isOptional: false,
        ),
        QuestionStep(
            title: "Welches Geschlcht haben Sie",
            stepIdentifier: StepIdentifier(id: '2'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Männlich', value: '0'),
                TextChoice(text: 'Weiblich', value: '1'),
                TextChoice(text: 'Nicht-Binär', value: '2'),
              ],
            )),
        QuestionStep(
            title: "Höchster Bildungsabschluss",
            stepIdentifier: StepIdentifier(id: '3'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Pflichtschule/Hauptschule/Realschule', value: '0'),
                TextChoice(text: 'Lehre', value: '1'),
                TextChoice(text: 'Fachschule/Handelsschule', value: '2'),
                TextChoice(text: 'Matura/Abitur', value: '3'),
                TextChoice(text: 'Universität/Fachhochschule', value: '4'),
              ],
            )),
        QuestionStep(
            title:
                "In Ihrer (beruflichen) Haupttätigkeit (Tätigkeit mit den meisten Stunden), sind Sie…?",
            stepIdentifier: StepIdentifier(id: '4'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(
                    text:
                        'Unselbstständig erwerbstätig (Lehrling, Arbeiter:in, Angestellte:r, Vertragsbedienstete, Beamter/Beamtin)',
                    value: '0'),
                TextChoice(
                    text:
                        'Selbstständig erwerbstätig (Selbstständige:r, Freie Dienstnehmer:in, Werkvertragsnehmer:in)',
                    value: '1'),
                TextChoice(text: 'Arbeitssuchend ', value: '2'),
                TextChoice(text: 'Schüler:in, Student:in', value: '3'),
                TextChoice(text: 'Pensionist:in', value: '4'),
              ],
            )),
        QuestionStep(
            title: "Wohnort?",
            stepIdentifier: StepIdentifier(id: '5'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Österreich', value: '0'),
                TextChoice(text: 'Deutschland', value: '1'),
                TextChoice(text: 'Anderes Land', value: '2'),
              ],
            )),
        InstructionStep(
          stepIdentifier: StepIdentifier(id: '6'),
          title: 'Angaben zum Spielverhalten',
          text: 'Als nächstes werden wir Ihnen einige Fragen zu Handyspielen stellen!',
          buttonText: 'Los geht\'s!',
        ),
        QuestionStep(
            title: "Wie häufig spielen Sie Spiele am Handy/Tablet?",
            stepIdentifier: StepIdentifier(id: '7'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Täglich', value: '0'),
                TextChoice(text: 'Jeden 2. Tag', value: '1'),
                TextChoice(text: '1x/Woche', value: '2'),
                TextChoice(text: 'alle 2 Wochen', value: '3'),
                TextChoice(text: '1x/Monat', value: '4'),
                TextChoice(text: 'Seltener', value: '5'),
                TextChoice(text: 'Nie', value: '6'),
              ],
            )),
        QuestionStep(
            title:
                "An Tagen an denen Sie am Handy/Tablet spielen: Wie viele Stunden spielen Sie durchschnittlich?",
            stepIdentifier: StepIdentifier(id: '8'),
            answerFormat: const DoubleAnswerFormat(
              hint: 'Kommastellen mit . trennen',
            )),
        QuestionStep(
            title:
                "Wie viel Geld geben Sie durchschnittlich pro Monat innerhalb von Spielen für kostenpflichtige Zusatzfunktionen wie z.B. Spiele-Levels, Skins, Upgrades am Handy/am Tablet aus („In-App-Kauf“)?",
            stepIdentifier: StepIdentifier(id: '9'),
            answerFormat: const IntegerAnswerFormat(
              hint: 'Gerundet auf ganze Euros',
            )),
        CompletionStep(
            stepIdentifier: StepIdentifier(id: '10'),
            text: 'Danke für die Teilnahme an der Umfrage',
            title: 'Fertig!',
            buttonText: 'Umfrage beenden'),
      ],
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: getStepIdentifier(task, "1"),
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (input) {
          int age = int.parse(input!);
          if (age < 18 || age > 200) {
            return getStepIdentifier(task, "10");
          } else {
            return getStepIdentifier(task, "2");
          }
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: getStepIdentifier(task, "7"),
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "0":
          case '1':
          case '2':
          case "3":
          case "4":
          case "5":
            return getStepIdentifier(task, "8");
          case "6":
            return getStepIdentifier(task, "9");
          default:
            return getStepIdentifier(task, "9");
        }
      }),
    );
    return Future.value(task);
  }

  Future<Task> buildEndSurvey() {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
        InstructionStep(
          title: 'Vielen dank dass Sie sich Zeit nahmen um an der an der Studie teilzunehmen',
          text: 'Abschließend haben wir noch einige Fragen zur Studie!',
          buttonText: 'Los geht\'s!',
        ),
        QuestionStep(
            title: 'Haben Sie das Spiel bis zuletzt aktiv gespielt?',
            stepIdentifier: StepIdentifier(id: '1'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Ja', value: '0'),
                TextChoice(text: 'Nein', value: '1'),
              ],
            )),
        QuestionStep(
            title: "Warum haben Sie das Spiel nicht bis zuletzt gespielt?",
            stepIdentifier: StepIdentifier(id: '2'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Technische Probleme', value: '0'),
                TextChoice(text: 'Datenschutzbedenken', value: '1'),
                TextChoice(text: 'Grafik/Design gefiel mir nicht', value: '2'),
                TextChoice(text: 'Spiel war langweilig', value: '3'),
                TextChoice(text: 'Spiel war zu schwierig', value: '4'),
                TextChoice(text: 'Nicht mehr daran gedacht', value: '5'),
                TextChoice(text: 'fehlende Zeit', value: '6'),
                TextChoice(text: 'anderer Grund', value: '7'),
              ],
            )),
        QuestionStep(
            title:
                "Wurde Ihr Spielverhalten durch bestimmte Aktionen/Features im Spiel beeinflusst ? ",
            stepIdentifier: StepIdentifier(id: '3'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Ja', value: '0'),
                TextChoice(text: 'Nein', value: '1'),
              ],
            )),
        QuestionStep(
            title: "Wie wurde durch diese Aktionen/Features die Dauer des Spielens beeinflusst?",
            stepIdentifier: StepIdentifier(id: '4'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'längere Spielzeit', value: '0'),
                TextChoice(text: 'kürzere Spielzeit', value: '1'),
                TextChoice(text: 'nicht beeinflusst', value: '2'),
              ],
            )),
        QuestionStep(
            title: "Wie wurde durch diese Aktionen/Features die Häufigkeit des Spielens "
                "beeinflusst?",
            stepIdentifier: StepIdentifier(id: '5'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'häufiger gespielt', value: '0'),
                TextChoice(text: 'seltener gespielt', value: '1'),
                TextChoice(text: 'nicht beeinflusst', value: '2'),
              ],
            )),
        QuestionStep(
            title: "Was ist ihnen aufgefallen?",
            stepIdentifier: StepIdentifier(id: '6'),
            answerFormat: const MultipleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Tägliche Belohnung zum Einsammeln', value: '0'),
                TextChoice(text: 'Variable Belohnungen (=Glücksrad)', value: '1'),
                TextChoice(text: 'Punktetabelle mit Rangfolge der Spieler*innen', value: '2'),
                TextChoice(text: 'Push-Nachrichten die zum Spielen animieren', value: '3'),
                TextChoice(text: 'Level waren in Blöcken angeordnet', value: '4'),
                TextChoice(text: 'alle der genannten', value: '5'),
                TextChoice(text: 'keines der genannten ', value: '6'),
              ],
            )),
        QuestionStep(
            title: "Was davon hat Ihr Spielverhalten beeinflusst?",
            stepIdentifier: StepIdentifier(id: '7'),
            answerFormat: const MultipleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Tägliche Belohnung zum Einsammeln', value: '0'),
                TextChoice(text: 'Variable Belohnungen (=Glücksrad)', value: '1'),
                TextChoice(text: 'Punktetabelle mit Rangfolge der Spieler*innen', value: '2'),
                TextChoice(text: 'Push-Nachrichten die zum Spielen animieren', value: '3'),
                TextChoice(text: 'Level waren in Blöcken angeordnet', value: '4'),
                TextChoice(text: 'alle der genannten', value: '5'),
                TextChoice(text: 'keines der genannten ', value: '6'),
              ],
            )),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '8'),
          text: 'Danke für die Teilnahme an der Umfrage und an der Studie',
          title: 'Fertig!',
          buttonText: 'Studie beenden',
        ),
      ],
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[1].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "1":
            return task.steps[8].stepIdentifier;
          default:
            return task.steps[2].stepIdentifier;
        }
      }),
    );
    return Future.value(task);
  }

  StepIdentifier getStepIdentifier(NavigableTask task, String stepIdentifier) {
    return task.steps.where((e) => e.stepIdentifier.id == stepIdentifier).first.stepIdentifier;
  }
}
