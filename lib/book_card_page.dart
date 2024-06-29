// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart'; // Flutter default package
import 'userprofile_value.dart';
import 'package:firebase_database/firebase_database.dart';

class BookInfoPage extends StatelessWidget {
  final Map bookInfo;
  final Image bookCover;
  const BookInfoPage({super.key, required this.bookInfo, required this.bookCover});
  
  @override
  Widget build(BuildContext context){
    return _BookInfoPage(bookInfo, bookCover);
  }
}

class _BookInfoPage extends StatefulWidget {
  final Map bookInfo;
  final Image bookCover;
  const _BookInfoPage(this.bookInfo, this.bookCover);
  @override
  State<StatefulWidget> createState() => BookInfoPageState();
}

class BookInfoPageState extends State<_BookInfoPage> {
  IconData favoriteIcon = Icons.star_border_rounded;
  String? username = UserProfileClass.getUserName();
  void _pressed(){
    if (username == null) return; // Do nothing if not logged in
    // Database connection
    DatabaseReference favRef = FirebaseDatabase.instance.ref().child("users/$username/favorites");
    Future<DataSnapshot> favoritesSnap = FirebaseDatabase.instance.ref().child("users/$username/favorites").get();
    // Check for favorite toggle
    if (favoriteIcon == Icons.star_border_rounded){ // Book Favorited
      setState(() => favoriteIcon = Icons.star_rounded); // Change icon UI
      favoritesSnap.then((snapshot){ // Fetch Favorites and add title
        if (snapshot.value != null){
          Map<Object?, Object?> titles = snapshot.value as Map<Object?, Object?>;
          titles[widget.bookInfo['title'].replaceAll(RegExp('\\W')," ") + '-' + (widget.bookInfo['author_name'] != null ? widget.bookInfo['author_name'][0].replaceAll(RegExp('\\W')," ") : "None")] = "";
          favRef.update(titles.cast<String, Object?>()); // Update List
        }
      });
    } else { // Unfavorited book
      // Removes title from database
      setState(() => favoriteIcon = Icons.star_border_rounded);
      favoritesSnap.then((snapshot){
        if (snapshot.value != null){
          Map<Object?, Object?> titles = snapshot.value as Map<Object?, Object?>; // Get map from database
          titles.removeWhere((key, value) => key == widget.bookInfo['title'].replaceAll(RegExp('\\W')," ") + '-' + (widget.bookInfo['author_name'] != null ? widget.bookInfo['author_name'][0].replaceAll(RegExp('\\W')," ") : "None")); // Delete title from map
          favRef.set(titles.cast<String, Object?>()); // Update list
        }
      });
    }
  }
  @override
  void initState(){ // Check if already favorited on click
    super.initState();
    Future<DataSnapshot> favoritesSnap = FirebaseDatabase.instance.ref().child("users/$username/favorites").get();
    favoritesSnap.then((snapshot){
      if (snapshot.value != null){
        Map<Object?, Object?> titles = snapshot.value as Map<Object?, Object?>;
        titles.forEach((k, v){
          String title = k as String;
          if (title == widget.bookInfo['title'].replaceAll(RegExp('\\W')," ") + '-' + (widget.bookInfo['author_name'] != null ? widget.bookInfo['author_name'][0].replaceAll(RegExp('\\W')," ") : "None")){
            setState(() => favoriteIcon = Icons.star_rounded);
          }
        });
      }
    });
  }
  @override
  Widget build(BuildContext context){
    const Color infoBackground = Colors.brown;
    const Color textColor = Colors.white;
    const String font = "Garamond";
    String title = widget.bookInfo['title'] ?? "None";
    if (title.length > 20){
      title = title.substring(0,20);
    }
    return Scaffold(appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(flex: 40, 
              child: FittedBox(fit: BoxFit.cover, child: widget.bookCover)
            ),
            Expanded(flex: 60, 
              child: Container(margin: const EdgeInsets.fromLTRB(10,20,10,20), clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.black, width: 2),
                  color: infoBackground
                ),
                child: FittedBox(fit: BoxFit.fitHeight, alignment: Alignment.topLeft,
                  child: Container(margin: const EdgeInsets.all(10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(text: TextSpan(style: const TextStyle(fontSize: 22.0, color: textColor, fontFamily: font),
                              children:[
                                const TextSpan(text: "Title: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: title)
                              ]
                            )),
                            RichText(text: TextSpan(style: const TextStyle(fontSize: 22.0, color: textColor, fontFamily: font),
                              children:[
                                const TextSpan(text: "Author: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.bookInfo['author_name'] != null ? widget.bookInfo['author_name'][0] : "None")
                              ]
                            )),
                            const Padding(padding: EdgeInsets.all(10)),
                            RichText(text: TextSpan(style: const TextStyle(fontSize: 22.0, color: textColor, fontFamily: font),
                              children:[
                                const TextSpan(text: "Published: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.bookInfo['publish_year'] != null ? widget.bookInfo['publish_year'][0].toString() : "None")
                              ]
                            )),
                            RichText(text: TextSpan(style: const TextStyle(fontSize: 22.0, color: textColor, fontFamily: font),
                              children:[
                                const TextSpan(text: "Page numbers: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.bookInfo['number_of_pages_median'] != null ? widget.bookInfo['number_of_pages_median'].toString() : "None")
                              ]
                            )),
                            const Padding(padding: EdgeInsets.all(10)),
                            RichText(text: TextSpan(style: const TextStyle(fontSize: 22.0, color: textColor, fontFamily: font),
                              children:[
                                const TextSpan(text: "ISBN ID: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.bookInfo['isbn'] != null ? widget.bookInfo['isbn'][0] : "None")
                              ]
                            )),
                            RichText(text: TextSpan(style: const TextStyle(fontSize: 22.0, color: textColor, fontFamily: font),
                              children:[
                                const TextSpan(text: "eBook Access: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.bookInfo['ebook_access'] ?? "None")
                              ]
                            )),

                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(10)),
                        IconButton(
                          onPressed: _pressed,
                          icon: Icon(
                            favoriteIcon, 
                            size: 100, 
                            color: const Color.fromRGBO(255, 253, 150, 1)
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ),
          ],
        ),
      )
    );
  }
}