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

## How to upload to Internal Testing

Go to 'C:\Schule\bachelor_flutter_crush\Projekt2_Flutter_Crush\android\app\build.gradle' and change
flutterVersionCode to next higher version
Update version in C:\Schule\bachelor_flutter_crush\Projekt2_Flutter_Crush\pubspec.yaml to next version
pub get in pubspec.yaml
Run 'flutter build appbundle'
Go to https://play.google.com/console/u/0/developers and upload app-release.aab from
'C:
\Schule\bachelor_flutter_crush\Projekt2_Flutter_Crush\build\app\outputs\bundle\release\app-release.aab'

https://docs.flutter.dev/deployment/android
https://developer.android.com/studio/publish/upload-bundle