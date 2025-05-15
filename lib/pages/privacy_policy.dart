import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              title: const Text('Datenschutzerklärung',
                  textAlign: TextAlign.center),
              centerTitle: true,
            ),
            body: Center(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(
                            text:
                                '''Datenschutz und Datensicherheit bei der Nutzung unserer Websites sind für uns sehr wichtig. Wir möchten Sie daher an dieser Stelle darüber informieren, welche Ihrer personenbezogenen Daten wir bei Ihrem Besuch auf unseren Websites erfassen und für welche Zwecke diese genutzt werden. Wichtig ist, dass die im Rahmen dieses Angebotes gespeicherten Daten ausschließlich für die Nutzung der angebotenen Plattform gespeichert werden und nicht mit anderen Daten der Projektbetreiber verknüpft werden. Verantwortlicher im Sinne der DSGVO ist:

Kammer für Arbeiter und Angestellte für Niederösterreich (AK Niederösterrreich)
AK-Platz 1
3100 St. Pölten
mailbox@aknoe.at
+43 (0)5 7171

Die Datenschutzerklärung der AK Niederösterreich ist hier abrufbar: ''',
                          ),
                          TextSpan(
                            text: 'https://noe.arbeiterkammer.at/datenschutz',
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(
                                    'https://noe.arbeiterkammer.at/datenschutz');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                          ),
                          const TextSpan(text: '''

Eine Zusammenführung der verschiedenen Daten findet nicht statt.

Für die Nutzung des Spiels wird eine zufällig erzeugte ID für die Dauer der Simulation erstellt und der Zugriff auf gstaic.com (von Google) für die Push-Benachrichtigungen benötigt. Da dies für die Funktion unumgänglich ist, stellt hier Art. 6 Abs. 1 lit b DSGVO die Rechtsgrundlage dar. Die Speicherung erfolgt für die Dauer der Simulation.

Sie haben das Recht auf Auskunft, Berichtigung, Löschung oder Einschränkung der Verarbeitung Ihrer gespeicherten Daten, ein Widerspruchsrecht gegen die Verarbeitung sowie ein Recht auf Datenübertragbarkeit und auf Beschwerde gemäß den geltenden Bestimmungen des Datenschutzrechts. Sofern Sie eines der genannten Rechte uns gegenüber geltend machen wollen, so wenden Sie sich datenschutz@aknoe.at oder am Postweg an den:
Datenschutzbeauftragten der AK Niederösterreich
AK-Platz 1
3100 St. Pölten

Im Zweifel können wir zusätzliche Informationen zur Bestätigung Ihrer Identität anfordern. Dies dient dem Schutz Ihrer Rechte und Ihrer Privatsphäre.

Auskunftsrecht
Sie können von uns Auskunft darüber verlangen, ob und in welchem Ausmaß wir Ihre Daten verarbeiten. Recht auf Berichtigung Falls wir Daten über Sie verarbeiten, die unvollständig oder unrichtig sind, so können Sie von uns deren Berichtigung bzw. Vervollständigung verlangen.

Recht auf Löschung
Sie können von uns unter gewissen Umständen die Löschung Ihrer Daten verlangen. Bitte beachten Sie aber, dass wir Ihre Daten nur löschen können, sofern der Löschung keine anderen gesetzliche Regelungen entgegenstehen, wie z.B. gesetzlich geregelte Aufbewahrungspflichten.

Recht auf Einschränkung der Verarbeitung
Ihnen steht es auch zu, die Einschränkung der Verarbeitung Ihrer Daten zu verlangen, wenn Sie die Richtigkeit der Daten bestreiten, die Verarbeitung der Daten unrechtmäßig ist, Sie aber eine Löschung ablehnen und stattdessen eine Einschränkung der Datennutzung verlangen, wir die Daten für den vorgesehenen Zweck nicht mehr benötigen, Sie diese Daten aber noch zur Geltendmachung oder Verteidigung von Rechtsansprüchen brauchen, oder Sie Widerspruch gegen die Verarbeitung der Daten eingelegt haben.

Recht auf Datenübertragbarkeit
Sie können von uns verlangen, dass wir Ihnen die zu Ihrer Person verarbeiteten Daten, die Sie uns bereitgestellt haben, in einem strukturierten, gängigen und maschinenlesbaren Format zur Verfügung stellen. Somit können Sie diese Daten problemlos einem anderen Verantwortlichen übermitteln, sofern wir diese Daten aufgrund einer von Ihnen erteilten und widerrufbaren Zustimmung oder zur Erfüllung eines Vertrages zwischen uns verarbeiten, und diese Verarbeitung mithilfe automatisierter Verfahren erfolgt. Sie können uns auch mit der direkten Übermittlung Ihrer Daten an einen anderen Verantwortlichen beauftragen, sofern dies technisch möglich ist.

Widerspruchsrecht
Wir verarbeiten Ihre Daten aus berechtigtem Interesse, so können Sie gegen diese Datenverarbeitung in begründeten Einzelfällen Widerspruch einlegen. Der Widerspruch kann von uns dann nicht berücksichtigt werden, insofern wir zwingende schutzwürdige Gründe für die Verarbeitung nachweisen können, die Ihre Interessen, Rechte und Freiheiten überwiegen oder wenn die Verarbeitung der Geltendmachung, Ausübung oder Verteidigung von Rechtsansprüchen dient. Wenn Sie von uns Informationen erhalten und diese zukünftig nicht mehr erhalten wollen, können Sie jederzeit ohne Angaben von Gründen widersprechen.

Beschwerderecht
Sind Sie der Meinung, dass wir Ihre Daten auf unzulässige Weise verarbeiten? Dann nehmen Sie bitte Kontakt mit uns auf, damit wir versuchen können, allfällige Fragen oder Missverständnisse aufzuklären. Zusätzlich haben Sie natürlich auch das Recht, sich bei der Österreichischen Datenschutzbehörde zu beschweren.
Österreichische Datenschutzbehörde
Barichgasse 40-42, 1030 Wien
dsb@dsb.gv.at

''')
                        ],
                      ))
                ],
              ),
            ))));
  }
}
