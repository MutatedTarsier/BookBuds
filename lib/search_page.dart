// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart'; // Flutter default package
import 'book_card.dart';
import 'book_shelf.dart';


class SearchPage extends StatelessWidget {
  final Map bookMap;
  const SearchPage({super.key, required this.bookMap});
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      ),
      body: Stack(
        children: <Widget>[
          _SearchPage(bookMap),
        ]
      )
    );
  }
}

class _SearchPage extends StatefulWidget {
  final Map bookMap;
  const _SearchPage(this.bookMap);
  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<_SearchPage> {
  @override
  Widget build(BuildContext context){
    Map? books = widget.bookMap;
    List<BookCard> bookCardList = [];
    for (Map bookInfo in books['docs']){
      String coverId = bookInfo["cover_edition_key"] ?? ""; // Get cover picture
      String coverPicUrl = "https://covers.openlibrary.org/b/olid/$coverId-M.jpg"; // Websearch for book information
      if (coverId == "") continue; // Skip books without author
      bookCardList.add(
        BookCard(
          coverPic: coverId != "" ? Image.network(coverPicUrl, fit: BoxFit.cover) : Image.asset('assets/NA.png', fit: BoxFit.cover),
          size: const Size(100,100),
          bookInfo: bookInfo,
        )
      );
    }
    // UI for bookshelf
    return Center(
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          height: 40.0,
          color: Colors.blueGrey,
          child: Container(margin: const EdgeInsets.all(0),
            child: const FittedBox(child: Text("Results found using Open Library API", style: TextStyle(color: Colors.white)))
          ),
        ),
        body: ListView(
          children: [
            Expanded(flex: 90,
              child: BookShelf(
                books: bookCardList, 
                size: const Size(4.0,14.0) // 4 x 7 grid (row, column)
              ),
            ),
          ]
        )
      ),
    );
  }
}