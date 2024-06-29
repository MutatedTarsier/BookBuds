// ignore_for_file: use_build_context_synchronously

import 'dart:convert'; // JSON decode
import 'package:flutter/material.dart'; // Flutter default package
import 'package:flip_card/flip_card.dart'; // Flip Card package
import 'package:http/http.dart' as http; // Package for fetching data through http

// Custom widgets
import 'search_page.dart';
import 'tween_animation.dart';

class BookSearch extends StatefulWidget {
  final double screenHeight, screenWidth, barPosition;
  final Size barSize;
  final GlobalKey<FlipCardState> coverKey;
  final TweenAnimation<double>? tween;
  final TweenAnimation<double>? tween2;
  final TweenAnimation<double>? shelfTween;

  const BookSearch({super.key, this.screenHeight = 1000, this.screenWidth = 1000, 
                     this.barPosition = 100, this.barSize = const Size(100,100), 
                     required this.coverKey, this.tween, this.tween2, this.shelfTween});
  @override
  State<StatefulWidget> createState() => _SearchState();
}
Future<Map> fetchAlbum(String searchUrl) async { // Parse information from internet
  final response = await http.get(Uri.parse(searchUrl));
  if (response.statusCode == 200){
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    return {};
  }
}
class _SearchState extends State<BookSearch> with TickerProviderStateMixin{
  // Animation controllers
  late TweenAnimation<double> shelfTween;
  late TweenAnimation<double> coverTweenOut;
  //
  void _onSearchSubmit(String input) async {
    // Get Web API from OpenLibrary
    input = input == "" ? "Default" : input;
    String searchUrl = 'https://openlibrary.org/search.json?title=$input';
    Map bookJson = await fetchAlbum(searchUrl); // Get Book information
    // Animate UI
    if (widget.coverKey.currentState?.isFront == false && widget.tween != null){ // Close book cover
      widget.tween?.controller.reverse();
      widget.coverKey.currentState?.toggleCard();
    }
    await Future.delayed(const Duration(milliseconds:550)); // Wait for cover to close
    // Slide entire book off screen
    setState(() {
      widget.tween?.makeNew(this, 500, widget.screenHeight * 0.5 - widget.screenWidth / 4.4 * 1.3198 + widget.screenWidth/40, widget.screenHeight, 1); // Slide cover off screen with new controller
    });
    widget.tween?.controller.forward();
    widget.tween2?.controller.forward(); // Slide book backside off screen
    await Future.delayed(const Duration(milliseconds:500)); // Wait for book to leave
    Future popped = Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(bookMap: bookJson))); // Send to new page
    popped.then((value) async {
      // Animate book back in
      widget.tween?.controller.reverse();
      widget.tween2?.controller.reverse();
      await Future.delayed(const Duration(milliseconds:500)); // Wait for book to come back
      widget.tween?.usePrevious();
    });
  }
  @override
  void initState(){
    super.initState();
    final double gridPosition = widget.screenHeight * 0.15;
    setState(() {
      shelfTween = TweenAnimation<double>(this, 300, widget.screenHeight, gridPosition);
      coverTweenOut = TweenAnimation<double>(this, 300, widget.screenHeight, gridPosition);
    });
  }
  @override 
  Widget build(BuildContext context){
    return Stack(
        children: <Widget>[
          // Expand Stack
          SizedBox(
            height: widget.screenHeight,
            width: widget.screenWidth
          ),
          // Search Bar
          Positioned(left: widget.barPosition, top: widget.screenHeight * 0.05,
            child: SearchBar(
              // Search icon
              leading: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 24.0,
              ),
              hintText: 'Search',
              constraints: BoxConstraints.tight(widget.barSize),
              // Events
              onSubmitted: (String input){
                _onSearchSubmit(input);  
                FocusScope.of(context).unfocus();                    
              },
              onTap: (){
                if (widget.coverKey.currentState?.isFront == true && widget.tween != null){
                  widget.tween?.controller.forward();
                  widget.coverKey.currentState?.toggleCard();
                }
              },
              onTapOutside: (PointerDownEvent event){
                if (widget.coverKey.currentState?.isFront == false && widget.tween != null){
                  widget.tween?.controller.reverse();
                  widget.coverKey.currentState?.toggleCard();
                  FocusScope.of(context).unfocus();
                }
              }
            )
          ),
        ]
      
    );
  }
}