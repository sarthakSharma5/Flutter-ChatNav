# ChatNav

Android Application developed using Flutter

Mobile App to with the following features:
* Allow clients have one-to-one chat using messages
* Use Google Maps for Navigation

Flutter integration with Firebase for
* Email Authentication
* Data storage in [Cloud Firestore](https://firebase.google.com/docs/firestore)

Use of Google's [Map SDK](https://developers.google.com/maps/documentation/android-sdk/overview) to allow use of Google Maps in App

Added <B>android/app/google-services.json</B> to [.gitignore](.gitignore) required for [Firebase integration](https://firebase.google.com/docs/android/setup)

Packages Used: mentioned in [pubspec.yaml](pubspec.yaml)

### Important!
Removed Google API key from [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) at <B>line 13</B> for security reasons
* Required for Google Maps: [reference](https://codelabs.developers.google.com/codelabs/google-maps-in-flutter#0)

<HR>

## Start building your own Apps

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
