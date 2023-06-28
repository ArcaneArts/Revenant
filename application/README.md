# Revenant
Do each section in order, or at least thats how it was intended to be done.

## Prerequisites
This stuff assumes you have done some kind of flutter development with firebase before. If you have not it might be wise to go over this list because this guide assumes you have all of these.

* [Firebase Account](https://firebase.google.com/)
* [CodeMagic Account](https://codemagic.io/start/)
* [Google Play Developer Account](https://play.google.com/console/about/)
  * Its like a $20 or $35 one time initiation fee (bot prevention)
* [Apple Developer Account](https://developer.apple.com/)
  * You need to actually enroll as a "Real Developer" for $99/year and must maintain membership to keep your apps on the AppStore
* [Flutter 3.10+](https://docs.flutter.dev/get-started/install)
* [NodeJs 16](https://nodejs.org/en/download/current)
* [KeyStore Explorer](https://keystore-explorer.org/)
* [Firebase CLI](https://firebase.google.com/docs/cli#mac-linux-npm)
  * Install with NPM `npm install -g firebase-tools`
  * Log in with `firebase login`
* IntelliJ Idea (toolbox)
  * Flutter Plugin
  * Flutter Pub Version Checker
  * Flutter Snippets
  * Dart Plugin
  * Dart Scripts Runner
* Android Studio (toolbox)
  * Google USB Driver
  * Latest Android SDK
  * Commandline Tools
* XCode (sorry)
  * You can simply have a mac with all this shit installed then also your "primary" windows device with everything BUT xcode, but you will have to use xcode at some point!

## Scripts
Your pubspec does more than usual. There is a scripts section at the bottom of the pubspec.yaml. They should have run buttons next to them provided you installed the IntelliJ Dart Scripts Runner Plugin (see above).

**A lot of this guide will instruct you to run the "xyz script" which means open the pubspec, find that script section and click the play button in the gutter**

**Flutter development is 50% programming, 50% running scripts that almost work 100% of the time.**

## 1. Claim
Note down the following properties as you will need them

| Property     | Example       | Description                  |
|--------------|---------------|------------------------------|
| app_id       | myguide       | The app id and project name |
| app_name     | MyGuide       | The human app name          |
| package_name | cloud.myguide | The android package id      |
| bundle_id    | cloud.myguide | The apple bundle identifier |


#### Android
1. Close IntelliJ... You could keep it open but it might fuck up some of the refactors your about to attempt.
2. `pubspec.yaml` change `name: application` to your `app_id`
3. `android/app/build.gradle` change `namespace "art.arcane.revenant.application"` to your `package_name`
4. `android/app/build.gradle` change `applicationId "art.arcane.revenant.application"` to your `package_name`
5. `android/app/src/main/AndroidManifest.xml` change `android:label="application"` to your `app_id`

#### IOS
1. Claim your `bundle_id` on Apple Developer
   * Dont use wildcard bundles!
   * This is for IOS only, you wont need a macos one!
   * This is for the AppStore!
2. Open XCode in `ios` directory.
3. Sign into XCode with your apple developer account.
4. Select `Runner` from the root sidebar.
   * Set the team to your developer team that is paying apple to exist (not your personal default one)
   * Set Bundle Identifier property to `bundle_id`
5. Select `Info.plist` from the sidebar
   * Change `Bundle name` to your `app_id`
   * Change `Bundle Display Name` to your `app_name`

## 2. Firebase
* [Create a new Project on Firebase](https://console.firebase.google.com/)
  * Keep Google Analytics Enabled (you can use the default firebase analytics account)
* Run the script `flutterfire_init` in pubspec and select this project. 
