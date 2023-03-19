import 'dart:developer' as dev;
import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:bachelor_flutter_crush/persistence/dark_patterns_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportingService {
  static const String endpointUrl = 'http://161.35.65.172/v1';
  static const String projectId = '64178a88883ddd21b350';
  static const String databaseId = '64178af11a3b242e891a';
  static const String collectionId = '64178afdbe4dab73b59a';

  static const String uuid = 'uuid';
  static const String darkPatterns = 'darkPatterns';
  static const String addScreenClick = 'addScreenClick';
  static const String paidForRemovingAdds = 'paidForRemovingAdds';
  static const String startOfLevel = 'startOfLevel';
  static const String checkHighScoreTime = 'checkHighScoreTime';
  static const String bootAppStartTime = 'bootAppStartTime';
  static const String closeAppTime = 'closeAppTime';
  static const String notificationTap = 'notificationTap';
  static const String ratingApp = 'rating';

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static Client client = Client();
  static Databases database = Databases(client);
  static Account account = Account(client);

  static Future<void> addAdvertisementTap(double x, double y) async {
    await _updateDocumentData(addScreenClick,
        'x: ' + x.toStringAsFixed(2) + ', y:' + y.toStringAsFixed(2));
  }

  static Future<void> addStartOfLevel(int levelNumber) async {
    await _updateDocumentData(
        startOfLevel,
        'Level: ' +
            levelNumber.toString() +
            ', Time: ' +
            DateTime.now().toString());
  }

  static Future<void> addStartApp(DateTime dateTime) async {
    await _updateDocumentData(bootAppStartTime, dateTime.toString());
  }

  static Future<void> checkHighScore(DateTime dateTime) async {
    await _updateDocumentData(checkHighScoreTime, dateTime.toString());
  }

  static Future<void> addCloseApp(DateTime dateTime) async {
    await _updateDocumentData(closeAppTime, dateTime.toString());
  }

  static Future<void> addRating(double rating) async {
    await _updateDocumentData(ratingApp, rating.toString());
  }

  static Future<void> removeAdds(bool removed) async {
    await _updateDocumentData(
        paidForRemovingAdds,
        'Removed: ' +
            removed.toString() +
            ', Time: ' +
            DateTime.now().toString());
  }

  static Future<void> addNotificationTap(
      DateTime dateTime, String? multiplier) async {
    multiplier ??= '';
    await _updateDocumentData(notificationTap,
        'Multiplier: ' + multiplier + ', Time: ' + dateTime.toString());
  }

  static Future<void> _updateDocumentData(
      String documentPropertyName, String data) async {
    models.Document document = await database.getDocument(
        collectionId: collectionId,
        documentId: await _getUuid(),
        databaseId: databaseId);
    List<dynamic> dataList = document.data[documentPropertyName];
    List<String> documentData = dataList.cast<String>();
    dataList.add(data);

    database.updateDocument(
        collectionId: collectionId,
        documentId: await _getUuid(),
        databaseId: databaseId,
        data: {documentPropertyName: documentData});
  }

  static Future<void> init() async {
    _initClient();

    models.SessionList? sessions;
    try {
      sessions = await account.listSessions();
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
    models.Document? document;
    try {
      document = await database.getDocument(
          collectionId: collectionId,
          databaseId: databaseId,
          documentId: await _getUuid());
    } catch (e) {
      dev.log(e.toString());
      dev.log("could not find file");
    }

    if (document != null) {
      return;
    }
    bool shouldDarkPatternsBeVisible =
        await DarkPatternsService.shouldDarkPatternsBeVisible();
    final planetsByDiameter = {
      uuid: await _getUuid(),
      darkPatterns: shouldDarkPatternsBeVisible,
      bootAppStartTime: [],
      closeAppTime: [],
      addScreenClick: [],
      startOfLevel: [],
      notificationTap: [],
      ratingApp: [],
      checkHighScoreTime: [],
      paidForRemovingAdds: []
    };

    database.createDocument(
        collectionId: collectionId,
        documentId: await _getUuid(),
        databaseId: databaseId,
        data: planetsByDiameter);
  }

  static void _initClient() {
    client
        .setEndpoint(endpointUrl)
        .setProject(projectId)
        .setSelfSigned(status: true);
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
