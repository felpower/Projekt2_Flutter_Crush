// ignore_for_file: avoid_print
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
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
  static const String paidForRemovingAdds = 'paidForRemovingAdds';
  static const String pushToken = 'pushToken';
  static const String grantedPushPermission = 'grantedPushPermission';
  static const String startOfLevel = 'startOfLevel';
  static const String finishOfLevel = 'finishOfLevel';
  static const String checkHighScoreTime = 'checkHighScoreTime';

  static const String collectDailyRewardsTime = 'collectDailyRewardsTime';
  static const String appStartDate = 'appStartDate';
  static const String initAppStartTime = 'initAppStartTime';
  static const String initAppStartDate = 'initAppStartDate';
  static const String appCloseTime = 'appCloseTime';
  static const String pushClick = 'pushClick';
  static const String survey = 'survey';
  static const String completeUserData = 'completeUserData';
  static const String ratingApp = 'rating';
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static Future<void> init() async {
    await _getUuid();
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCcBYFUJbTyRWUjy6dhLbLLEj_lwhqnsh4",
            authDomain: "darkpatterns-ac762.firebaseapp.com",
            databaseURL:
                "https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app",
            projectId: "darkpatterns-ac762",
            storageBucket: "darkpatterns-ac762.appspot.com",
            messagingSenderId: "552263184384",
            appId: "1:552263184384:web:87e17944dc571dc4e028e5"));
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
    await _updateDocument(startOfLevel, 'Level: $levelNumber, Time: ${DateTime.now()}');
  }

  static Future<void> addFinishOfLevel(int levelNumber, bool won) async {
    await _updateDocument(finishOfLevel, 'Level: $levelNumber, Won: $won Time: ${DateTime.now()}');
  }

  static Future<void> addStartApp(DateTime dateTime) async {
    await _updateDocument(appStartDate, dateTime.toString());
  }

  static Future<void> addCloseApp(DateTime dateTime) async {
    await _updateDocument(appCloseTime, dateTime.toString());
  }

  static Future<void> addRating(double rating) async {
    await _updateDocument(ratingApp, rating.toString());
  }

  static Future<void> removeAdds(bool removed) async {
    await _updateDocument(paidForRemovingAdds, 'Removed: $removed, Time: ${DateTime.now()}');
  }

  static Future<void> grantPushPermission(bool granted) async {
    await _updateDocument(grantedPushPermission, 'Granted: $granted, Time: ${DateTime.now()}');
  }

  static Future<void> currentPushToken(String token) async {
    await _updateDocument(pushToken, 'Token: $token, Time: ${DateTime.now()}');
  }

  static Future<void> addAdvertisementTap(double x, double y) async {
    await _updateDocument(addScreenClick, 'x: ${x.toStringAsFixed(2)}, y:${y.toStringAsFixed(2)}');
  }

  static Future<void> addNotificationTap(DateTime dateTime, [String multiplier = "2x"]) async {
    await _updateDocument(pushClick, 'Multiplier: $multiplier, Time: $dateTime');
  }

  static void sendSurvey(List<String> jsonResult) async {
    await _updateDocument(survey, 'SurveyResult: $jsonResult');
  }

  static Future<void> addUserData(Map userData) async {
    String firstName = userData['firstName'];
    String lastName = userData['lastName'];
    String email = userData['email'];
    String mobile = userData['mobile'];
    String dob = userData['dob'];
    await _updateDocument(
        completeUserData, 'Name: $firstName $lastName, Email: $email, Mobile: $mobile, DOB: $dob');
  }

  static Future<void> _updateDocument(String documentPropertyName, String information) async {
    var userId = await _getUuid();
    DatabaseReference ref = database.ref("users/$userId");
    ref.child(documentPropertyName).push().set(information);
  }

  static addUser() async {
    var userId = await _getUuid();
    bool shouldDarkPatternsBeVisible = await DarkPatternsService.shouldDarkPatternsBeVisible();
    final data = {
      uuid: userId,
      darkPatterns: shouldDarkPatternsBeVisible,
    };
    DatabaseReference ref = database.ref("users/$userId");
    ref.update(data);

    FlutterError.onError = (FlutterErrorDetails details) {
      sendError(details.exceptionAsString(), isFlutterError: true);
    };
  }

  static void sendError(String error, {stacktrace = "", isFlutterError = false}) async {
    print(error);
    try {
      var userId = await _getUuid();
      final data = {
        'error': error,
        'stacktrace': stacktrace,
        'userAgent': html.window.navigator.userAgent,
        'isFlutterError': isFlutterError,
        'timestamp': DateTime.now().toIso8601String(),
      };
      DatabaseReference ref = database.ref("errors/$userId");
      ref.set(data);
    } catch (e) {
      print('Failed to send error: $e');
    }
  }

  static Future<void> sendFeedback(String info, html.File? file) async {
    try {
      var userId = await _getUuid();
      final String userAgent = html.window.navigator.userAgent;
      String uploadedFileId = _getRandomString(15);
      var taskSnapshot = await storage.ref('feedback/$uploadedFileId').putBlob(file);
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
      ref.set(data);

      Fluttertoast.showToast(msg: 'Feedback sent successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error sending feedback: $e');
    }
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

  static String _getRandomString(int length) {
    return "V0-${DateFormat('yy-MM-dd–kk:mm').format(DateTime.now())}-${String.fromCharCodes
      (Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))))}";
  }
}
