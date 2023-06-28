# Revenant
Do each section in order, or at least thats how it was intended to be done.

# Don't open this project before following step 1!

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
* [Strong Password Generator](https://passwordsgenerator.net/)
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
> The point of this step is to actually claim the app as your own and not just keep it as a template. It's super important because changing your package name in the future is annoying so lets get it over with!

Note down the following properties as you will need them

| Property     | Example       | Description                         |
|--------------|---------------|-------------------------------------|
| app_id       | myguide       | The app id and project name         |
| app_name     | MyGuide       | The human app name                  |
| package_name | cloud.myguide | The android package id              |
| bundle_id    | cloud.myguide | The apple bundle identifier         |
| domain       | myguide.cloud | The domain your web app will go to  |
| region       | us_central    | The cloud region your shit runs on  |

### 1.1: Flutter
1. Rename the `application` folder to your `app_id` as the folder name. 
2. Open `REPO/<app_id>` in IntelliJ
3. `pubspec.yaml` change `name: application` to your `app_id`

### 1.2: Android
1. `android/app/build.gradle` change `namespace "art.arcane.revenant.application"` to your `package_name`
2. `android/app/build.gradle` change `applicationId "art.arcane.revenant.application"` to your `package_name`
3. `android/app/src/main/AndroidManifest.xml` change `android:label="application"` to your `app_id`

### 1.3: IOS
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
> In this section we create a firebase project in the cloud and link the api keys and ids to our project using flutterfire.

* [Create a new Project on Firebase](https://console.firebase.google.com/)
  * Keep Google Analytics Enabled (you can use the default firebase analytics account)
  * Click on Build > Hosting > Get Started (required)
  * Click on Build > Firestore > Create DB (required)
    * Start in Production Mode
    * Set the location to nam5 or the best multi-region near you.
  * Click on Build > Storage > Get Started (if you need storage)
    * Start in Production Mode
    * Set the location to nam5 or the best multi-region near you.
  * Click on Build > Remote Config > Create Configuration
    * Name the first parameter derp or something and give it a false boolean value just to init it
    * Hit Save
* Run the script `firebase_init` in the pubspec and select this project.
  1. 
* Run the script `flutterfire_init` in pubspec and select this project.
  1. Select your newly created project (up down arrow keys, then enter for selection)
  2. For platform selection, just press enter. Keep android ios and web selected. Keep macos unselected.
  3. It will ask to modify the android gradle files hit YES (enter)
  4. It will ask to modify the existing firebase_options file hit YES (enter)
* Run the sript `update` and wait for it to finish (it could take a minute or two)

## 3. Keys
> This is a crucial step and will ensure ease of development and app integrity down the line.
1. Create a folder in the root directory of the repo (NOT INSIDE THE `app_id` folder)
2. On your firebase project -> Settings (scroll down to the apps)
  * Click on Android & download the google-services.json into the keys folder
  * Click on IOS and download the GoogleService-Info.plist into the keys folder
3. Open KeyStore Explorer
  * File > New and use the JKS format
  * Right Click > Generate new Key Pair (RSA 2,048)
    * Version 3
    * Signature Algorithm: SHA-256 with RSA
    * Validity Period: 25 Years
    * Name: Click the Address Book Button and fill them out (its not required but good idea to at least get the common name CN filled out)
      * The common name should be `<app_id>-production`
  * Literally do the same thing but with the CN common name as `<app_id>-debug` instead.
  * Now with both keys
    * Right Click -> Set Password (generate a unique one with at least 32 chars on password generator)
    * Save the `<key_name>: <password>` into a file called `unlock.txt` in the keys folder. Note: You cannot open source this app because of these keys!
  * File > Save
    * Set unique password for the entire keystore (32 chars prolly)
    * Save the `keystore: <password>` into the unlock file. You should have 3 passwords in here now
    * Save the file to `keys/keystore.jks`
4. Open the `android/app/build.gradle`
5. Find the signing configs section and replace the entire section with 

```groovy
signingConfigs {
    release {
        storeFile file("../../../keystore.jks")
        storePassword '<the keystore password>'
        keyAlias '<key_id>-production'
        keyPassword '<the key password>'
    }
    debug {
        storeFile file("../../../keystore.jks")
        storePassword '<the keystore password>'
        keyAlias '<key_id>-debug'
        keyPassword '<the key password>'
    }
}
```

6. Replace the build types with

```groovy
buildTypes {
    release {
        debuggable false
        signingConfig signingConfigs.release
    }

    debug {
        debuggable true
        signingConfig signingConfigs.debug
    }
}
```

## 4. Play Store
1. Run the script `build_appbundle_release` (it tells you where it outputs to)
2. Create a new App on the Play Store and upload your appbundle (you will need to configure a lot of stuff so allocate 30 minutes to setting up the play store)
3. Keep it as Internal Test for now

## 5. Firebase App Configuration
To get firebase to work with sign in with google and sign in with apple we need to prove that our app is actually our app and was actually downloaded from the play store (or its our debug key that only we have).

1. Open Firebase > Build > Authentication (hit get started)
   * Open the Sign-In Method Tab
   * Add Provider > Click on Google & Switch on Enable
   * Add Provider > Click on Apple & Switch on Enable
2. Open Settings > Project Settings (scroll down to apps)
3. Select the Android App and Add the following fingerprints
  * Open AndroidStudio and open `android` directory
  * Run the signing report gradle script
  * For the debug configuration paste in both the MD5 and SHA-256 signatures
  * For the release configuration do the same paste both
  * In Play Store go to App Integrity and copy both signatures and also put those into firebase
  * You should have 6 signatures (3 sha-256 and 3 md5)
4. Select the IOS App
   * Set the team id to your apple developer team id

## Web Hosting
> To support our web app we need to do the following steps. This will host two sites a production site and beta site.
1. Open Firebase > Build > Hosting (get started,next,next,finish)
   * Add your domain here! Link a beta subdomain too for the beta site
   * Hit Add Another Site (name it beta-<firebase_project_id> but its not important)
   * In your pubspec change deploy_web_beta and deploy_web_production scripts to match these websites
2. Edit your `firebase.json` hosting section

```json
"hosting": [
    {
      "site": "<site_id>",
      "public": "<app_id>/build/web",
      "predeploy": [
        "cd <app_id> && flutter build web --release --web-renderer canvaskit --dart2js-optimization O4 --verbose"
      ],
      "ignore": [
        "firebase.json",
        "**/node_modules/**"
      ]
    },
    {
      "site": "beta-<site_id>",
      "public": "<app_id>/build/web",
      "predeploy": [
        "cd <app_id> && flutter build web --release --web-renderer canvaskit --dart2js-optimization O4 --verbose"
      ],
      "ignore": [
        "firebase.json",
        "**/node_modules/**"
      ]
    }
  ],

3. Run both the deploy_web_beta and deploy_web_production scripts to see if it works and deploys out to firebase!
```

## Run & Test
> We want to make sure google sign in is working and firebase is picking up the app. It may take a couple tries, this shit is buggy on new projects. If everything works, then you are pretty much done however there is more stuff to configure but its not essential to development beginnings. Do the other checklists when you want those things setup or they are alternative things you could do but arent essential.
