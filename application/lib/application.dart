import 'package:application/main.dart';
import 'package:application/service/auth_service.dart';
import 'package:application/service/firestore_service.dart';
import 'package:application/service/storage_service.dart';
import 'package:application/service/user_service.dart';
import 'package:application/ui/screen/home.dart';
import 'package:application/ui/screen/login.dart';
import 'package:application/ui/screen/splash.dart';
import 'package:application/util/generated/assets.gen.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serviced/serviced.dart';
import 'package:tinycolor2/tinycolor2.dart';

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
  Future<void> onStartup() async {}

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

  @override
  Widget buildLoginBackground(BuildContext context) => Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
          Theme.of(context).scaffoldBackgroundColor,
          Theme.of(context).primaryColor.desaturate(25)
        ], radius: 15)),
      );

  @override
  Widget buildLoginLogo(BuildContext context) => Assets.icon.icon.svg(
      width: 275,
      height: 275,
      colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcATop));
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
