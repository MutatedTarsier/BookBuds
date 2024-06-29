import 'package:book_buds/favorite_page.dart';
import 'package:flutter/material.dart'; // Flutter default package
import 'padded_list.dart';
import 'tween_animation.dart';
import 'friends_page.dart';

class MenuSideBar extends StatefulWidget{
  final double screenHeight;
  final double screenWidth;
  final int animationDuration;
  final double endSize;
  final TickerProvider tick;

  const MenuSideBar({required this.tick, super.key, this.screenHeight = 1000, this.screenWidth = 1000, 
                     this.animationDuration = 300, this.endSize = 1.0});
  
  @override
  State<MenuSideBar> createState() => _State();
}

class _State extends State<MenuSideBar>{
  late TweenAnimation<double> menuTween;
  late Animation<double> size;
  bool menuToggle = true;
  Color menuButtonColor = Colors.black;
  @override
  void initState(){
    super.initState();
    menuTween = TweenAnimation<double>(widget.tick, widget.animationDuration, 0.0, widget.endSize); // Start animation event for menu
    size = menuTween.value;
  }
  void _onPressed(){
    if (menuToggle) {
      menuTween.controller.forward();
      menuToggle = !menuToggle;
    } else {
      menuTween.controller.reverse();
      menuToggle = !menuToggle;
    }
  }
  @override
  Widget build(BuildContext context){
    return Stack(children: <Widget>[
        // Expand space of stack
        SizedBox( 
          height: widget.screenHeight,
          width: widget.screenWidth,
        ),
        // Animated bar
        Positioned(left: widget.screenWidth * 0.04, top: widget.screenHeight * 0.045,
          child: AnimatedBuilder(
            animation: size,
            builder: (context, child) {
              return Container(clipBehavior: Clip.hardEdge,
                height: size.value * 120,
                width: 45,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(93, 157, 241, 1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center,children: [
                  // Push to menu height
                  const Padding(padding: EdgeInsets.fromLTRB(0,30,0,0)), 
                  PaddedList(padding: const EdgeInsets.all(5),
                    children: <Widget>[
                      
                      SizedBox(width: 50, height: 30,
                        child: IconButton(
                          icon: const Icon(Icons.star_rounded, size: 30), 
                          color: const Color.fromARGB(255, 0, 0, 0),
                          onPressed: () { 
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritePage()));
                            menuToggle = true;
                            menuTween.controller.reverse();
                          },
                        ),
                      ),
                      SizedBox(width: 50, height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.people, size: 30, color:  Color.fromARGB(255, 0, 0, 0)),
                          onPressed: () { 
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendsPage()));
                            menuToggle = true;
                            menuTween.controller.reverse();
                          },
                        ),
                      ),                   
                    ],
                  ),
                ]),
              );
            }
          ),
        ),
        // Menu Button
        Positioned(width: 45, height: 40,
          left: widget.screenWidth * 0.04,
          top: widget.screenHeight * 0.04,
          child: SizedBox(width: 50, height: 40,
            child: IconButton(
              onPressed: _onPressed,
              icon: const Icon(Icons.menu, color: Colors.black),
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory
              ),
            ),
          ),
        ),
      ]
    );
  }
}