import 'package:book_buds/book_card_page.dart';
import 'package:flutter/material.dart'; // Flutter default package

class BookCard extends StatefulWidget{
  final Image coverPic;
  final Size size;
  final Map bookInfo;
  const BookCard({super.key, required this.coverPic, required this.size, required this.bookInfo});

 @override
  State<StatefulWidget> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  void _onPressed(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookInfoPage(bookCover: widget.coverPic, bookInfo: widget.bookInfo,)));
  }
  @override
  Widget build(BuildContext context){
    return SizedBox(height: widget.size.height, width: widget.size.width, 
      child:FittedBox(clipBehavior: Clip.hardEdge,child: IconButton(
        icon: widget.coverPic,
        onPressed: _onPressed
      ))
    );
  }
}