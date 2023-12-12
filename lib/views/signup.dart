import 'package:accidentapp/viewmodels/signupViewModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  SignUpViewModel signupViewModel = SignUpViewModel();
  String userType = 'Rider';
  String helmetMacAddress = "";
  String selectedAvatar = "assets/avatars/Frame-0.png";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    signupViewModel.userAvatar = "Frame-0.png";
    signupViewModel.userType = "Rider";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      enableDrag: true,
                      showDragHandle: true,
                      builder: (BuildContext context) {
                        return AvatarSelection(
                            initialValue: selectedAvatar,
                            onChange: (data) {
                              signupViewModel.userAvatar = data;
                              setState(() {
                                selectedAvatar = 'assets/avatars/${data}';
                              });
                            });
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: Image(image: AssetImage(selectedAvatar)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    onChanged: (data) {
                      signupViewModel.email = data;
                    },
                    decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.white),
                        focusColor: Color.fromARGB(255, 241, 81, 6),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        fillColor: Color.fromARGB(255, 56, 56, 56),
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    cursorColor: Color.fromARGB(255, 241, 81, 6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    obscureText: true,
                    onChanged: (data) {
                      signupViewModel.password = data;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.white),
                        focusColor: Color.fromARGB(255, 241, 81, 6),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        fillColor: Color.fromARGB(255, 56, 56, 56),
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    cursorColor: Color.fromARGB(255, 241, 81, 6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    onChanged: (data) {
                      signupViewModel.nickname = data;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Nickname",
                        hintStyle: TextStyle(color: Colors.white),
                        focusColor: Color.fromARGB(255, 241, 81, 6),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        fillColor: Color.fromARGB(255, 56, 56, 56),
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    cursorColor: Color.fromARGB(255, 241, 81, 6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    onChanged: (data) {
                      signupViewModel.contactNumber = data;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Contact Number",
                        hintStyle: TextStyle(color: Colors.white),
                        focusColor: Color.fromARGB(255, 241, 81, 6),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        fillColor: Color.fromARGB(255, 56, 56, 56),
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    cursorColor: Color.fromARGB(255, 241, 81, 6),
                  ),
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Text("User Type: ${userType}"),
                    Expanded(
                      child: Container(),
                    ),
                    Switch(
                        value: userType == 'Rider',
                        onChanged: (data) {
                          signupViewModel.userType = data ? "Rider" : "Regular";

                          setState(() {
                            userType = data ? "Rider" : "Regular";
                          });
                        })
                  ],
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 56, 56, 56),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () async {
                      final notificationSettings = await FirebaseMessaging
                          .instance
                          .requestPermission(provisional: true);

                      // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
                      final apnsToken =
                          await FirebaseMessaging.instance.getToken();
                      if (apnsToken != null) {
                        signupViewModel.SignupUser(apnsToken, () {
                          showDialog<void>(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: const Text('Error'),
                                  content: Text("Please try again"));
                            },
                          );
                        }, () {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child:
                        Text("Sign up", style: TextStyle(color: Colors.white)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AvatarSelection extends StatefulWidget {
  late Function onChangeAvatar;
  String? defValue = null;
  AvatarSelection({
    super.key,
    required String initialValue,
    required Function onChange,
  }) {
    defValue = initialValue;
    onChangeAvatar = onChange;
  }

  @override
  State<AvatarSelection> createState() => _AvatarSelectionState();
}

class _AvatarSelectionState extends State<AvatarSelection> {
  String? selectedAvatar = null;

  List<String> background = [
    "Frame-0.png",
    "Frame-1.png",
    "Frame-2.png",
    "Frame-3.png",
    "Frame-4.png",
    "Frame-5.png",
  ];

  @override
  void initState() {
    selectedAvatar = widget.defValue;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 3,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(6, (index) {
        return Center(
          child: GestureDetector(
              onTap: () {
                widget.onChangeAvatar(background[index]);
                setState(() {
                  selectedAvatar = background[index];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: selectedAvatar == background[index]
                        ? Colors.amber
                        : Colors.transparent),
                child: Image(
                    image: AssetImage('assets/avatars/${background[index]}')),
              )),
        );
      }),
    );
  }
}
