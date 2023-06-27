/*
 * Copyright (c) 2022-2023. MyGuide
 *
 * MyGuide is a closed source project developed by Arcane Arts.
 * Do not copy, share, distribute or otherwise allow this source file
 * to leave hardware approved by Arcane Arts unless otherwise
 * approved by Arcane Arts.
 */

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:native_ios_dialog/native_ios_dialog.dart';
import 'package:universal_io/io.dart';

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
