import 'package:application/main.dart';
import 'package:application/service/auth_service.dart';
import 'package:application/service/user_service.dart';
import 'package:application/util/generated/assets.gen.dart';
import 'package:application/util/sugar.dart';
import 'package:delayed_progress_indicator/delayed_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:padded/padded.dart';
import 'package:serviced/serviced.dart';
import 'package:get/get.dart';
import 'package:snackbar/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (!_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
          const Duration(milliseconds: 750), () => dropSplash()));
    }
    Paint.enableDithering = true;
    Widget w = _loading
        ? Scaffold(
            body: Stack(
              children: [
                rapp.buildLoginBackground(context),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                rapp.buildLoginBackground(context),
                Align(
                  alignment: Alignment.center,
                  child: LoginContent(state: this),
                )
              ],
            ),
          );
    Paint.enableDithering = false;
    return w;
  }
}

class LoginContent extends StatelessWidget {
  final _LoginScreenState state;
  const LoginContent({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          rapp.buildLoginLogo(context),
          GoogleSignInButton(state: state),
          PaddingTop(padding: 14, child: Container()),
          Visibility(
            visible: isIOS(),
            child: AppleSignInButton(state: state),
          ),
        ],
      );
}

class AppleSignInButton extends StatelessWidget {
  final _LoginScreenState state;

  const AppleSignInButton({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => state.setState(() {
          state._loading = true;
          svc<AuthService>().signInWithApple().then((value) {
            svc<UserService>()
                .bind(svc<UserService>().userId())
                .then((value) => Get.offAndToNamed("/"));
          }).catchError((e) {
            state.setState(() {
              state._loading = false;
              snack("Login failed: $e");
            });
          });
        }),
        child: PaddingAll(
          padding: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaddingRight(
                padding: 14,
                child: Assets.icon.apple
                    .svg(width: 32, height: 32, color: Colors.white),
              ),
              const Text("Sign in with Apple",
                  style: TextStyle(color: Colors.white, fontSize: 18))
            ],
          ),
        ),
      );
}

class GoogleSignInButton extends StatelessWidget {
  final _LoginScreenState state;

  const GoogleSignInButton({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => state.setState(() {
          state._loading = true;
          svc<AuthService>().signInWithGoogle().then((value) {
            svc<UserService>()
                .bind(svc<UserService>().userId())
                .then((value) => Get.offAndToNamed("/"));
          }).catchError((e) {
            state.setState(() {
              state._loading = false;
              snack("Login failed: $e");
            });
          });
        }),
        child: PaddingAll(
          padding: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaddingRight(
                padding: 14,
                child: Assets.icon.google.svg(width: 32, height: 32),
              ),
              const Text("Sign in with Google",
                  style: TextStyle(color: Colors.white, fontSize: 18))
            ],
          ),
        ),
      );
}
