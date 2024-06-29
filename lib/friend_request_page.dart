import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'book_shelf.dart';
import 'request_profile.dart';
import 'userprofile_value.dart'; // Flutter default packalge

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: const _RequestsPage());
  }
}

class _RequestsPage extends StatefulWidget {
  const _RequestsPage();

  @override
  State<_RequestsPage> createState() => RequestsPageState();
}

// HomePage
class RequestsPageState extends State<_RequestsPage> with TickerProviderStateMixin{
  UserCredential? user = UserProfileClass.getValue();
  late Future<DataSnapshot> friendSnap;

  @override
  void initState(){
    // Get list of friends
    String? username = UserProfileClass.getUserName();
    if (username == null) return;
    friendSnap = FirebaseDatabase.instance.ref().child("users/$username/friend_requests").get();
    
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if (user == null){ // Build if not logged in
      return const Center(
        child: Column(
          children: [
            Expanded(flex: 40, child: Text("")),
            Expanded(flex: 60,child: Text("Please sign in to see friends", style: TextStyle(fontSize: 25))),
          ],
        )
      );
      
    } else {
      return Scaffold(
        body: FutureBuilder<DataSnapshot>(
          future: friendSnap,
          builder: (context, snapshot){
            Map<Object?,Object?>? friends = snapshot.data?.value as Map<Object?, Object?>?;
            if (friends != null){ // Convert friends map to list of profile UI
              List<RequestProfile> friendsList = [];
              for (Object? friend in friends.keys){
                if (friends[friend] == "") continue; // Skip invalid friend / placeholder
                friendsList.add(
                  RequestProfile(
                    name: friend as String
                  )
                );
              }
              // UI for bookshelf
              return BookShelf(
                size: const Size(3.0,5.0),
                custom: friendsList,
              );
            } else {          
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.blue, size: 100)
              );
            }
          }
        ),
      );
    }
  }
}