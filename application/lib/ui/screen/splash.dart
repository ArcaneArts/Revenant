import 'package:application/service/auth_service.dart';
import 'package:application/service/user_service.dart';
import 'package:application/util/sugar.dart';
import 'package:delayed_progress_indicator/delayed_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serviced/serviced.dart';

String? splashRouteTo;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 25), () {
      if (services().get<AuthService>().isSignedIn()) {
        services()
            .get<UserService>()
            .bind(services().get<UserService>().uid())
            .then((value) {
          Navigator.pushNamedAndRemoveUntil(ctx(), "/", (route) => false);

          if ((splashRouteTo ?? "/") != "/") {
            Get.toNamed(splashRouteTo ?? "/");
          }
        });
      } else {
        Navigator.pushNamedAndRemoveUntil(ctx(), "/login", (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: SizedBox(
      width: 100,
      height: 100,
      child: DelayedProgressIndicator(),
    )));
  }
}
