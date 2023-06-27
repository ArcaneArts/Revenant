/*
 * Copyright (c) 2022-2023. MyGuide
 *
 * MyGuide is a closed source project developed by Arcane Arts.
 * Do not copy, share, distribute or otherwise allow this source file
 * to leave hardware approved by Arcane Arts unless otherwise
 * approved by Arcane Arts.
 */

import 'dart:async';
import 'dart:math';

import 'package:application/service/firestore_service.dart';
import 'package:application/service/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_log/fast_log.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:native_ios_dialog/native_ios_dialog.dart';
import 'package:serviced/serviced.dart';
import 'package:synchronized/synchronized.dart';
import 'package:universal_io/io.dart';

Box hiveNow(String box) => Hive.box("mg$box");

Lock _hiveLock = Lock();

Future<Box> hive(String box) async {
  if (Hive.isBoxOpen("mg$box")) {
    return Hive.box("mg$box");
  }

  return Hive.openBox("mg$box").then((value) {
    success(
        "Initialized Hive Box ${value.name} with ${value.keys.length} keys");
    return value;
  });
}

Future<LazyBox> hiveLazy(String box) => _hiveLock.synchronized(() async {
      if (Hive.isBoxOpen("mg$box")) {
        return Hive.lazyBox("mg$box");
      }

      return Hive.openLazyBox("mg$box").then((value) {
        success(
            "Initialized Lazy Hive Box ${value.name} with ${value.keys.length} keys");
        return value;
      });
    });

bool isAndroid() => !kIsWeb && Platform.isAndroid;

bool isIOS() => !kIsWeb && Platform.isIOS;

bool isMacos() => !kIsWeb && Platform.isMacOS;

bool isWeb() => kIsWeb;

BuildContext? tempContext;

BuildContext ctx() => (Get.context ?? tempContext)!;

Future<T?> dialogText<T>({
  required BuildContext context,
  required String title,
  required String submitButtonText,
  required T? Function(BuildContext context, String text) onSubmit,
  String? description,
  String? hint,
  String? initialValue,
  int? maxLines,
  int? minLines,
  int? maxLength,
}) async {
  TextEditingController td = TextEditingController(text: initialValue ?? "");
  return showDialog(
    context: context,
    builder: (dcontext) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: description != null,
              child: Text(description ?? ""),
            ),
            TextField(
              autofocus: true,
              onSubmitted: (f) => Navigator.pop(dcontext, onSubmit(context, f)),
              keyboardType: TextInputType.text,
              controller: td,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              decoration: InputDecoration(hintText: hint),
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
            ),
            onPressed: () => Navigator.pop(dcontext),
          ),
          TextButton(
              child: Text(
                (submitButtonText),
              ),
              onPressed: () {
                String s = td.value.text;
                T? v = onSubmit(context, s);
                Navigator.pop(ctx(), v);
              }),
        ],
      );
    },
  );
}

Future<T?> dialogTextMultiline<T>({
  required BuildContext context,
  required String title,
  required String submitButtonText,
  required T? Function(BuildContext context, String text) onSubmit,
  String? description,
  String? hint,
  String? initialValue,
  int? maxLines,
  int? minLines,
  int? maxLength,
}) async {
  TextEditingController td = TextEditingController(text: initialValue ?? "");
  return showDialog(
    context: context,
    builder: (dcontext) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: description != null,
              child: Text(description ?? ""),
            ),
            TextField(
              autofocus: true,
              onSubmitted: (f) => Navigator.pop(dcontext, onSubmit(context, f)),
              keyboardType: TextInputType.multiline,
              controller: td,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              decoration: InputDecoration(hintText: hint),
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
            ),
            onPressed: () => Navigator.pop(dcontext),
          ),
          TextButton(
              child: Text(
                (submitButtonText),
              ),
              onPressed: () {
                String s = td.value.text;
                T? v = onSubmit(context, s);
                Navigator.pop(ctx(), v);
              }),
        ],
      );
    },
  );
}

