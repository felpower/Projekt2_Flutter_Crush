// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer' as dev;
// import 'dart:html' as html;
// import 'dart:math';
// import 'dart:typed_data';
//
// import 'package:bachelor_flutter_crush/persistence/dark_patterns_service.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ReportingService {
// static const String endpointUrl = 'https://cloud.appwrite.io/v1';
// static const String projectId = '650033bf2a56bd416943';
// static const String databaseId = '6500415a6fabcd65fbab';
// static const String collectionId = '6500416c5d0dc4c25a24';
// static const String errorCollectionId = '651ecf01ea5bfd9d7d47';
// static const String feedbackCollectionId = '651fe3520770d805b449';
// static const String feedbackBucketId = '651fe28fc0074e462967';
// static const String uuid = 'uuid';
// static const String darkPatterns = 'darkPatterns';
// static const String addScreenClick = 'addScreenClick';
// static const String paidForRemovingAdds = 'paidForRemovingAdds';
// static const String startOfLevel = 'startOfLevel';
// static const String checkHighScoreTime = 'checkHighScoreTime';
//
// static const String collectDailyRewardsTime = 'collectDailyRewardsTime';
// static const String bootAppStartTime = 'bootAppStartTime';
// static const String initAppStartTime = 'initAppStartTime';
// static const String closeAppTime = 'closeAppTime';
// static const String notificationTap = 'notificationTap';
// static const String completeUserData = 'completeUserData';
// static const String ratingApp = 'rating';
//
// static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
// static final Random _rnd = Random();
// static Client client = Client();
// static Databases database = Databases(client);
// static Account account = Account(client);
//
// static Storage storage = Storage(client);

// static Future<void> addAdvertisementTap(double x, double y) async {
//   await _updateDocumentData(
//       addScreenClick, 'x: ${x.toStringAsFixed(2)}, y:${y.toStringAsFixed(2)}');
// }
//
// static Future<void> addStartOfLevel(int levelNumber) async {
//   await _updateDocumentData(startOfLevel, 'Level: $levelNumber, Time: ${DateTime.now()}');
// }
//
// static Future<void> addStartApp(DateTime dateTime) async {
//   await _updateDocumentData(bootAppStartTime, dateTime.toString());
// }
//
// static Future<void> addInitApp(DateTime dateTime) async {
//   await _updateDocumentData(initAppStartTime, dateTime.toString());
// }
//
// static Future<void> addCloseApp(DateTime dateTime) async {
//   await _updateDocumentData(closeAppTime, dateTime.toString());
// }
// static Future<void> addRating(double rating) async {
//   await _updateDocumentData(ratingApp, rating.toString());
// }
//
// static Future<void> removeAdds(bool removed) async {
//   await _updateDocumentData(paidForRemovingAdds, 'Removed: $removed, Time: ${DateTime.now()}');
// }
//
// static Future<void> addNotificationTap(DateTime dateTime, String? multiplier) async {
//   multiplier ??= '';
//   await _updateDocumentData(notificationTap, 'Multiplier: $multiplier, Time: $dateTime');
// }

// static Future<void> addUserData(Map userData) async {
//   String firstName = userData['firstName'];
//   String lastName = userData['lastName'];
//   String email = userData['email'];
//   String mobile = userData['mobile'];
//   String dob = userData['dob'];
//   await _updateDocumentData(
//       completeUserData, 'Name: $firstName $lastName, Email: $email, Mobile: $mobile, DOB: $dob');
// }
//
// static Future<void> _updateDocumentData(String documentPropertyName, String data) async {
//   models.Document document = await database.getDocument(
//       collectionId: collectionId, documentId: await _getUuid(), databaseId: databaseId);
//   List<dynamic> dataList = document.data[documentPropertyName];
//   List<String> documentData = dataList.cast<String>();
//   dataList.add(data);
//
//   database.updateDocument(
//       collectionId: collectionId,
//       documentId: await _getUuid(),
//       databaseId: databaseId,
//       data: {documentPropertyName: documentData});
// }

