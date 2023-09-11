# Bachelor Flutter Crush

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

On mobile go to: 192.168.0.80:8080

On PC go to chrome://inspect/#devices