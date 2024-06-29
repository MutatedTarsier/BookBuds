// ignore: file_names
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PaddedList extends StatelessWidget{
  List<Widget> paddedArray = List<Widget>.empty(growable: true);
  PaddedList({super.key, EdgeInsets padding = const EdgeInsets.fromLTRB(0,0,0,0), List<Widget> children = const <Widget>[]}){
    for (int i = 0; i < children.length - 1; i++){ // Loop through children to add into new array, except last element
      paddedArray.add(children[i]);
      paddedArray.add(Padding(padding: padding));
    }
    paddedArray.add(children[children.length - 1]); // Add last element without padding
  }
  @override
  Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.center ,children: paddedArray);
  }
}