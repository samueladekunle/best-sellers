import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;

import "./model/config.dart";
import "./books_list_item.dart";

class BooksList extends StatefulWidget {
  BooksList({Key key, this.listNameEncoded, this.config}) : super(key:key);
  final String listNameEncoded;
  final Config config;

  _BooksListState createState() => _BooksListState();
}

class _BooksListState extends State<BooksList> {
  List<BooksListItem> _items;
  BuildContext _context;
  String _base, _key, _listNameEncoded, _message;

  Future<List<Map<String, dynamic>>> _fetchBooks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> books = List<Map<String, dynamic>>();
    final String apiUrl = "$_base/$_listNameEncoded?api-key=$_key";
    try {
      final http.Response response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(responseBody["results"]["books"]);
        books.addAll(results);
        prefs.setString(_listNameEncoded, json.encode(results));
      }
    } catch (e) {}

    final String value = prefs.getString(_listNameEncoded);
    if (books.length == 0 && value != null) {
      _message = "No Internet Connection";
      final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(json.decode(value));
      books.addAll(results);
    }

    return books;
  }

  Future<Null> _updateItems() async {
    List<BooksListItem> items = List<BooksListItem>();
    if (_items != null) {
      _message = null;
      setState(() => _items = null);
    }
    final List<Map<String, dynamic>> books = await _fetchBooks();
    if (books.length > 0) {
      items = books.map((Map<String, dynamic> book) {
        final String rank = "${book["rank"]}",
                      weeksOnList = "${book["weeks_on_list"]}",
                      title = book["title"],
                      contributor = book["contributor"],
                      bookImage = book["book_image"],
                      description = book["description"];
        final List<dynamic> buyLinks = book["buy_links"];

        return BooksListItem(
          rank: rank,
          weeksOnList: weeksOnList,
          title: title,
          contributor: contributor,
          bookImage: bookImage,
          description: description,
          buyLinks: buyLinks,
        );
      }).toList();
    }
    setState(() => _items = items);
    if (_message != null) {
      Scaffold.of(_context).showSnackBar(SnackBar(
        content: Text(_message),
        action: SnackBarAction(
          label: "RETRY",
          onPressed: _updateItems,
          textColor: Colors.blue[700],
        ),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _base = widget.config.base;
    _key = widget.config.key;
    _listNameEncoded = widget.listNameEncoded;
    _updateItems();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    if (_items == null) {
      return Container(
        height: 200,
        color: Color(0XFFCCCCCC),
        padding: EdgeInsets.all(5.0),
        child: Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_items.length == 0) {
      final String message = "No Internet Connection";
      return Container(
        height: 200,
        color: Color(0XFFCCCCCC),
        padding: EdgeInsets.all(5.0),
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(message),
                RaisedButton(
                  child: Text("RETRY"),
                  onPressed: _updateItems,
                ),
              ],
            ),
          ),
        )
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Container(
          color: Color(0xFFCCCCCC),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _items,
          ),
        ),
      ),
    );
  }
}