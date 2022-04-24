import 'dart:developer' as dev;
import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:bachelor_flutter_crush/persistence/dark_patterns_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportingService {
  static const String collectionId = '622c77a86c1c479fe0af';
  static const String endpointUrl = 'https://server.flutter-crush.tk/v1';
  static const String projectId = '62233cfed4c5a2f3bf3d';

  static const String uuid = 'uuid';
  static const String darkPatterns = 'darkPatterns';
  static const String addScreenClick = 'addScreenClick';
  static const String startOfLevel = 'startOfLevel';
  static const String bootAppStartTime = 'bootAppStartTime';
  static const String closeAppTime = 'closeAppTime';
  static const String notificationTap = 'notificationTap';

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static Client client = Client();
  static Database database = Database(client);
  static Account account = Account(client);

  static Future<void> addAdvertisementTap(double x, double y) async {
    await _updateDocumentData(addScreenClick, 'x: ' + x.toStringAsFixed(2) + ', y:' + y.toStringAsFixed(2));
  }

  static Future<void> addStartOfLevel(int levelNumber) async {
    await _updateDocumentData(startOfLevel,'Level: ' + levelNumber.toString() + ', time: ' + DateTime.now().toString());
  }

  static Future<void> addStartApp(DateTime dateTime) async {
    await _updateDocumentData(bootAppStartTime, dateTime.toString());
  }

  static Future<void> addCloseApp(DateTime dateTime) async{
    await _updateDocumentData(closeAppTime, dateTime.toString());
  }

  static Future<void> addNotificationTap(DateTime dateTime, String? multiplier) async {
    multiplier ??= '';
    await _updateDocumentData(notificationTap, 'Multiplier: ' + multiplier + ', Time: ' + dateTime.toString());
  }

  static Future<void> _updateDocumentData(String documentPropertyName, String data) async {
    Document document = await database.getDocument(
        collectionId: collectionId, documentId: await _getUuid());
    List<dynamic> dataList = document.data[documentPropertyName];
    List<String> documentData = dataList.cast<String>();
    dataList.add(data);

    database.updateDocument(collectionId: collectionId, documentId: await _getUuid(), data: {
      documentPropertyName: documentData
    });
  }

  static Future<void> init() async {
    _initClient();

    SessionList? sessions;
    try {
      sessions = await account.getSessions();
    } catch (e) {
      dev.log(e.toString());
      dev.log('session not found');
    }
    if (sessions == null) {
      await account.createAnonymousSession();
    }
    _addDocumentIfItDoesNotExist();
  }

  static void _addDocumentIfItDoesNotExist() async {
    Document? document;
    try {
      document = await database.getDocument(
          collectionId: collectionId, documentId: await _getUuid());
    } catch (e) {
      dev.log(e.toString());
      dev.log("could not find file");
    }

    if (document != null) {
      return;
    }
    bool shouldDarkPatternsBeVisible = await DarkPatternsService.shouldDarkPatternsBeVisible();
    final planetsByDiameter = {
      uuid: await _getUuid(),
      darkPatterns: shouldDarkPatternsBeVisible,
      bootAppStartTime: [],
      closeAppTime: [],
      addScreenClick: [],
      startOfLevel: [],
      notificationTap: []
    };

    database.createDocument(
        collectionId: collectionId,
        documentId: await _getUuid(),
        data: planetsByDiameter);
  }

  static void _initClient() {
    client.setEndpoint(endpointUrl).setProject(projectId).setSelfSigned();
  }

  static Future<String> _getUuid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString(uuid);
    if (response != null) {
      return response;
    }
    final newUuid = _getRandomString(15);
    prefs.setString(uuid, newUuid);
    return newUuid;
  }

  static String _getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
