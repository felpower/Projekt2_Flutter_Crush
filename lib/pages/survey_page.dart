import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';

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
            future: getSampleTask(),
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
                          if (questionResult.result is TextChoice) {
                            resultString.add((questionResult.result as TextChoice).text);
                          } else {
                            resultString.add(questionResult.result.toString());
                          }
                        }
                      }
                    }
                    print("final Score is $resultString");
                    /* call a new widget to show the results*/
                    // final jsonResult = result.toJson();
                    // print("ToJSON: $jsonResult");
                    // ReportingService().sendSurvey(jsonResult); //FixMe: Add to DB
                    Navigator.pop(context);
                  },
                  task: task,
                  showProgress: true,
                  localizations: const {
                    'cancel': 'Cancel',
                    'next': 'Next',
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

  Future<Task> getSampleTask() {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
        InstructionStep(
          title: 'Willkommen zur \nArbeiterkammer\n Survey',
          text: 'Mach Sie sich bereit für einen Haufen super zufälliger Fragen!',
          buttonText: 'Let\'s go!',
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
                TextChoice(text: 'Männlich', value: 'M'),
                TextChoice(text: 'Weiblich', value: 'W'),
                TextChoice(text: 'Nicht-Binär', value: 'NB'),
              ],
            )),
        QuestionStep(
            title: "Was ist ihr höchster Bildungsabschluss",
            stepIdentifier: StepIdentifier(id: '3'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Neue Mittelschule', value: 'NMS'),
                TextChoice(text: 'höhere Schule/Fachschule', value: 'ABHSA'),
                TextChoice(text: 'Lehrabschluss', value: 'LA'),
                TextChoice(text: 'Matura', value: 'MA'),
                TextChoice(text: 'Diplomstudium', value: 'DS'),
                TextChoice(text: 'Bachelor', value: 'MS'),
                TextChoice(text: 'Master', value: 'MS'),
                TextChoice(text: 'Doktor', value: 'DR'),
              ],
            )),
        QuestionStep(
            title: "Was ist ihr derzeitiger Berufs-status",
            stepIdentifier: StepIdentifier(id: '4'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Arbeiter*in', value: 'ARB'),
                TextChoice(text: 'Angestellte*r', value: 'ANG'),
                TextChoice(text: 'Pensionist*in', value: 'PEN'),
                TextChoice(text: 'Student*in', value: 'Stu'),
                TextChoice(text: 'Erwerbslos', value: 'ERW'),
                TextChoice(text: 'Schüler*in', value: 'SCH'),
              ],
            )),
        QuestionStep(
            title: "Wo ist ihr aktueller Wohnort?",
            stepIdentifier: StepIdentifier(id: '5'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Österreich', value: 'AT'),
                TextChoice(text: 'Deutschland', value: 'DE'),
                TextChoice(text: 'Schweiz', value: 'SW'),
                TextChoice(text: 'Anderes', value: 'AND'),
              ],
            )),
        InstructionStep(
          stepIdentifier: StepIdentifier(id: '6'),
          title: 'Handyspezifische Fragen',
          text: 'Als nächstes werden wir Ihnen einige Fragen zum Handyspielen stellen!',
          buttonText: 'Let\'s go!',
        ),
        QuestionStep(
            title: "Wie oft spielen sie mit Ihrem Handy/Tablet",
            stepIdentifier: StepIdentifier(id: '7'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Täglich', value: 'ZEITTAG'),
                TextChoice(text: 'Jeden 2 Tag', value: 'ZEIT2TAG'),
                TextChoice(text: 'Ca. 1x die Woche', value: 'ZEIT1WOCH'),
                TextChoice(text: 'alle 2 Wochen', value: 'ZEIT2WOCH'),
                TextChoice(text: '1x im Monat', value: 'ZEITMON'),
                TextChoice(text: 'seltener', value: 'ZEITSEL'),
                TextChoice(text: 'Nie', value: 'ZEITNIE'),
              ],
            )),
        QuestionStep(
            title: "Wie lange spielen sie im Durchschnitt täglich am Handy/Tablet in Stunden",
            stepIdentifier: StepIdentifier(id: '8'),
            answerFormat: const ScaleAnswerFormat(
              minimumValue: 0,
              maximumValue: 24,
              defaultValue: 12,
              step: 1,
            )),
        QuestionStep(
            title: "Wie lange spielen sie im Durchschnitt wöchentlich am Handy/Tablet in Stunden",
            stepIdentifier: StepIdentifier(id: '9'),
            answerFormat: const ScaleAnswerFormat(
              minimumValue: 0,
              maximumValue: 30,
              defaultValue: 15,
              step: 1,
            )),
        QuestionStep(
            title: "Wie lange spielen sie im Durchschnitt monatlich am Handy/Tablet in Stunden",
            stepIdentifier: StepIdentifier(id: '10'),
            answerFormat: const ScaleAnswerFormat(
              minimumValue: 0,
              maximumValue: 30,
              defaultValue: 15,
              step: 1,
            )),
        QuestionStep(
            title: "Wie oft geben Sie Geld bei Spielen am Handy/Tablet aus",
            stepIdentifier: StepIdentifier(id: '11'),
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Täglich', value: 'GELDTAG'),
                TextChoice(text: 'Jeden 2 Tag', value: 'GELD2TAG'),
                TextChoice(text: 'Ca. 1x die Woche', value: 'GELD1WOCH'),
                TextChoice(text: 'alle 2 Wochen', value: 'GELD2WOCH'),
                TextChoice(text: '1x im Monat', value: 'GELDMON'),
                TextChoice(text: 'seltener', value: 'GELDSEL'),
                TextChoice(text: 'Nie', value: 'GELDNIE'),
              ],
            )),
        QuestionStep(
            title: "Wie wie Geld geben sie im Durchschnitt täglich am Handy/Tablet aus",
            stepIdentifier: StepIdentifier(id: '12'),
            answerFormat: const ScaleAnswerFormat(
              minimumValue: 0,
              maximumValue: 24,
              defaultValue: 12,
              step: 1,
            )),
        QuestionStep(
            title: "Wie wie Geld geben sie im Durchschnitt wöchentlich am Handy/Tablet in Stunden"
                " aus",
            stepIdentifier: StepIdentifier(id: '13'),
            answerFormat: const ScaleAnswerFormat(
              minimumValue: 0,
              maximumValue: 30,
              defaultValue: 15,
              step: 1,
            )),
        QuestionStep(
            title: "Wie wie Geld geben sie im Durchschnitt monatlich am Handy/Tablet in Stunden "
                "aus",
            stepIdentifier: StepIdentifier(id: '14'),
            answerFormat: const ScaleAnswerFormat(
              minimumValue: 0,
              maximumValue: 30,
              defaultValue: 15,
              step: 1,
            )),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '15'),
          text: 'Thanks for taking the survey, we will contact you soon!',
          title: 'Done!',
          buttonText: 'Submit survey',
        ),
      ],
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[1].stepIdentifier,
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (input) {
          int age = int.parse(input!);
          if (age < 18 || age > 120) {
            return task.steps[15].stepIdentifier;
          } else {
            return task.steps[2].stepIdentifier;
          }
        },
      ),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[7].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "ZEITTAG":
          case 'ZEIT2TAG':
            return task.steps[8].stepIdentifier;
          case 'ZEIT1WOCH':
          case "ZEIT2WOCH":
            return task.steps[9].stepIdentifier;
          case "ZEITMON":
            return task.steps[10].stepIdentifier;
          case "ZEITSEL":
          case "ZEITNIE":
            return task.steps[11].stepIdentifier;
          default:
            return task.steps[11].stepIdentifier;
        }
      }),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[8].stepIdentifier,
      navigationRule: DirectNavigationRule(task.steps[11].stepIdentifier),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[9].stepIdentifier,
      navigationRule: DirectNavigationRule(task.steps[11].stepIdentifier),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[11].stepIdentifier,
      navigationRule: ConditionalNavigationRule(resultToStepIdentifierMapper: (input) {
        switch (input) {
          case "GELDTAG":
          case 'GELD2TAG':
            return task.steps[12].stepIdentifier;
          case 'GELD1WOCH':
          case "GELD2WOCH":
            return task.steps[13].stepIdentifier;
          case "GELDMON":
            return task.steps[14].stepIdentifier;
          case "GELDSEL":
          case "GELDNIE":
            return task.steps[15].stepIdentifier;
          default:
            return task.steps[15].stepIdentifier;
        }
      }),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[12].stepIdentifier,
      navigationRule: DirectNavigationRule(task.steps[15].stepIdentifier),
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[13].stepIdentifier,
      navigationRule: DirectNavigationRule(task.steps[15].stepIdentifier),
    );
    return Future.value(task);
  }

  Future<Task> getJsonTask() async {
    final taskJson = await rootBundle.loadString('assets/example_json.json');
    final taskMap = json.decode(taskJson);

    return Task.fromJson(taskMap);
  }
}
