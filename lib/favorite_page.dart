// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Flutter default package
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Loading effect for search
import 'package:firebase_database/firebase_database.dart';

import 'book_card.dart';
import 'book_shelf.dart';
import 'search_bar.dart';
import 'userprofile_value.dart';



class FavoritePage extends StatelessWidget {
  final Future<DataSnapshot>? bookSnap;
  const FavoritePage({super.key, this.bookSnap});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Stack(
        children: <Widget>[
          _FavoritePage(bookSnap),
        ]
      )
    );
  }
}

class _FavoritePage extends StatefulWidget {
  final Future<DataSnapshot>? bookSnap;
  const _FavoritePage(this.bookSnap);
  @override
  State<StatefulWidget> createState() => FavoritePageState();
}

class FavoritePageState extends State<_FavoritePage> {
  UserCredential? user = UserProfileClass.getValue();
  late Future<List<Map>> books;

  Future<Map> getBook(String input) async {
    // Get Web API from OpenLibrary
    input = input == "" ? "Default" : input;
    List<String> inputSplit = input.split('-');
    String searchUrl = 'https://openlibrary.org/search.json?title=${inputSplit[0].split(' ').join('+')}&author=${inputSplit[1].split(' ').join('+')}';
    final searchResult = await fetchAlbum(searchUrl); // Get Book information
    return searchResult['docs'][0];
  }
  Future<List<Map>> convertBookInfo(Future<DataSnapshot> snapshot) async {
    List<Map> bookInformationList = [];
    DataSnapshot data = await snapshot;
    Map<Object?, Object?> titles = data.value as Map<Object?, Object?>;
    for (Object? key in titles.keys){
      if (key == "nothing" && titles[key] == "") continue; // Skip initializer element
      String title = key as String;
      Map bookInfo = await getBook(title);
      bookInformationList.add(bookInfo);
    }
    return bookInformationList;
  }
  @override
  void initState(){
    super.initState();
    String? username = UserProfileClass.getUserName();
    if (username == null) return;
    Future<DataSnapshot> favoritesSnap = widget.bookSnap ?? FirebaseDatabase.instance.ref().child("users/$username/favorites").get();
    books = convertBookInfo(favoritesSnap);
  }
  @override
  Widget build(BuildContext context){
    if (user == null){
      return const Center(
        child: Column(
          children: [
            Expanded(flex: 40, child: Text("")),
            Expanded(flex: 60,child: Text("Please sign in to see favorites", style: TextStyle(fontSize: 25))),
          ],
        )
      );
    } else {
      return FutureBuilder<List<Map>>(
        future: books,
        builder: (context, snapshot){
          List<Map>? listOfBooks = snapshot.data;
          if (listOfBooks != null){
            List<BookCard> bookCardList = [];
            for (Map bookInfo in listOfBooks){
              int coverId = bookInfo["cover_i"] ?? 0000; // Get cover picture
              String coverPicUrl = "https://covers.openlibrary.org/b/id/$coverId-M.jpg"; // Websearch for book information
              bookCardList.add(
                BookCard(
                  coverPic: Image.network(coverPicUrl,fit: BoxFit.cover),
                  size: const Size(100,100),
                  bookInfo: bookInfo
                )
              );
            }
            // UI for bookshelf
            return BookShelf(
              books: bookCardList, 
              size: const Size(4.0,3.0)
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.blue, size: 100)
            );
          }
        }
      );
    }
  }
}