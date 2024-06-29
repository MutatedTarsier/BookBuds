import 'package:flutter/material.dart'; // Flutter default package

class BookShelf extends StatefulWidget{
  final List books; // Preferably list of BookCards
  final Size size; // Rows, Columns
  final List? custom;
  const BookShelf({super.key, this.books = const [], required this.size, this.custom});

 @override
  State<StatefulWidget> createState() => _BookState();
}

class _BookState extends State<BookShelf> {
  List<Widget> rows = [];

  @override
  void initState(){
    super.initState();
    List? books = widget.custom ?? widget.books;
    if (books.isEmpty == true) return;
    int maxSize = (widget.size.width * widget.size.height).toInt();
    int numOfBooks = books.length > maxSize ? maxSize : books.length;
    
    for (int i = 0; i < (numOfBooks / widget.size.width).ceil(); i++){
      List<Widget> rowBooks = [];
      for (int j = 0; j < widget.size.width && (i * widget.size.width.toInt() + j) < numOfBooks; j++){
        rowBooks.add(books[(i * widget.size.width.toInt()) + j]);
      }
      rows.add(Row(
        children: rowBooks      
      ));
      rows.add(const Padding(padding: EdgeInsets.all(5)));
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Column(children: rows);
  }
}