Future<Future<T?>> dialogTextAsyncResult<T>({
  required BuildContext context,
  required String title,
  required String submitButtonText,
  required Future<T?> Function(BuildContext context, String text) onSubmit,
  String? description,
  String? hint,
  String? initialValue,
  int? maxLines,
  int? minLines,
  int? maxLength,
}) async =>
    showDialog(
      context: context,
      builder: (dcontext) {
        TextEditingController td =
            TextEditingController(text: initialValue ?? "");

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: description != null,
                child: Text(description ?? ""),
              ),
              TextField(
                autofocus: true,
                onSubmitted: (f) =>
                    Navigator.pop(context, onSubmit(context, f)),
                keyboardType: TextInputType.text,
                controller: td,
                maxLines: maxLines,
                minLines: minLines,
                maxLength: maxLength,
                decoration: InputDecoration(hintText: hint),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
              ),
              onPressed: () => Navigator.pop(dcontext),
            ),
            TextButton(
                child: Text(
                  (submitButtonText),
                ),
                onPressed: () {
                  String s = td.value.text;
                  Navigator.pop(ctx(), onSubmit(context, s));
                }),
          ],
        );
      },
    );

Future<T?> dialogNumber<T>({
  required BuildContext context,
  required String title,
  required String submitButtonText,
  required T? Function(BuildContext context, int? value) onSubmit,
  String? description,
  String? hint,
  String? initialValue,
}) async =>
    showDialog(
      context: context,
      builder: (dcontext) {
        TextEditingController td =
            TextEditingController(text: initialValue ?? "");

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: description != null,
                child: Text(description ?? ""),
              ),
              TextField(
                autofocus: true,
                onSubmitted: (f) =>
                    Navigator.pop(context, onSubmit(context, int.tryParse(f))),
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                controller: td,
                maxLines: 1,
                decoration: InputDecoration(hintText: hint),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
              ),
              onPressed: () => Navigator.pop(dcontext),
            ),
            TextButton(
                child: Text(
                  (submitButtonText),
                ),
                onPressed: () {
                  String s = td.value.text;
                  T? v = onSubmit(context, int.tryParse(s));

                  Navigator.pop(ctx(), v);
                }),
          ],
        );
      },
    );

Future<T?> dialogText2<T>(
        {required BuildContext context,
        required String title,
        required String submitButtonText,
        required T? Function(BuildContext context, String text, String text2)
            onSubmit,
        String? description,
        String? hint,
        String? hint2,
        String? initialValue,
        String? initialValue2,
        int? maxLines,
        int? minLines,
        int? maxLength,
        bool obscureSecond = false}) async =>
    showDialog(
      context: context,
      builder: (dcontext) {
        TextEditingController td =
            TextEditingController(text: initialValue ?? "");
        TextEditingController td2 =
            TextEditingController(text: initialValue2 ?? "");

        return AlertDialog(
          title: Text((title)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: description != null,
                child: Text((description ?? "")),
              ),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.text,
                controller: td,
                maxLines: maxLines,
                minLines: minLines,
                maxLength: maxLength,
                decoration: InputDecoration(hintText: hint),
              ),
              !obscureSecond
                  ? TextField(
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      controller: td2,
                      maxLines: maxLines,
                      minLines: minLines,
                      maxLength: maxLength,
                      decoration: InputDecoration(hintText: hint2),
                    )
                  : TextField(
                      controller: td2,
                      obscureText: obscureSecond,
                      decoration: InputDecoration(hintText: hint2),
                    )
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
                child: Text(
                  (submitButtonText),
                ),
                onPressed: () => Navigator.pop(
                    context, onSubmit(context, td.value.text, td2.value.text))),
          ],
        );
      },
    );

Future<T?> dialogEmail<T>({
  required BuildContext context,
  required String title,
  required String submitButtonText,
  required T? Function(BuildContext context, String text) onSubmit,
  String? description,
  String? hint,
  String? initialValue,
  int? maxLines,
  int? minLines,
  int? maxLength,
}) async =>
    showDialog(
      context: context,
      builder: (dcontext) {
        TextEditingController td =
            TextEditingController(text: initialValue ?? "");

        return AlertDialog(
          title: Text((title)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: description != null,
                child: Text((description ?? "")),
              ),
              TextField(
                autofocus: true,
                onSubmitted: (f) =>
                    Navigator.pop(context, onSubmit(context, f)),
                keyboardType: TextInputType.text,
                controller: td,
                maxLines: maxLines,
                minLines: minLines,
                maxLength: maxLength,
                decoration: InputDecoration(hintText: hint),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
                child: Text(
                  (submitButtonText),
                ),
                onPressed: () =>
                    Navigator.pop(context, onSubmit(context, td.value.text))),
          ],
        );
      },
    );

