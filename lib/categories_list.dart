import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;

import "./model/config.dart";
import "./model/categories_list_item.dart";

class CategoriesList extends StatefulWidget {
  CategoriesList({Key key, this.config}) : super(key: key);
  final Config config;

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  String _base, _key, _message;
  List<CategoriesListItem> _items;
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

  Future<Null> _updateItems() async {
    List<CategoriesListItem> items = List<CategoriesListItem>();
    if (_items != null) {
      _message = null;
      setState(() => _items = null);
    }
    final List<Map<String, dynamic>> categories = await _fetchCategories();
    print("categories.length: ${categories.length}");
    if (categories.length > 0) {
      items = categories.map((Map<String, dynamic> category) {
        return CategoriesListItem(
          displayName: category["display_name"],
          listNameEncoded: category["list_name_encoded"],
          isExpanded: false,
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
    _updateItems();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    if (_items == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_items.length == 0) {
      final String message = "No Internet Connection";
      return Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _updateItems();
      },
      child: ListView(
        children: [
          ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() => _items[index].isExpanded = !_items[index].isExpanded);
            },
            children: _items.map((CategoriesListItem item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(item.displayName),
                  );
                },
                body: Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                isExpanded: item.isExpanded,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}