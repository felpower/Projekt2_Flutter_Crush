// ignore_for_file: avoid_print
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import 'dark_patterns_service.dart';

class FirebaseStore {
  static FirebaseDatabase database = FirebaseDatabase.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static const String uuid = 'uuid';
  static const String darkPatterns = 'darkPatterns';
  static const String addScreenClick = 'addScreenClick';
  static const String pushToken = 'pushToken';
  static const String grantedPushPermission = 'grantedPushPermission';
  static const String startOfLevel = 'startOfLevel';
  static const String finishOfLevel = 'finishOfLevel';
  static const String checkHighScoreTime = 'checkHighScoreTime';
  static const String levelBought = 'levelBought';
  static const String itemBought = 'itemBought';
  static const String collectDailyRewardsTime = 'collectDailyRewardsTime';
  static const String appStartDate = 'appStartDate';
  static const String initAppStartTime = 'initAppStartTime';
  static const String initAppStartDate = 'initAppStartDate';
  static const String appCloseTime = 'appCloseTime';
  static const String watchedAddTime = 'watchedAddTime';
  static const String pushClick = 'pushClick';
  static const String startSurvey = 'startSurvey';
  static const String endSurvey = 'endSurvey';
  static const String userDeleted = 'userDeleted';
  static const String completeUserData = 'completeUserData';
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static final Random _rnd = Random();

  static Future<void> init() async {
    await getUuid();
    addUser();
  }

  static Future<void> addInitApp(DateTime date) async {
    await _updateDocument(initAppStartTime, date.toString());
  }

  static Future<void> checkHighScore(DateTime dateTime) async {
    await _updateDocument(checkHighScoreTime, dateTime.toString());
  }

  static Future<void> collectedDailyRewards(DateTime dateTime) async {
    await _updateDocument(collectDailyRewardsTime, dateTime.toString());
  }

  static Future<void> addStartOfLevel(int levelNumber) async {
    await _updateDocument(
        startOfLevel, 'Level: $levelNumber, Time: ${DateTime.now()}');
  }

  static Future<void> addFinishOfLevel(int levelNumber, bool won) async {
    await _updateDocument(finishOfLevel,
        'Level: $levelNumber, Won: $won, Time: ${DateTime.now()}');
  }

  static Future<void> addStartApp(DateTime dateTime) async {
    await _updateDocument(appStartDate, dateTime.toString());
  }

  static Future<void> addCloseApp(DateTime dateTime) async {
    await _updateDocument(appCloseTime, dateTime.toString());
  }

  static Future<void> watchedAdd(DateTime dateTime) async {
    await _updateDocument(watchedAddTime, dateTime.toString());
  }

  static Future<void> grantPushPermission(bool granted) async {
    await _updateDocument(
        grantedPushPermission, 'Granted: $granted, Time: ${DateTime.now()}');
  }

  static Future<void> currentPushToken(String token) async {
    await _updateDocument(pushToken, 'Token: $token, Time: ${DateTime.now()}');
  }

  static Future<void> addNotificationTap(DateTime dateTime) async {
    await _updateDocument(pushClick, dateTime.toString());
  }

  static void sendStartSurvey(List<String> jsonResult) async {
    await _updateDocument(startSurvey, 'SurveyResult: $jsonResult');
  }

  static void sendEndSurvey(List<String> jsonResult) async {
    await _updateDocument(endSurvey, 'SurveyResult: $jsonResult');
  }

  static void sendUserAgent({website = false}) async {
    var userAgent = html.window.navigator.userAgent;
    await _updateDocument(
        'userAgent', 'UserAgent: $userAgent, Website: $website');
  }

  static void sendUserDeleted() async {
    await _updateDocument(userDeleted, 'User deleted');
  }

  static void addLevelBought(int levelNumber) async {
    await _updateDocument(
        levelBought, 'Level: $levelNumber, Time: ${DateTime.now()}');
  }

  static void addItemBought(String item) async {
    await _updateDocument(itemBought, 'Item: $item, Time: ${DateTime.now()}');
  }

  static Future<void> _updateDocument(
      String documentPropertyName, String information) async {
    var userId = await getUuid();
    getDatabaseRef(userId).child(documentPropertyName).push().set(information);
  }

  static DatabaseReference getDatabaseRef(String userId) {
    DatabaseReference ref;
    if (kDebugMode) {
      ref = database.ref("debug/$userId");
    } else if (userId.contains('flutter')) {
      ref = database.ref("flutter/$userId");
    } else if (userId.contains('felpower')) {
      ref = database.ref("felpower/$userId");
    } else {
      ref = database.ref("users/$userId");
    }
    return ref;
  }

  static addUser() async {
    var userId = await getUuid();
    int darkPatternsState =
        await DarkPatternsService.shouldDarkPatternsBeVisible();
    final data = {
      uuid: userId,
      darkPatterns: darkPatternsState,
    };
    getDatabaseRef(userId).update(data);

    FlutterError.onError = (FlutterErrorDetails details) {
      sendError(details.exceptionAsString(), isFlutterError: true);
    };
  }

  static void sendError(String error,
      {stacktrace = "", isFlutterError = false, extraInfo = ""}) async {
    print(error);
    try {
      var userId = await getUuid();
      final data = {
        'error': error,
        'stacktrace': stacktrace,
        'userAgent': html.window.navigator.userAgent,
        'isFlutterError': isFlutterError,
        'timestamp': DateTime.now().toIso8601String(),
        'extraInfo': extraInfo,
      };
      DatabaseReference ref = database.ref("errors/$userId");
      ref.push().set(data);
    } catch (e) {
      print('Failed to send error: $e');
    }
  }

  static Future<void> sendFeedback(String info, html.File? file) async {
    try {
      var userId = await getUuid();
      final String userAgent = html.window.navigator.userAgent;
      String uploadedFileId = _getRandomString(15);
      var taskSnapshot =
          await storage.ref('feedback/$uploadedFileId').putBlob(file);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      final data = {
        'info': info,
        'userAgent': userAgent,
        'uuid': userId,
        'fileId': uploadedFileId,
        'timestamp': DateTime.now().toIso8601String(),
        'fileUrl': downloadUrl,
      };
      DatabaseReference ref = database.ref("feedback/$uploadedFileId");
      ref.push().set(data);

      Fluttertoast.showToast(msg: 'Feedback sent successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error sending feedback: $e');
    }
  }

  static Future<String> getUuid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString(uuid);
    if (response != null) {
      return response;
    }
    final newUuid = _getRandomString(15);
    prefs.setString(uuid, newUuid);
    return newUuid;
  }

  static String _getRandomString(int length) {
    var currentVersion = getCurrentVersion();
    return "$currentVersion${DateFormat('yy-MM-dd–kk:mm').format(DateTime.now())}-${String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))))}";
  }

  static String getCurrentVersion() {
    String hostname = Uri.parse(html.window.location.href).host;
    String version = "";
    if (hostname.contains('localhost')) {
      return "testVersion-V20-";
    }
    if (hostname.contains('felpower')) {
      return "felpower-V20-";
    }
    if (hostname.contains('flutter')) {
      return "flutter-V20-";
    }
    return "${version}V20-";
  }

  static Future<void> sendLog(String log, message) async {
    try {
      var userId = await getUuid();
      final data = {
        'log': log,
        'message': message,
        'userAgent': html.window.navigator.userAgent,
        'timestamp': DateTime.now().toIso8601String(),
      };
      DatabaseReference ref = database.ref("logs/$userId");
      ref.push().set(data);
    } catch (e) {
      print('Failed to send logs: $e');
    }
  }
}
