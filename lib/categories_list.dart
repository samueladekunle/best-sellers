import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;

import "./config.dart";

class CategoriesList extends StatefulWidget {
  CategoriesList({Key key, this.config}) : super(key: key);
  final Config config;

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  String _base, _key, _message;
  List<Map<String, dynamic>> _categories;
  BuildContext _context;

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> categories = List<Map<String, dynamic>>();
    final String apiUrl = "$_base/names.json?api-key=$_key";

    try {
      final http.Response response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(json.decode(response.body)["results"]);
        categories.addAll(results);
        // Save data to SharedPreferences.
        prefs.setString("categories", json.encode(categories));
      }
    } catch(e) {}

    // If user is offline, try to fetch data from SharedPreferences.
    final String value = prefs.getString("categories");
    if (categories.length == 0 && value != null) {
      _message = "No Internet Connection";
      final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(json.decode(value));
      categories.addAll(results);
    }

    return categories;
  }

  Future<Null> _updateCategories() async {
    if (_categories != null) {
      _message = null;
      setState(() => _categories = null);
    }
    final List<Map<String, dynamic>> categories = await _fetchCategories();
    setState(() => _categories = categories);
    if (_message != null) {
      Scaffold.of(_context).showSnackBar(SnackBar(
        content: Text(_message),
        action: SnackBarAction(
          label: "RETRY",
          onPressed: _updateCategories,
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
    _updateCategories();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    if (_categories == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_categories.length == 0) {
      final String message = "No Internet Connection";
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message),
            RaisedButton(
              child: Text("RETRY"),
              onPressed: _updateCategories,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _updateCategories();
      },
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(color: Colors.black);
        },
        itemCount: _categories.length,
        itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> category = _categories[index];
            return ListTile(title: Text(category["display_name"]));
        },
      ),
    );
  }
}