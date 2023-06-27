import 'dart:async';

import 'package:application/application.dart';
import 'package:application/firebase_options.dart';
import 'package:application/util/sugar.dart';
import 'package:fast_log/fast_log.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:serviced/serviced.dart';

abstract class RevenantApp {
  /// Called when its time to build the app widget
  Widget build();

  /// Called when it's time to register services and prep them for startup
  void onRegisterServices();

  /// Called after all services have been registered and the app is about to build the first screen
  Future<void> onStartup();

  Future<Widget> _run() async {
    onRegisterServices();
    await services().waitForStartup();
    await onStartup();
    return build();
  }
}

class RevenantRoot extends StatefulWidget {
  final Widget app;

  const RevenantRoot({super.key, required this.app});

  @override
  State<RevenantRoot> createState() => _RevenantRootState();
}

class _RevenantRootState extends State<RevenantRoot> {
  @override
  void initState() {
    tempContext = context;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.app;
}

Future<void> _initializeStorage() async {}

Future<void> _initializeFirebase() async => await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform)
        .then((value) async {
      actioned("Initialized Firebase App: ${Firebase.app().options.appId}");
      actioned("API Key: ${Firebase.app().options.apiKey}");
      actioned("App Id: ${Firebase.app().options.appId}");
      actioned("App Group Id: ${Firebase.app().options.appGroupId}");
      actioned("Project Id: ${Firebase.app().options.projectId}");

      await FirebaseRemoteConfig.instance
          .setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 12),
      ));
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kReleaseMode);

      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        await FirebaseAuth.instance.authStateChanges().first;
      }

      if (!kIsWeb) {
        try {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(true);
        } catch (e) {
          error("Failed to enable crashlytics $e");
        }

        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      }
      estate(
          "mode",
          kDebugMode
              ? "debug"
              : kReleaseMode
                  ? "production"
                  : kProfileMode
                      ? "profile"
                      : "unknown");
    });

Future<void> _coreInit() async {
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  await _initializeStorage();
  try {
    await _initializeFirebase();
    verbose("Firebase Initialized");
  } catch (e) {
    error("Firebase already registered with probably the wrong options");
    warn(
        "It looks like we already registered app id: ${Firebase.app().options.appId}");
    warn("API Key: ${Firebase.app().options.apiKey}");
    warn("App Id: ${Firebase.app().options.appId}");
    warn("App Group Id: ${Firebase.app().options.appGroupId}");
    warn("Project Id: ${Firebase.app().options.projectId}");
    rethrow;
  }
}

void main() => runZonedGuarded(
        () => _coreInit().then((_) => Application()
            ._run()
            .then((value) => runApp(RevenantRoot(app: value)))), (e, es) {
      error("Zone Error: $e");
      error(es);
    });
