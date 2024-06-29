import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'book_shelf.dart';
import 'friend_profile.dart';
import 'friend_request_page.dart';
import 'tween_animation.dart';
import 'userprofile_value.dart'; // Flutter default packalge

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: const _FriendsPage());
  }
}

class _FriendsPage extends StatefulWidget {
  const _FriendsPage();

  @override
  State<_FriendsPage> createState() => FriendsPageState();
}

// HomePage
class FriendsPageState extends State<_FriendsPage> with TickerProviderStateMixin{
  UserCredential? user = UserProfileClass.getValue();
  late Future<DataSnapshot> friendSnap;
  bool? showInput;
  bool? failedToFind;
  bool addToggle = false;
  late TweenAnimation<double> inputTween;

  @override
  void initState(){
    setState(()=>inputTween = TweenAnimation<double>(this, 500, 0.0, 1.0));
    // Get list of friends
    String? username = UserProfileClass.getUserName();
    if (username == null) return;
    friendSnap = FirebaseDatabase.instance.ref().child("users/$username/friends").get();
    
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
        bottomNavigationBar: const BottomAppBar(height: 50, child: Center(child: Text("Limit of 15 friends"))), 
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(margin: const EdgeInsets.fromLTRB(20,0,20,10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              FloatingActionButton(heroTag: null, onPressed: () async {
                //Do something
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestsPage()));
                
              }, child: const Icon(Icons.mail)),
              // Add Friend Stuff below
              AnimatedBuilder(
                animation: inputTween.controller, 
                builder: (context, w){
                  return SizedBox(width: 200 * inputTween.value.value, 
                    child: TextField(
                      obscureText: false,
                      decoration: InputDecoration(
                        border: showInput != null ? const OutlineInputBorder() : null,
                        labelText: "Email",
                      ),
                      textAlign: TextAlign.start,
                      onSubmitted: (String email){
                        //Something
                        inputTween.controller.reverse();
                        // Send request
                        String? username = UserProfileClass.getUserName();
                        if (username == null || showInput == null || username == email.replaceAll(RegExp('\\W'),"")) return;
                        DatabaseReference reqRef = FirebaseDatabase.instance.ref().child("users/${email.replaceAll(RegExp('\\W'),"")}/friend_requests");
                        Future<DataSnapshot> requestSnap = reqRef.get();
                        requestSnap.then((data){
                          if (mounted && data.value == null){
                            setState(()=>failedToFind = true);
                          } else if(data.value != null && mounted){
                            // Find user, then insert our name into their requests
                            Map<Object?, Object?> requests = data.value as Map<Object?, Object?>; // Get map from database
                            requests[username] = "true";
                            reqRef.set(requests.cast<String, Object?>()); // Update list
                          }
                        });
                        setState(()=>showInput = null);
                      },
                    )
                  );
                }
              ),
              FloatingActionButton(heroTag: null, onPressed: (){
                //Do something
                if (!addToggle){
                  inputTween.controller.forward();
                  setState(()=>showInput=true);
                } else{
                  inputTween.controller.reverse();
                  setState(()=>showInput=null);
                }
                setState(()=>addToggle=!addToggle);
              }, child: const Icon(Icons.add),
            )]
          ),
        ),
        body: FutureBuilder<DataSnapshot>(
          future: friendSnap,
          builder: (context, snapshot){
            Map<Object?,Object?>? friends = snapshot.data?.value as Map<Object?, Object?>?;
            if (friends != null){ // Convert friends map to list of profile UI
              List<FriendProfile> friendsList = [];
              for (Object? friend in friends.keys){
                if (friends[friend] == "") continue; // Skip invalid friend / placeholder
                friendsList.add(
                  FriendProfile(
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