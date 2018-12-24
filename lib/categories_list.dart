import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;

class CategoriesList extends StatefulWidget {
  CategoriesList({Key key, this.apiBase, this.apiKey}) : super(key: key);
  final String apiBase;
  final String apiKey;

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  List<dynamic> _categories;

  Future<Null> _loadCategories({String apiUrl}) async {
    final response = await http.get(apiUrl);
    if (response.statusCode == 200) {
      final categories = json.decode(response.body)["results"];
      setState(() => _categories = categories);
    }
  }

  @override
  void initState() {
    super.initState();
    final String base = widget.apiBase;
    final String key = widget.apiKey;
    final String apiUrl = "$base/names.json?api-key=$key";
    _loadCategories(apiUrl: apiUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (_categories == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_categories[index]["display_name"]),
          );
        },
      );
    }
  }
}