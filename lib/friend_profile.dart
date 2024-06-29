import 'package:book_buds/userprofile_value.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'favorite_page.dart';
import 'tween_animation.dart'; // Flutter default package

class FriendProfile extends StatefulWidget{
  final String name;
  const FriendProfile({super.key, required this.name});

 @override
  State<StatefulWidget> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> with TickerProviderStateMixin{
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
    // Get friend favorites
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/${widget.name.replaceAll(RegExp('\\W'),"")}/favorites");
    Future<DataSnapshot> snap = ref.get();
    Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritePage(bookSnap: snap)));
    toggle = true;
    menu.controller.reverse();
  }
  void _removePressed(){
    String? username = UserProfileClass.getUserName();
    if (username == null) return; // Do nothing if not logged in
    // Database connection
    DatabaseReference favRef = FirebaseDatabase.instance.ref().child("users/$username/friends");
    Future<DataSnapshot> friendSnap = FirebaseDatabase.instance.ref().child("users/$username/friends").get();
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
              Positioned(top:0, left: 60,
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
                          toggle == false ?
                          DeferPointer(
                            child: IconButton(onPressed: _favPressed, 
                              icon: const Icon(Icons.star_rounded, size: 30.0),
                              padding: const EdgeInsets.all(0.0)
                            ),
                          ) : IconButton(onPressed: _favPressed, 
                              icon: const Icon(Icons.star_rounded, size: 30.0),
                              padding: const EdgeInsets.all(0.0)
                            ),
                          toggle == false ?
                          DeferPointer(
                            child: IconButton(onPressed: _removePressed, 
                              icon: const Icon(Icons.block, size: 25.0)
                            ),
                          ) : IconButton(onPressed: _removePressed, 
                              icon: const Icon(Icons.block, size: 25.0)
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