// static Future<void> init() async {
//   _initClient();
//
//   models.SessionList? sessions;
//   try {
//     sessions = await account.listSessions();
//   } catch (e) {
//     dev.log(e.toString());
//     dev.log('session not found');
//   }
//   if (sessions == null) {
//     await account.createAnonymousSession();
//   }
//   _addDocumentIfItDoesNotExist();
//
//   FlutterError.onError = (FlutterErrorDetails details) {
//     sendErrorToAppwrite(details.exceptionAsString(), isFlutterError: true);
//   };
// }
//
// static void _addDocumentIfItDoesNotExist() async {
//   models.Document? document;
//   try {
//     document = await database.getDocument(
//         collectionId: collectionId, databaseId: databaseId, documentId: await _getUuid());
//   } catch (e) {
//     dev.log(e.toString());
//     dev.log("could not find file");
//   }
//
//   if (document != null) {
//     return;
//   }
//   bool shouldDarkPatternsBeVisible = await DarkPatternsService.shouldDarkPatternsBeVisible();
//   final planetsByDiameter = {
//     uuid: await _getUuid(),
//     darkPatterns: shouldDarkPatternsBeVisible,
//     bootAppStartTime: [],
//     closeAppTime: [],
//     addScreenClick: [],
//     startOfLevel: [],
//     notificationTap: [],
//     ratingApp: [],
//     checkHighScoreTime: [],
//     collectDailyRewardsTime: [],
//     paidForRemovingAdds: []
//   };
//
//   await database.createDocument(
//       collectionId: collectionId,
//       documentId: await _getUuid(),
//       databaseId: databaseId,
//       data: planetsByDiameter);
//   // addInitApp(DateTime.now());
// }
//
// static void _initClient() {
//   client.setEndpoint(endpointUrl).setProject(projectId).setSelfSigned(status: true);
// }

// static Future<String> _getUuid() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? response = prefs.getString(uuid);
//   if (response != null) {
//     return response;
//   }
//   final newUuid = _getRandomString(15);
//   prefs.setString(uuid, newUuid);
//   return newUuid;
// }
//
// static void sendErrorToAppwrite(String error, {stacktrace = "", isFlutterError = false}) async {
//   try {
//     final String userAgent = html.window.navigator.userAgent;
//     database.createDocument(
//       collectionId: errorCollectionId,
//       documentId: _getRandomString(15),
//       databaseId: databaseId,
//       data: {
//         'error': error,
//         'stacktrace': stacktrace,
//         'userAgent': userAgent,
//         'isFlutterError': isFlutterError,
//         'timestamp': DateTime.now().toIso8601String(),
//       },
//     );
//   } catch (e) {
//     print('Failed to send error to Appwrite: $e');
//   }
// }
//
// static Future<void> sendFeedback(String info, html.File? file) async {
//   try {
//     final String userAgent = html.window.navigator.userAgent;
//     String uploadedFileId = _getRandomString(15);
//     database.createDocument(
//       collectionId: feedbackCollectionId,
//       documentId: _getRandomString(15),
//       databaseId: databaseId,
//       data: {
//         'info': info,
//         'userAgent': userAgent,
//         'fileId': uploadedFileId,
//         'timestamp': DateTime.now().toIso8601String(),
//       },
//     );
//     if (file != null) {
//       storage.createFile(
//           bucketId: feedbackBucketId,
//           fileId: uploadedFileId,
//           file: InputFile.fromBytes(
//               bytes: await convertHtmlFileToBytes(file),
//               filename: "FileId:${uploadedFileId}FileName:${file.name}"));
//       Fluttertoast.showToast(msg: 'Feedback sent successfully!');
//     }
//   } catch (e) {
//     Fluttertoast.showToast(msg: 'Error sending feedback: $e');
//   }
// }
//
// static Future<Uint8List> convertHtmlFileToBytes(html.File file) async {
//   final Completer<Uint8List> completer = Completer<Uint8List>();
//
//   final reader = html.FileReader();
//
//   reader.onLoadEnd.listen((e) {
//     completer.complete(reader.result as Uint8List);
//   });
//
//   reader.onError.listen((error) {
//     completer.completeError(error);
//   });
//
//   reader.readAsArrayBuffer(file);
//
//   return completer.future;
// }
//
// static String _getRandomString(int length) => String.fromCharCodes(
//     Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
//
// void sendSurvey(Map<String, dynamic> jsonResult) async {
//   JsonEncoder encoder = const JsonEncoder.withIndent('  ');
//   String prettyprint = encoder.convert(jsonResult);
//   storage.createFile(
//       bucketId: feedbackBucketId,
//       fileId: _getRandomString(15),
//       file: InputFile.fromBytes(bytes: utf8.encode(prettyprint), filename: 'report.json'));
// }
// }