Future<void> dialogConfirmIOSNative<T>(
        {required BuildContext context,
        required String title,
        required String description,
        bool destructive = false,
        bool cancelButton = true,
        required String confirmButtonText,
        String? cancelButtonText,
        required T? Function(BuildContext context) onConfirm,
        T? Function(BuildContext context)? onCancel}) =>
    NativeIosDialog(
        title: title,
        message: description,
        style: NativeIosDialogStyle.actionSheet,
        actions: [
          NativeIosDialogAction(
              text: confirmButtonText,
              style: destructive
                  ? NativeIosDialogActionStyle.destructive
                  : NativeIosDialogActionStyle.defaultStyle,
              onPressed: () => onConfirm(context)),
          NativeIosDialogAction(
              text: cancelButtonText ?? "Cancel",
              style: NativeIosDialogActionStyle.cancel,
              onPressed: () => onCancel?.call(context))
        ]).show();

Future<T?> dialogConfirm<T>(
        {required BuildContext context,
        required String title,
        required String description,
        bool destructive = false,
        Widget? descriptionWidget,
        bool cancelButton = true,
        required String confirmButtonText,
        String? cancelButtonText,
        required T? Function(BuildContext context) onConfirm,
        T? Function(BuildContext context)? onCancel}) async =>
    (isIOS() && descriptionWidget == null)
        ? dialogConfirmIOSNative(
                context: context,
                title: title,
                cancelButton: cancelButton,
                destructive: destructive,
                description: description,
                confirmButtonText: confirmButtonText,
                onConfirm: onConfirm)
            .then((value) => null)
        : showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text((title)),
                  content: descriptionWidget ?? Text((description)),
                  actions: [
                    cancelButton
                        ? TextButton(
                            child: Text(
                              cancelButtonText ?? "Cancel",
                            ),
                            onPressed: () =>
                                Navigator.pop(context, onCancel?.call(context)),
                          )
                        : Container(),
                    TextButton(
                        child: Text(
                          (confirmButtonText),
                        ),
                        onPressed: () =>
                            Navigator.pop(context, onConfirm(context))),
                  ],
                ));

Map<String, String> customCrashKeys = {};

Box? box;

Future<void> estate(String k, dynamic v) {
  customCrashKeys[k] = v.toString();

  if (!kIsWeb) {
    return FirebaseCrashlytics.instance.setCustomKey(k, v);
  }

  return Future.value();
}

bool splashActive = true;
void dropSplash() {
  if (splashActive) {
    FlutterNativeSplash.remove();
    splashActive = false;
  }
}

bool flatEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  Map<String, dynamic> fa = flatMap(a);
  Map<String, dynamic> fb = flatMap(b);

  if (fa.length != fb.length) {
    return false;
  }

  for (final String key in fa.keys) {
    if (!fb.containsKey(key) || !eq(fb[key], fa[key])) {
      return false;
    }
  }

  return true;
}

List<String> flatDiff(Map<String, dynamic> a, Map<String, dynamic> b) {
  Map<String, dynamic> fa = flatMap(a);
  Map<String, dynamic> fb = flatMap(b);
  List<String> changes = <String>[];

  if (fa.length != fb.length) {
    changes.add("* length ${fa.length} -> ${fb.length}");
    return changes;
  }

  for (final String key in fa.keys) {
    if (!fb.containsKey(key)) {
      changes.add("* Key change " + key);
    } else if (!eq(fb[key], fa[key])) {
      changes.add("* $key [${fa[key]} -> ${fb[key]}]");
    }
  }

  return changes;
}

bool eq(dynamic a, dynamic b) {
  if ((a != null) != (b != null)) {
    return false;
  }

  if (a.runtimeType != b.runtimeType) {
    return false;
  }

  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (!eq(a[i], b[i])) {
        return false;
      }
    }
  } else if (a is Map && b is Map) {
    if (a.length != b.length) {
      return false;
    }

    for (final dynamic key in a.keys) {
      if (!b.containsKey(key) || !eq(b[key], a[key])) {
        return false;
      }
    }
  } else if (a != b) {
    return false;
  }

  return true;
}

