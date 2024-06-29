
import 'package:firebase_auth/firebase_auth.dart';
class UserProfileClass {
  static UserCredential? value;
  static void setValue(UserCredential? user){
    value = user;
  }
  static UserCredential? getValue(){
    return value;
  }
  static String? getUserName(){
    return value?.user?.email?.replaceAll(RegExp('\\W'),"");
  }
}