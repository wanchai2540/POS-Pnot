// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos/data/api/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAEC),
      body: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Image.asset(
                  "assets/icon/logo-splash.png",
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _username,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                    hintText: "Enter Your Username",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุชื่อผู้ใช้งาน';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                    hintText: "Enter Your Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุรหัสผ่าน';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color(0xFFF5ECD5),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      Map<String, dynamic> result = await DataService().login(_username.text, _password.text);
                      if (result["status"] == "success") {
                        Navigator.pushReplacementNamed(context, "/home");
                      } else if (result["status"] == "failed") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed: check your username or password'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: retry again'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
