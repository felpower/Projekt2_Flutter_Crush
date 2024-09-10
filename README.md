# Master JellyFun

A flutter project which includes the implementation of several dark patterns.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flutter version

We used flutter version 2.8.0 for implementation.

## How to upload to Android Internal Testing

Go to 'projekt_flutter_crush\android\app\build.gradle' and change
flutterVersionCode to next higher version
Update version in projekt_flutter_crush\pubspec.yaml to next version
pub get in pubspec.yaml
Run 'flutter build appbundle'
Go to 'https://play.google.com/console/u/0/developers' and upload app-release.aab from
'projekt_flutter_crush\build\app\outputs\bundle\release\app-release.aab'

https://docs.flutter.dev/deployment/android
https://developer.android.com/studio/publish/upload-bundle

## How to upload to firebase web app

Go to project_flutter_crush folder
run 'flutter build web'
copy 'project_flutter_crush\build\web' folder 'into bachelor_flutter_crush\build\web' folder
run 'firebase deploy'

## How to test the app on mobile web

flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

ipconfig check for IP4 address

On mobile go to: 192.168.88.131:8080

On PC go to
chrome://inspect/#devices

## Test Notifications

oAuth Playground:
https://developers.google.com/oauthplayground/
Step 1: https://www.googleapis.com/auth/firebase.messaging
Step 2: https://fcm.googleapis.com/v1/projects/flutter-crush-4ece9/messages:send
Step 3: Send Post requests

```json
{
    "message":{
        "token":"czm7cFL9Fr8taHBHNYVzIb:APA91bHYq5YxDbrvxvdX-E-uPHxGcLCMEXFn6b6jHzey4Tv2C1azb0FiDNOeOH2qC6Yfjz1MNQKLpXoHNelaVC5IALS-5yXfk68OV3b23BufYIyarrAvXzRZeeqC2BzJ03fK51tZiDGs",
        "notification":{
            "title":"Test",
            "body":"Test"
        },
        "data":{
            "site": "https://flutter-crush-4ece9.web.app/",
            "click_action":"FLUTTER_NOTIFICATION_CLICK",
            "id":"1",
            "status":"done"
        }
    }
}
```

```json
{
  "message": {
    "token": "eygV6UarhggjAacnuAkilW:APA91bF6e7AR2DJ4c8CEj7cDc6cB-PIDCSbqdvDxQk9riJ3jC_IbxmUCryPG1DTy0wmoBxvktXCXmJNoG5TBmHEYzOWi45G8eoOwQV5u-z_AKxNzCixhBs5yjJ0Im2_lWQxtsPdp8v5b",
    "data": {
      "title": "Test",
      "body": "Test",
      "site": "https://flutter-crush-4ece9.web.app/",
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done"
    }
  }
}
```

## Fixes for threading issues in WebGL

https://forum.unity.com/threads/async-await-and-webgl-builds.472994/page-2#post-6218307
https://github.com/VolodymyrBS/WebGLThreadingPatcher
https://github.com/Cysharp/UniTask

###

Dart Data Class
Flutter Snippets

## Change Splash Screen

dart run flutter_native_splash:create

## ToDo's

✅ Klick auf „Kaufen“ im Shop -> Info auf Dark Patterns
✅ Dollar tauschen gegen Münz-Emoji
✅ Infobox ausklappbar machen
✅ Shop in die Menüleiste
Info auf Sonderangebot im Hauptspiel
Werbung wieder reingeben
bei Dark Pattern Infobox dazuschreiben wieviele Dark Patterns bereits gefunden wurden