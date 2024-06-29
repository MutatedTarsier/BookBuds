import 'package:book_buds/userprofile_value.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'tween_animation.dart'; // Flutter default package

class RequestProfile extends StatefulWidget{
  final String name;
  const RequestProfile({super.key, required this.name});

 @override
  State<StatefulWidget> createState() => _RequestProfileState();
}

class _RequestProfileState extends State<RequestProfile> with TickerProviderStateMixin{
  late TweenAnimation<double> menu;
  bool removed = false;
  bool toggle = true;
  void _onPressed(){
    if (toggle) {
      menu.controller.forward();
    } else {
      menu.controller.reverse();
    }
    toggle = !toggle;
  }
  void _favPressed(){
    String? username = UserProfileClass.getUserName();
    if (username == null) return; // Do nothing if not logged in
    // Add Person to friend
    DatabaseReference friendRef = FirebaseDatabase.instance.ref().child("users/$username/friends");
    Future<DataSnapshot> friendSnap = friendRef.get();
    friendSnap.then((data){
      if (data.value != null){
        Map<Object?, Object?> friends = data.value as Map<Object?, Object?>; // Get map from database
        friends[widget.name] = "true";
        friendRef.set(friends.cast<String, Object?>()); // Update list
      }
    });
    // Add us to other
    DatabaseReference otherRef = FirebaseDatabase.instance.ref().child("users/${widget.name}/friends");
    Future<DataSnapshot> otherSnap = otherRef.get();
    otherSnap.then((data){
      if (data.value != null){
        Map<Object?, Object?> friends = data.value as Map<Object?, Object?>; // Get map from database
        friends[username] = "true";
        otherRef.set(friends.cast<String, Object?>()); // Update list
      }
    });
    // Database connection
    DatabaseReference favRef = FirebaseDatabase.instance.ref().child("users/$username/friend_requests");
    Future<DataSnapshot> reqSnap = favRef.get();
    // Removes friend name from database
    reqSnap.then((snapshot){
      if (snapshot.value != null){
        Map<Object?, Object?> friends = snapshot.value as Map<Object?, Object?>; // Get map from database
        friends.removeWhere((key, value) => key == widget.name); // Delete title from map
        favRef.set(friends.cast<String, Object?>()); // Update list
      }
    });
    // Replace Icon with blocked icon
    setState(() => removed = true);
    
  }
  void _removePressed(){
    String? username = UserProfileClass.getUserName();
    if (username == null) return; // Do nothing if not logged in
    // Database connection
    DatabaseReference favRef = FirebaseDatabase.instance.ref().child("users/$username/friend_requests");
    Future<DataSnapshot> friendSnap = FirebaseDatabase.instance.ref().child("users/$username/friend_requests").get();
    // Removes friend name from database
    friendSnap.then((snapshot){
      if (snapshot.value != null){
        Map<Object?, Object?> friends = snapshot.value as Map<Object?, Object?>; // Get map from database
        friends.removeWhere((key, value) => key == widget.name); // Delete title from map
        favRef.set(friends.cast<String, Object?>()); // Update list
      }
    });
    // Replace Icon with blocked icon
    setState(() => removed = true);
  }

  @override
  void initState(){
    setState((){
      menu = TweenAnimation<double>(this, 300, 0.0, 1.0);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    if (removed == true) {
      return const SizedBox(height: 135, width: 135, 
        child: FittedBox(child: Icon(Icons.block, color: Colors.red)
      ));
    }
    return SizedBox(height: 135, width: 135, 
      child: TextButton(
        onPressed: _onPressed,
        child: DeferredPointerHandler(
          child: Stack(clipBehavior: Clip.none,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(flex: 70,child: 
                    FittedBox(child: Icon(Icons.person))
                  ),
                  Expanded(flex: 30, child: FittedBox(child: Text(widget.name)))
                ],
              ),
              Positioned(top:0, left: 70,
                child: AnimatedBuilder(
                  animation: menu.controller,
                  builder: (context, w){
                    return Container(clipBehavior: Clip.hardEdge,
                      height: 100 * menu.value.value,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(93, 157, 241, 1),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DeferPointer(
                            child: IconButton(onPressed: _favPressed, 
                              icon: const Icon(Icons.check, size: 30.0, color: Colors.green),
                              padding: const EdgeInsets.all(0.0)
                            ),
                          ),
                          DeferPointer(
                            child: IconButton(onPressed: _removePressed, 
                              icon: const Icon(Icons.cancel, size: 25.0)
                            ),
                          ),
          
                        ],
                      )
                    );
                  }
                )
              )
            ],
          ),
        ),
      )
    );
  }
}