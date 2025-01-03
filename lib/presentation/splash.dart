import 'package:flutter/material.dart';
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
      await checkLogin() == false
          ? Navigator.pushReplacementNamed(context, "/login")
          : Navigator.pushReplacementNamed(context, "/home");
    });
    super.didChangeDependencies();
  }

  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    if (accessToken != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
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
