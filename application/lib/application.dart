import 'package:application/main.dart';
import 'package:application/service/auth_service.dart';
import 'package:application/service/user_service.dart';
import 'package:application/ui/screen/home.dart';
import 'package:application/ui/screen/login.dart';
import 'package:application/ui/screen/splash.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serviced/serviced.dart';

class Application extends RevenantApp implements GetMiddleware {
  final List<GetMiddleware> middlewares = [ApplicationMiddleware()];

  @override
  void onRegisterServices() {
    services().register(() => AuthService());
    services().register(() => UserService());
  }

  @override
  Future<void> onStartup() async {
    // Do your own custom async shit before the app opens
  }

  @override
  Widget build() => GetMaterialApp(
        title: "Application",
        getPages: [
          GetPage(
              name: "/",
              page: () => const HomeScreen(),
              middlewares: middlewares),
          GetPage(
              name: "/login",
              page: () => const LoginScreen(),
              middlewares: middlewares),
          GetPage(
              name: "/splash",
              page: () => const SplashScreen(),
              middlewares: middlewares),
        ],
      );
}

class ApplicationMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (route == "/splash" || route == "/login") {
      return null;
    }

    if (!services().get<AuthService>().isSignedIn() ||
        !services().get<UserService>().bound) {
      warn("Navigating to ${route ?? "?"} before splash!");
      splashRouteTo = route ?? "/";
      return const RouteSettings(name: "/splash");
    }

    return null;
  }
}