Map<String, dynamic> flatMap(Map<String, dynamic> m) => m.flattened();

Future<void> patchDocument(DocumentReference<Map<String, dynamic>> document,
    Map<String, dynamic> original, Map<String, dynamic> altered) async {
  Map<String, dynamic> before = flatMap(original);
  Map<String, dynamic> after = flatMap(altered);
  Map<String, dynamic> diff = <String, dynamic>{};
  Set<String> removalCheck = <String>{};
  double keyCount = max(before.length, after.length).toDouble();
  before.forEach((key, value) {
    if (after.containsKey(key)) {
      if (!eq(value, after[key])) {
        diff[key] = after[key];
        verbose("[Patch]: Modified Field $key $value => ${after[key]}");
      }
    } else {
      diff[key] = FieldValue.delete();
      verbose("[Patch]: Removed Field $key");
      List<String> k = key.split(".");
      k.removeLast();
      removalCheck.add(k.join("."));
    }
  });

  for (final key in removalCheck) {
    if (after.keys.where((element) => element.startsWith("$key.")).isEmpty) {
      verbose("[Patch]: Removed Field Group $key");
      diff.removeWhere((kkey, value) {
        if (value == FieldValue.delete() && kkey.startsWith("$key.")) {
          verbose("[Patch]: -- Caused by Removing Field $kkey");
          return true;
        }

        return false;
      });
      diff[key] = FieldValue.delete();
    }
  }

  after.forEach((key, value) {
    if (!before.containsKey(key)) {
      diff[key] = value;
      verbose("[Patch]: Added Field $key $value");
    }
  });

  if (diff.isNotEmpty) {
    diff.removeWhere((key, value) => key.trim().isEmpty);

    double len = diff.length.toDouble();
    double percent = ((len / keyCount) * 100);
    actioned(
        "[Patch]: Pushed Document with ${(100.0 - percent).toStringAsFixed(0)}% efficiency (${diff.length} / ${keyCount.toInt()})");

    return document.updateMonitored(diff);
  }
}

class JsonPatch {
  JsonPatchType type = JsonPatchType.deleted;
  dynamic value;
  dynamic to;

  @override
  String toString() =>
      "<${type.name}> ${type != JsonPatchType.deleted ? type == JsonPatchType.added ? value : "$value => $to" : ""}";

  void reverse() {
    switch (type) {
      case JsonPatchType.deleted:
        type = JsonPatchType.added;
        break;
      case JsonPatchType.changed:
        dynamic t = value;
        value = to;
        to = t;
        break;
      case JsonPatchType.added:
        type = JsonPatchType.deleted;
        break;
    }
  }

  static JsonPatch deleted(dynamic value) =>
      JsonPatch()..type = JsonPatchType.deleted;

  static JsonPatch changedTo(dynamic value, dynamic to) => JsonPatch()
    ..value = value
    ..to = to
    ..type = JsonPatchType.changed;

  static JsonPatch added(dynamic value) => JsonPatch()
    ..value = value
    ..type = JsonPatchType.added;
}

enum JsonPatchType { deleted, changed, added }

extension XMap on Map<String, dynamic> {
  Map<String, dynamic> copy() {
    Map<String, dynamic> f = <String, dynamic>{};
    forEach((key, value) => f[key] = value);
    return f;
  }

  Map<String, dynamic> inversePatched(Map<String, JsonPatch> patch,
      {bool forceMerge = false}) {
    Map<String, dynamic> self = flattened();
    patch.forEach((key, value) {
      switch (value.type) {
        case JsonPatchType.added:
          if (forceMerge || self.containsKey(key)) {
            self.remove(key);
          }
          break;
        case JsonPatchType.changed:
          if (forceMerge || value.to == self[key]) {
            self[key] = value.value;
          }
          break;
        case JsonPatchType.deleted:
          if (forceMerge || !self.containsKey(key)) {
            self[key] = value.value;
          }
          break;
      }
    });

    return self.expanded();
  }

  Map<String, dynamic> patched(Map<String, JsonPatch> patch,
      {bool forceMerge = false}) {
    Map<String, dynamic> self = flattened();
    patch.forEach((key, value) {
      switch (value.type) {
        case JsonPatchType.deleted:
          if (forceMerge || self.containsKey(key)) {
            self.remove(key);
          }
          break;
        case JsonPatchType.changed:
          if (forceMerge || value.value == self[key]) {
            self[key] = value.to;
          }
          break;
        case JsonPatchType.added:
          if (forceMerge || !self.containsKey(key)) {
            self[key] = value.value;
          }
          break;
      }
    });

    return self.expanded();
  }

