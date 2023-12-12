import 'package:accidentapp/models/userData.dart';
import 'package:accidentapp/services/userDataService.dart';
import 'package:accidentapp/viewmodels/userViewModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/relationshipService.dart';
import 'viewmodels/homeViewModel.dart';
import 'views/home.dart';
import 'views/users.dart';

class AuthenticatedLayout extends StatefulWidget {
  AuthenticatedLayout({Key? key}) : super(key: key);

  @override
  State<AuthenticatedLayout> createState() => _AuthenticatedLayoutState();
}

class _AuthenticatedLayoutState extends State<AuthenticatedLayout> {
  UserDataService userDataService = UserDataService();
  UserViewModel? userViewModel;
  int currentIndex = 0;
  List<Widget> pages = [Home(), Users()];

  @override
  void initState() {
    super.initState();
    userViewModel = UserViewModel();
  }

  @override
  Widget build(BuildContext context) {
    String? relationship = null;

    return FutureBuilder(
        future: userDataService.getMyData(),
        builder: (context, snapshot) {
          // if(snapshot.data==null){
          //   FirebaseAuth.instance.signOut();
          //   return Container();
          // }
          if (snapshot.hasData) {
            userViewModel?.forApproval = snapshot.data?.forApproval;
            userViewModel?.relatives = snapshot.data?.relatives;

            return MultiProvider(
                providers: [
                  Provider(create: (_) => snapshot.data),
                  ChangeNotifierProvider<HomeViewModel>(
                      create: (context) => HomeViewModel()),
                  ChangeNotifierProvider<UserViewModel>(
                      create: (context) => userViewModel as UserViewModel),
                ],
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(children: [
                          Container(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                                "assets/avatars/${snapshot.data?.userAvatar}"),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                                snapshot.data == null
                                    ? ""
                                    : snapshot.data!.nickname,
                                style: TextStyle(color: Colors.black)),
                          ),
                          GestureDetector(
                              onTap: () async {
                                Clipboard.setData(ClipboardData(
                                        text: FirebaseAuth
                                            .instance.currentUser!.uid))
                                    .then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("UID copied to clipboard")));
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.copy,
                                ),
                              ))
                        ]),
                      ),
                      Expanded(child: Container()),
                      currentIndex == 1
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 56, 56, 56),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    FirebaseAuth.instance.signOut();
                                  },
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Accident Tracker",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 241, 81, 6),
                                      fontWeight: FontWeight.w700)),
                            )
                    ],
                  ),
                  body: pages[currentIndex],
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: currentIndex == 1
                      ? Container(
                          height: 50,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 56, 56, 56),
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  enableDrag: true,
                                  showDragHandle: true,
                                  builder: (BuildContext context) {
                                    return AddRelatives(
                                      userViewModel:
                                          userViewModel as UserViewModel,
                                    );
                                  },
                                );
                              },
                              child: const Center(
                                child: Text('Add Relative',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        )
                      : null,
                  bottomNavigationBar: Theme(
                    data: ThemeData(
                      highlightColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 56, 56, 56),
                          borderRadius: BorderRadius.circular(20)),
                      child: BottomNavigationBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          currentIndex: currentIndex,
                          onTap: (value) {
                            setState(() {
                              currentIndex = value;
                            });
                          },
                          showSelectedLabels: true,
                          showUnselectedLabels: false,
                          selectedItemColor: Color.fromARGB(255, 241, 81, 6),
                          unselectedItemColor: Colors.white,
                          items: [
                            BottomNavigationBarItem(
                                icon: Icon(Icons.dashboard),
                                label: "Dashboard"),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.verified_user_sharp),
                              label: "Users",
                            )
                          ]),
                    ),
                  ),
                ));
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Loading....",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                )
              ],
            ),
          );
        });
  }
}

class AddRelatives extends StatefulWidget {
  final UserViewModel userViewModel;
  AddRelatives({Key? key, required this.userViewModel}) : super(key: key);

  @override
  State<AddRelatives> createState() => _AddRelativesState();
}

class _AddRelativesState extends State<AddRelatives> {
  UserDataService userDataService = new UserDataService();
  RelationShipService relationShipService = new RelationShipService();
  String? relationship = null;
  String? uid = "";
  bool? isFound = null;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.white),
              onChanged: (data) async {
                if (data == null || data == "") {
                  setState(() {
                    isFound = null;
                  });
                  return;
                }
                UserData? fnd = await userDataService.getUserDataByUID(data);
                widget.userViewModel.uid = data;
                setState(() {
                  isFound = fnd != null;
                  uid = fnd!.uid;
                });
              },
              decoration: InputDecoration(
                  hintText: "Insert UID",
                  hintStyle: TextStyle(color: Colors.white),
                  focusColor: Color.fromARGB(255, 241, 81, 6),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  fillColor: Color.fromARGB(255, 56, 56, 56),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
              cursorColor: Color.fromARGB(255, 241, 81, 6),
            ),
            Visibility(
              visible: isFound != null,
              child: Text(
                isFound == true ? "User found" : "No User Found",
                style: TextStyle(
                  color: isFound == true ? Colors.green : Colors.red,
                ),
              ),
            ),
            Container(
              height: 200,
              child: GridView.count(
                primary: false,
                crossAxisCount: 3,
                children: <Widget>[
                  ChoiceChip(
                    label: Text("Father"),
                    selectedColor: Colors.amber,
                    onSelected: (data) {
                      if (data) {
                        widget.userViewModel.selected = "Father";
                        setState(() {
                          relationship = "Father";
                        });
                      }
                    },
                    selected: relationship == "Father",
                  ),
                  ChoiceChip(
                    label: Text("Mother"),
                    selectedColor: Colors.amber,
                    selected: relationship == "Mother",
                    onSelected: (data) {
                      if (data) {
                        widget.userViewModel.selected = "Mother";
                        setState(() {
                          relationship = "Mother";
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text("Sibling"),
                    selectedColor: Colors.amber,
                    selected: relationship == "Sibling",
                    onSelected: (data) {
                      if (data) {
                        widget.userViewModel.selected = "Sibling";
                        setState(() {
                          relationship = "Sibling";
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text("Niece"),
                    selectedColor: Colors.amber,
                    selected: relationship == "Niece",
                    onSelected: (data) {
                      if (data) {
                        widget.userViewModel.selected = "Niece";
                        setState(() {
                          relationship = "Niece";
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text("Nephew"),
                    selectedColor: Colors.amber,
                    selected: relationship == "Nephew",
                    onSelected: (data) {
                      if (data) {
                        widget.userViewModel.selected = "Nephew";
                        setState(() {
                          relationship = "Nephew";
                        });
                      }
                    },
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                widget.userViewModel.addRelativeClient();
                showDialog<void>(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text('Note'),
                        content: Text(
                            "Wait for the other person to accept your request"));
                  },
                );
              },
              child: Text("Add", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 56, 56, 56),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
