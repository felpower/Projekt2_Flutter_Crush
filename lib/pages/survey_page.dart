import 'package:bachelor_flutter_crush/pages/under_18_page.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_kit/survey_kit.dart';

import 'finished_survey_page.dart';
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
    return PopScope(
        canPop: false, // Prevents the user from using the back button
        child: Scaffold(
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
                              resultString.add(
                                  "ID: ${questionResult.id?.id.toString()}-${questionResult.valueIdentifier}");
                            }
                          }
                        }
                        if (widget.title.contains("Start")) {
                          sendStartSurvey(resultString);
                          Navigator.pop(context);
                          var age = int.parse(resultString[0].split("-").last);
                          if (age >= 18 && age <= 120) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const DeviceToken()));
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const Under18Page()));
                          }
                        } else {
                          sendEndSurvey(resultString);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const FinishedSurveyPage()));
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
        ));
  }

  Future<Task> buildStartSurvey() async {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
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
          title: 'Vor dem Spielstart',
          text: 'Vor dem Spielstart werden Ihnen noch ein paar Fragen zu Ihrer Person und Ihrem '
              'üblichen Spielverhalten gestellt. Dies wird maximal 5 Minuten in Anspruch nehmen. Bitte beantworten Sie alle Fragen ehrlich.   '
              'All ihre Daten (Angaben aus dem Fragebogen und Daten aus dem Spiel) werden auf einem Server, der in der EU (DSGVO konform) gehostet wird, anonymisiert (d.h. ohne einen möglichen Rückschluss auf Ihre Person; es werden keine personenbezogenen Daten erfasst) gespeichert und anschließend für wissenschaftliche Zwecke ausgewertet. Sie können jederzeit die Studienteilnahme beenden.',
          buttonText: 'weiter',
        ),
        InstructionStep(
          title: 'Willkommen!',
          text:
              'Wenn Sie über 18 Jahre alt sind und an der Studie teilnehmen möchten, klicken Sie bitte auf „Weiter“ und bestätigen so Ihr Einverständnis für die Studienteilnahme. ',
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
            title: "Welches Geschlecht haben Sie",
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
                TextChoice(text: 'Arbeitssuchend, Karenz', value: '2'),
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
            answerFormat: const DoubleAnswerFormat(
              hint: 'Kommastellen mit . trennen',
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
          if (age < 18) {
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
          title: 'Liebe Studienteilnehmer:innen, vielen Dank für Ihre Teilnahme.',
          text:
              'Zum Abschluss der Studie wären wir Ihnen dankbar, wenn Sie noch ein paar letzte Fragen beantworten würden. Dies wird maximal 5 Minuten in Anspruch nehmen. Alle Angaben sind anonym.'
              ' Vielen Dank!',
          buttonText: 'Weiter',
        ),
        QuestionStep(
            title: 'Haben Sie das Spiel bis zum Ende bzw. bis zum jetzigen Zeitpunkt gespielt?',
            stepIdentifier: StepIdentifier(id: '1'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Ja', value: '1'),
                TextChoice(text: 'Nein', value: '2'),
              ],
            )),
        QuestionStep(
            title:
                "Aus welchem Grund/welchen Gründen haben Sie das Spiel abgebrochen/nicht mehr gespielt?",
            stepIdentifier: StepIdentifier(id: '2'),
            answerFormat: const MultipleChoiceAnswerFormat(
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
                "Wenn Sie an das Spielen zurückdenken – hatten Sie während oder nach dem Spielen den Eindruck, dass bestimmte Spiel-Features Ihr Verhalten beeinflussen wollten?",
            stepIdentifier: StepIdentifier(id: '3'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Ja', value: '1'),
                TextChoice(text: 'Nein', value: '0'),
              ],
            )),
        InstructionStep(
            title: "",
            stepIdentifier: StepIdentifier(id: '4'),
            text:
                "Inwiefern hatten Sie das Gefühl, Ihr Spielverhalten sei möglicherweise beeinflusst worden?"),
        QuestionStep(
            title: "Spieldauer",
            stepIdentifier: StepIdentifier(id: '5'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'längere Spielzeit', value: '2'),
                TextChoice(text: 'kürzere Spielzeit', value: '1'),
                TextChoice(text: 'nicht beeinflusst', value: '0'),
              ],
            )),
        QuestionStep(
            title: "Spielhäufigkeit",
            stepIdentifier: StepIdentifier(id: '6'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'häufiger gespielt', value: '2'),
                TextChoice(text: 'seltener gespielt', value: '1'),
                TextChoice(text: 'nicht beeinflusst', value: '0'),
              ],
            )),
        QuestionStep(
            title:
                "Bei welchen dieser Features hatten Sie den Eindruck, dass davon Ihr Spielverhalten beeinflusst wurde?",
            stepIdentifier: StepIdentifier(id: '7'),
            answerFormat: const MultipleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Tägliche Belohnung zum Einsammeln', value: '1'),
                TextChoice(text: 'Variable Belohnungen (=Glücksrad)', value: '2'),
                TextChoice(text: 'Punktetabelle mit Rangfolge der Spieler*innen', value: '3'),
                TextChoice(text: 'Push-Nachrichten die zum Spielen animieren', value: '4'),
                TextChoice(text: 'Level waren in Blöcken angeordnet', value: '5'),
                TextChoice(text: 'alle der genannten', value: '6'),
                TextChoice(text: 'keines der genannten ', value: '0'),
              ],
            )),
        QuestionStep(
            title: "Haben Sie Push-Nachrichten erhalten?",
            stepIdentifier: StepIdentifier(id: '8'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Ja', value: '1'),
                TextChoice(text: 'Nein', value: '0'),
              ],
            )),
        QuestionStep(
            title: "Wie empfanden Sie die Häufigkeit der Push-Nachrichten?",
            stepIdentifier: StepIdentifier(id: '9'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Zu selten', value: '0'),
                TextChoice(text: 'Genau Richtig', value: '1'),
                TextChoice(text: 'Zu oft', value: '2'),
              ],
            )),
        QuestionStep(
            title: "Wie passend war(en) die Uhrzeit(en) der Push-Nachricht(en) für Sie?",
            stepIdentifier: StepIdentifier(id: '10'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Sehr passend', value: '0'),
                TextChoice(text: 'Wenig passend', value: '1'),
                TextChoice(text: 'Gar nicht passend', value: '2'),
              ],
            )),
        QuestionStep(
            title: "Welche Uhrzeit(en) wäre(n) besser gewesen?",
            stepIdentifier: StepIdentifier(id: '11'),
            answerFormat: const TextAnswerFormat()),
        QuestionStep(
            title:
                "Möchten Sie zu dieser Studie oder zum besseren Verständnis Ihrer Antworten noch etwas anmerken?",
            stepIdentifier: StepIdentifier(id: '12'),
            isOptional: true,
            answerFormat: const TextAnswerFormat()),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '13'),
          text: '',
          title: '',
          buttonText: 'Studie beenden',
        ),
      ],
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[1].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "1":
            return task.steps[3].stepIdentifier;
          default:
            return task.steps[2].stepIdentifier;
        }
      }),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[3].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "0":
            return task.steps[13].stepIdentifier;
          default:
            return task.steps[4].stepIdentifier;
        }
      }),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[10].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "0":
            return task.steps[12].stepIdentifier;
          default:
            return task.steps[9].stepIdentifier;
        }
      }),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[10].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "0":
            return task.steps[12].stepIdentifier;
          default:
            return task.steps[11].stepIdentifier;
        }
      }),
    );
    return Future.value(task);
  }

  StepIdentifier getStepIdentifier(NavigableTask task, String stepIdentifier) {
    return task.steps.where((e) => e.stepIdentifier.id == stepIdentifier).first.stepIdentifier;
  }

  void sendStartSurvey(List<String> resultString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = DateTime.now();
    FirebaseStore.addInitApp(now);
    FirebaseStore.sendStartSurvey(resultString);
    prefs.setBool("firstStart", false);
    prefs.setString("firstStartTime", now.toString());
    FirebaseStore.sendUserAgent();
  }

  void sendEndSurvey(List<String> resultString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseStore.sendEndSurvey(resultString);
    prefs.setString("endSurvey", DateTime.now().toString());
  }
}