  Map<String, JsonPatch> diff(Map<String, dynamic> altered) {
    Map<String, JsonPatch> patch = <String, JsonPatch>{};
    Map<String, dynamic> self = flattened();
    Map<String, dynamic> alt = altered.flattened();
    alt.forEach((key, value) {
      if (!self.containsKey(key)) {
        patch[key] = JsonPatch.added(value);
      } else if (!eq(self[key], value)) {
        patch[key] = JsonPatch.changedTo(self[key], value);
      }
    });
    self.forEach((key, value) {
      if (!alt.containsKey(key)) {
        patch[key] = JsonPatch.deleted(value);
      }
    });

    return patch;
  }

  Map<String, dynamic> expanded() {
    Map<String, dynamic> expanded = <String, dynamic>{};
    forEach((key, value) => expanded.putFlatKey(key, value));
    return expanded;
  }

  Map<String, dynamic> flattened({String prefix = ""}) {
    Map<String, dynamic> flat = <String, dynamic>{};

    forEach((key, value) {
      if (value is Map<String, dynamic>) {
        value
            .flattened(prefix: "$prefix$key.")
            .forEach((key, value) => flat[key] = value);
      } else {
        flat["$prefix$key"] = value;
      }
    });

    return flat;
  }

  void putFlatKey(String key, dynamic value) {
    if (key.contains(".")) {
      Map<String, dynamic> cursor = this;
      List<String> segments = key.split(".");

      for (int i = 0; i < segments.length - 1; i++) {
        cursor.putIfAbsent(segments[i], () => <String, dynamic>{});
        cursor = cursor[segments[i]];
      }

      cursor[segments.last] = value;
    } else {
      this[key] = value;
    }
  }

  Map<String, dynamic> insertHierarchical(Map<String, dynamic> onto) {
    Map<String, dynamic> mix = <String, dynamic>{};
    flattened().forEach((key, value) => mix[key] = value);
    onto.flattened().forEach((key, value) => mix[key] = value);
    return mix.expanded();
  }
}

Box getBox() => box!;

String truncate(String s, int length) =>
    s.length > length ? "${s.substring(0, length)}..." : s;

String uid() => svc<UserService>().userId();

Future<void> ucput(String key, dynamic value) => svc<UserService>()
        .patchUserSettings(uid(), svc<UserService>().lastSettings, (settings) {
      settings.settings ??= {};
      if (value == null) {
        settings.settings!.remove(key);
        verbose("UCREMOVE $key");
      } else {
        settings.settings![key] = value;
        verbose("UCPUT $key=$value");
      }
    });

String ucstring(String key, String def) =>
    svc<UserService>().getStringSetting(key, def);

List<String> ucstringList(String key, List<String> def) =>
    svc<UserService>().getStringListSetting(key, def);

int ucsint(String key, int def) => svc<UserService>().getIntSetting(key, def);

double ucdouble(String key, double def) =>
    svc<UserService>().getDoubleSetting(key, def);

bool ucbool(String key, bool def) =>
    svc<UserService>().getBoolSetting(key, def);

Future<void> localput(String key, dynamic value) => value == null
    ? getBox().delete("localconfig.$key")
    : getBox().put("localconfig.$key", value);

Future<void> localputRefresh(String key, dynamic value) async {
  await localput(key, value);
  svc<UserService>().updateApp();
}

String localstring(String key, String def, {bool put = false}) {
  if (put) {
    String? v = getBox().get("localconfig.$key");

    if (v == null) {
      localput(key, def);
      return getBox().get("localconfig.$key", defaultValue: def) ?? def;
    }
  }

  return getBox().get("localconfig.$key", defaultValue: def) ?? def;
}

int localint(String key, int def) =>
    getBox().get("localconfig.$key", defaultValue: def) ?? def;

double localdouble(String key, double def) =>
    getBox().get("localconfig.$key", defaultValue: def) ?? def;

bool localbool(String key, bool def) =>
    getBox().get("localconfig.$key", defaultValue: def) ?? def;
