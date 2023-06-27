import 'package:application/main.dart';
import 'package:application/service/auth_service.dart';
import 'package:application/service/firestore_service.dart';
import 'package:application/service/storage_service.dart';
import 'package:application/service/user_service.dart';
import 'package:application/ui/screen/home.dart';
import 'package:application/ui/screen/login.dart';
import 'package:application/ui/screen/splash.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serviced/serviced.dart';

class Application extends RevenantApp {
  final List<GetMiddleware> _middlewares = [ApplicationMiddleware()];

  @override
  void onRegisterServices() {
    services().register(() => StorageService(), lazy: false);
    services().register(() => FirestoreService());
    services().register(() => AuthService());
    services().register(() => UserService());
  }

  @override
  Future<void> onStartup() async {
    // Do your own custom async shit before the app opens
  }

  GetPage _page(String name, GetPageBuilder screen) =>
      GetPage(name: name, page: screen, middlewares: _middlewares);

  @override
  Widget build() => GetMaterialApp(
        title: "Application",
        getPages: [
          _page("/", () => const HomeScreen()),
          _page("/login", () => const LoginScreen()),
          _page(
            "/splash",
            () => const SplashScreen(),
          ),
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

    if (!svc<AuthService>().isSignedIn() || !svc<UserService>().bound) {
      warn("Navigating to ${route ?? "?"} before splash!");
      splashRouteTo = route ?? "/";
      return const RouteSettings(name: "/splash");
    }

    return null;
  }
}
