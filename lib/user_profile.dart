import 'package:flutter/material.dart'; // Flutter default package
// Custom widgets
import 'tween_animation.dart';
import 'userprofile_value.dart';

class UserProfile extends StatefulWidget{
  final Function? onPressed;
  final Function loginPressed;
  const UserProfile({super.key, this.onPressed, required this.loginPressed});

  @override
  State<StatefulWidget> createState() => _ProfileState();
}
class _ProfileState extends State<UserProfile> with TickerProviderStateMixin{
  late TweenAnimation<double> valueTween;
  bool profileState = false;
  // Event functions
  void profilePressed(){
    if (!profileState){
      valueTween.controller.forward(); // Animate dropdown menu
    } else {
      valueTween.controller.reverse(); // Retract dropdown menu
    }
    profileState = !profileState;
  }
  // Overrides
  @override
  void initState(){
    super.initState();
    setState((){
      valueTween = TweenAnimation<double>(this, 200, 0.0, 1.0);
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Positioned(right: screenWidth * 0.05, top: screenHeight * 0.04, child: Stack(children: <Widget>[
        const SizedBox(width: 100, height: 100),
        Positioned(left: 35, child: IconButton(
          icon: const Icon(Icons.person), iconSize: 40.0,
          splashColor: Colors.blue,
          onPressed: profilePressed, 
        )),
        AnimatedBuilder(
          animation: valueTween.controller,
          builder: (context, w){
            return Positioned(right:-12, top: 40, child: 
              SizedBox(width: 100, height: valueTween.value.value * 45, child:
                FittedBox(child: TextButton(
                  onPressed: () {
                    if (UserProfileClass.getValue() == null){
                      widget.loginPressed(valueTween);
                      profileState = false;
                    } else {
                      UserProfileClass.setValue(null); // Set Userprofile to null to sign out
                      valueTween.controller.reverse();
                      profileState = false;
                    }
                  },
                  child: Text(UserProfileClass.getValue() == null ? "Sign In" : "Sign Out", style: const TextStyle(color: Colors.black, )),
                ))
              )
            );
          }
        ),
    ]));
  }
}