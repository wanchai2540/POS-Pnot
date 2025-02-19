import 'package:flutter/material.dart';
import 'package:kymscanner/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void didChangeDependencies() {
    Future.delayed(Duration(seconds: 2, milliseconds: 500), () async {
      await checkLogin() == null
          ? Navigator.pushReplacementNamed(context, "/login")
          : Navigator.pushReplacementNamed(context, "/home");
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFFAEC),
      child: Center(
        child: Image.asset(
          "assets/icon/logo-splash.png",
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
