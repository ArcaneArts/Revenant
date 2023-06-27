import 'dart:async';

import 'package:application/model/user.dart';
import 'package:application/model/user_settings.dart';
import 'package:application/service/firestore_service.dart';
import 'package:application/util/sugar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_log/fast_log.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quantum/quantum.dart' as q;
import 'package:serviced/serviced.dart';
import 'package:throttled/throttled.dart';

typedef UserSettingsPatcher = Function(UserSettings settings);

class UserService extends StatelessService {
  late User lastUser;
  late UserSettings lastSettings;
  List<StreamSubscription> subscriptions = <StreamSubscription>[];
  bool bound = false;
  late q.QuantumController<UserSettings> _settingsController;

  Future<void> bind(String uid) async {
    if (uid == null) {
      error(
          "UID is null FATAL: MYGUIDE CANNOT RUN WITHOUT A UID FOR THE USER SERVICE");
    }

    verbose("Binding user service for $uid");
    try {
      bool startup = true;
      verbose("Binding Analytics");
      await FirebaseAnalytics.instance
          .setUserId(id: uid, callOptions: AnalyticsCallOptions(global: true));
      verbose("Bound Analytics");

      await Future.wait([
        getUserData(uid).then((value) {
          lastUser = value;
          lastUser.uid = uid;
        }),
      ]);

      subscriptions.add(streamUserDataSelf().listen((event) {
        lastUser = event;
        lastUser.uid = uid;
      }));
      _settingsController = q.QuantumController<UserSettings>(
        serializer: (settings) => settings?.toJson() ?? {},
        deserializer: (json) => UserSettings.fromJson(json ?? {}),
        document: getSettingsDocument(uid),
        compressionMode: q.QuantumCompressionMode.thresholdAndForceEncoded,
        feedbackDuration: const Duration(milliseconds: 50),
        phasingDuration: const Duration(seconds: 1),
      )..open();
      verbose("Settings Controller Activated for User Settings");
      subscriptions.add(_settingsController.stream().listen((event) {
        lastSettings = event;
        lastSettings.uid = uid;
        if (!startup) {
          updateApp();
        }
      }));
      verbose("Listener Activated for User Settings");
      bound = true;
      success("User is bound to service!");
      updateApp();
      Future.delayed(const Duration(seconds: 3), () {
        startup = false;
      });
    } catch (e, es) {
      bound = true;
      error("Failed to bind User service!");
      error(e);
      error(es);
    }
  }

  DocumentReference<Map<String, dynamic>> getSettingsDocument(String uid) =>
      FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .collection("settings")
          .doc("settings");

  void updateApp() => throttle("updateapp", () {
        warn("=== APP UPDATE ===");
        Get.forceAppUpdate();
      }, leaky: true, cooldown: const Duration(milliseconds: 250));

  void unbind() {
    bound = false;
    for (final element in subscriptions) {
      element.cancel();
    }
    subscriptions.clear();
    _settingsController.close();
  }

  Stream<User> streamUserData(String uid) => FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .snapshotsMonitored()
      .map((event) =>
          User.fromJson(event.data() ?? <String, dynamic>{})..uid = uid);

  Future<void> setUserData(String uid, User user) => FirebaseFirestore.instance
      .collection("user")
      .doc(uid)
      .setMonitored(user.toJson());

  Future<User> getUserData(String uid,
          {String? firstName,
          String? lastName,
          ValueChanged<User>? onSignedUp}) =>
      FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .getMonitored()
          .then((value) async {
        verbose("User Data: ${value.data()}");
        User us = User.fromJson(value.data() ?? <String, dynamic>{});
        if (!value.exists) {
          us.firstName = firstName ?? us.firstName;
          us.lastName = lastName ?? us.lastName;

          if (!(us.registered ?? false)) {
            verbose("User is not registered. Registering...");
            us.registered = true;
            verbose("Calling onSignedUp");
            onSignedUp?.call(us);
            verbose(
                "Setting registration email as ${auth.FirebaseAuth.instance.currentUser?.email}");
            us.email ??= auth.FirebaseAuth.instance.currentUser?.email;
          }

          warn("User data does not exist. Creating it...");
          await FirebaseFirestore.instance
              .collection("user")
              .doc(uid)
              .setMonitored(us.toJson());
          verbose("User data created.");
        }

        us.uid = uid;
        return us;
      });

  Future<Map<String, dynamic>> getClaims([bool? force]) => getCurrentUser()
      .getIdTokenResult(force ?? false)
      .then((value) => value.claims ?? <String, dynamic>{});

  Stream<User> streamUserDataSelf() => streamUserData(userId());

  String userId() => getCurrentUser().uid;

  auth.User getCurrentUser() => auth.FirebaseAuth.instance.currentUser!;

  bool hasSettings() =>
      bound &&
      (_settingsController.getLatestSync()?.settings ??
              lastSettings.settings) !=
          null;

  Map<String, dynamic> userSettings() => bound
      ? (_settingsController.getLatestSync()?.settings ??
          lastSettings.settings ??
          {})
      : {};

  String getStringSetting(String key, [String? def]) =>
      (userSettings()[key] ?? userSettings().flattened()[key] ?? def) as String;

  List<String> getStringListSetting(String key, [List<String>? def]) =>
      ((userSettings()[key] ?? userSettings().flattened()[key] ?? def) as List)
          .map((e) => e.toString())
          .toList();

  int getIntSetting(String key, [int? def]) =>
      userSettings()[key] ?? userSettings().flattened()[key] ?? def as int;

  double getDoubleSetting(String key, [double? def]) =>
      userSettings()[key] ?? userSettings().flattened()[key] ?? def as double;

  bool getBoolSetting(String key, [bool? def]) =>
      userSettings()[key] ?? userSettings().flattened()[key] ?? def as bool;

  Iterable<String> getSettingsKeysFor(bool Function(String test) b) =>
      userSettings().keys.where(b);

  Future<void> patchUserSettings(
          String uid, UserSettings lastState, UserSettingsPatcher patch) =>
      _settingsController.pushWith((value) {
        value.settings ??= {};
        patch(value);
        Map<String, dynamic> v = value.settings!.flattened().expanded();
        value.settings = v;
        lastSettings = value;
        lastSettings.uid ??= uid;
      });

  Future<void> updateName({String? first, String? last}) {
    if (first != null) {
      lastUser.firstName = first;
    }

    if (last != null) {
      lastUser.lastName = last;
    }

    return setUserData(userId(), lastUser);
  }
}
