import 'package:accidentapp/views/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../viewmodels/loginViewModel.dart';
import 'home.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginViewModel _loginViewModel = LoginViewModel();
  String email = "";
  String password = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                "Accident Tracker",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                onChanged: (data) {
                  email = data;
                },
                decoration: InputDecoration(
                    focusColor: Color.fromARGB(255, 241, 81, 6),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    fillColor: Color.fromARGB(255, 56, 56, 56),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                cursorColor: Color.fromARGB(255, 241, 81, 6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                obscureText: true,
                onChanged: (data) {
                  password = data;
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    focusColor: Color.fromARGB(255, 241, 81, 6),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    fillColor: Color.fromARGB(255, 56, 56, 56),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                cursorColor: Color.fromARGB(255, 241, 81, 6),
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(value: false, onChanged: (bool? newValue) {}),
                Text("Remember Me")
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 56, 56, 56),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    _loginViewModel.login(email, password, false, (e) {
                      showDialog<void>(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text('Error'),
                              content: Text("Please try again"));
                        },
                      );
                    });
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Don't have an account?"),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) => Signup()));
                      },
                      child: Text(
                          style: TextStyle(
                            color: Color.fromARGB(255, 241, 81, 6),
                            fontWeight: FontWeight.bold,
                          ),
                          "Sign up"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
