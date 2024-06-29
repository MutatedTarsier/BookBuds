import 'package:flutter/material.dart';

class TweenAnimation <T> with ChangeNotifier{
  TweenAnimation<T>? previous;
  late AnimationController controller;
  late Animation<T> value;
  int state = 0;

  TweenAnimation(vsync, duration, begin, end){
    controller = AnimationController(duration: Duration(milliseconds: duration), vsync: vsync);
    value = Tween<T>(begin: begin, end: end).animate(CurvedAnimation(
      parent: controller, 
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)
    ));
  }

  TweenAnimation.setWith(AnimationController controller2, Animation<T> value2){
    controller = controller2;
    value = value2;
  }

  void makeNew(vsync, duration, begin, end, newState){
    previous = TweenAnimation.setWith(this.controller, this.value);
    controller = AnimationController(duration: Duration(milliseconds: duration), vsync: vsync);
    value = Tween<T>(begin: begin, end: end).animate(CurvedAnimation(
      parent: controller, 
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)
    ));
    state = newState;
    notifyListeners();
  }

  void usePrevious(){
    controller = previous?.controller ?? controller;
    value = previous?.value ?? value;
    state = previous?.state ?? state;
  
    notifyListeners();
  }
}