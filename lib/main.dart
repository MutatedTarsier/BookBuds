import 'dart:ui';

import 'package:flutter/material.dart'; // Flutter default package
import 'package:flip_card/flip_card.dart'; // Flip Card package
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Custom made widgets
import 'tween_animation.dart'; // Tween class for reusibility
import 'menu_sidebar.dart'; // Side bar script
import 'search_bar.dart'; // Search bar script
import 'user_profile.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // App Name
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(186, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Project Title'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  //Fields in a Widget subclass are always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

// HomePage
class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  // Keys
  ProfilePageState? profileState;
  GlobalKey<FlipCardState> coverKey = GlobalKey<FlipCardState>();

  // Constant variables
  final double menuWidth = 65.0;
  final int menuTime = 200; // In Milliseconds
  // Controllers
  late TweenAnimation<double> bookTween;
  late TweenAnimation<double> bookInsideTween;
  // Event functions
  void loginPressed(TweenAnimation valueTween){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
    valueTween.controller.reverse();
  }

  @override
  void initState(){
	FlutterView view = PlatformDispatcher.instance.views.first;
	double screenWidth = (view.physicalSize / view.devicePixelRatio).width;
	double screenHeight = (view.physicalSize / view.devicePixelRatio).height;
	setState((){ // setState has to be in initState to update book position
  // Some math to scale book size and position
      bookTween = TweenAnimation<double>(this, 500, (screenWidth*1.2) / 4.4 - screenWidth / 50, ((screenWidth*1.2) / 4.4 - screenWidth / 50) - screenWidth / 2.2 + screenWidth/50);
      bookInsideTween = TweenAnimation<double>(this, 500, screenHeight * 0.5 - screenWidth / 4 * 1.2525, screenHeight);
  });
	super.initState();
  }
  
  @override
  Widget build(BuildContext context) { // UI for homepage
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    const Size searchBoxSize = Size(150, 30);
    double positionOfSearch = screenWidth * 0.5 - searchBoxSize.width * 0.5; // X Position is at 1/2 of screen width
	
    
    return Scaffold(body: Stack(clipBehavior: Clip.none, children:[    
      // Search Bar
      BookSearch(
        screenHeight: screenHeight, 
        screenWidth: screenWidth, 
        barPosition: positionOfSearch, 
        barSize: const Size(150,30), 
        coverKey: coverKey,
        tween: bookTween,
        tween2: bookInsideTween
      ),
      // App Logo Inside
      AnimatedBuilder(
        animation: bookInsideTween.controller, builder: (context, w){
          return Stack(children:<Widget>[
            SizedBox(width: screenWidth, height: screenHeight),
            // Book backside
            Positioned(left: screenWidth * 0.25, top: bookInsideTween.value.value,child: 
              Image(image: const AssetImage('assets/Book_Inside.png'), 
                width: screenWidth / 2, 
                height: screenWidth / 2 * 1.2525,
                alignment: Alignment.center,
              )
            ),
            // Logo Text Effect
			Positioned(left: screenWidth * 0.5 - 55, top: bookInsideTween.value.value + screenWidth / 5, child: const Text(
              "Searching", 
              style: TextStyle(fontSize: 20, fontFamily: 'Times New Roman', color: Color.fromRGBO(61, 61, 61, 1)), 
              softWrap: true,
              textAlign: TextAlign.center,
            )),
            
          ]);
        }
      ),
      // App Logo Cover
      ListenableBuilder(listenable: bookTween, builder: (context, w){
        return AnimatedBuilder(animation: bookTween.controller, builder: (context, child){
          return Positioned(
            left: bookTween.state == 0 ? bookTween.value.value : screenWidth * 0.25, 
            top: bookTween.state == 1 ? bookTween.value.value : screenHeight * 0.5 - screenWidth / 4.4 * 1.3198 + screenWidth/40,child: 
            FlipCard( key: coverKey,
              front: Image(image: const AssetImage('assets/Book_Cover.png'), 
                width: screenWidth / 2.2, 
                height: screenWidth / 2.2 * 1.3198,
                alignment: Alignment.center,
              ),
              back: Image(image: const AssetImage('assets/Book_Cover_Blank.png'), 
                width: screenWidth / 2.2, 
                height: screenWidth / 2.2 * 1.3198,
                alignment: Alignment.center,
              ),
              flipOnTouch: false,
            )
          );
        });
      }),
      // SideBar for Menu
      MenuSideBar(tick: this,screenHeight: screenHeight, screenWidth: screenWidth,),
      // User profile Top right
      UserProfile(loginPressed: loginPressed,)
    ]));
  }
}
