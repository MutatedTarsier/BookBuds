// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart'; // Flutter default package
import 'package:firebase_auth/firebase_auth.dart';
import 'userprofile_value.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context){
    return const _ProfilePage();
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<_ProfilePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserCredential? user;
  void _signin(TextEditingController passwordController, TextEditingController usernameController) async {
    try {
      user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: usernameController.text, password: passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Successfully signed in!"),
          backgroundColor: Colors.green,
        )
      );
      UserProfileClass.setValue(user);
      Navigator.pop(context);
    } catch (message){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Failed to log in, please try again"),
          backgroundColor: Colors.red,
        )
      );
    }
  }
  void _createAccount(TextEditingController passwordController, TextEditingController usernameController) async {
    try {
      // Add user to database
      FirebaseDatabase.instance.ref().child("users/${usernameController.text.replaceAll(RegExp('\\W'),"")}").set({
        "email" : usernameController.text, // email stored as value
        "name" : usernameController.text.split("@")[0],
        "favorites" : {"nothing":""},
        "friends" : {"nothing":""},
        "friend_requests" : {"nothing":""},
      }).then((value){
        print("Successfully created account");
      }).catchError((error){
        print(error);
        throw(error);
      });
      //
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: usernameController.text, password: passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Account successfully created! Proceed to sign in"),
          backgroundColor: Colors.green,
        )
      );
    } catch (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Failed to create account, please try again"),
          backgroundColor: Colors.red,
        )
      );
    }
  }
  @override
  Widget build(BuildContext context){
    TextEditingController passwordController = TextEditingController(); // Deleted after sign in
    TextEditingController usernameController = TextEditingController(); // Deleted after sign in
    return Center(
      child: Scaffold(appBar: AppBar(), key: scaffoldKey, resizeToAvoidBottomInset: false,body: (Column(children: [
        const Expanded(flex: 15, child: Text("")),
        Expanded(flex: 85, child: Column(children: [
          // Profile picture
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(width: 2, color: Colors.black)
            ),
            child: const Icon(Icons.person, size: 100)
          ),
          Container(margin: const EdgeInsets.fromLTRB(40,40,40,0),
            child: TextField(
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
              ),
              textAlign: TextAlign.start,
              controller: usernameController,

            ),
          ),
          Container(margin: const EdgeInsets.fromLTRB(40,20,40,0),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
              textAlign: TextAlign.start,
              controller: passwordController,
            ),
          ),
          Container(margin: const EdgeInsets.fromLTRB(0,20,0,0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _signin(passwordController, usernameController),
                  child: const Text("Sign In", style: TextStyle(fontSize: 15),)
                ),
                TextButton(
                  onPressed: () => _createAccount(passwordController, usernameController),
                  child: const Text("Create Account", style: TextStyle(fontSize: 15),)
                ),
              ],
            ),
          ),
        ])),
      ]
      ))),
    );
  }
}