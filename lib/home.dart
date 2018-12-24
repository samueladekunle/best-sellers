import "dart:convert";

import "package:flutter/material.dart";

import "./categories_list.dart";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _apiBase, _apiKey;

  Future<Null> _loadConfig() async {
    final String config = await DefaultAssetBundle.of(context).loadString("assets/config/config.json");
    _apiBase = json.decode(config)["base"];
    _apiKey = json.decode(config)["key"];
  }

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The New York Times Best Sellers"),
      ),
      body: CategoriesList(
        apiBase: _apiBase,
        apiKey: _apiKey,
      ),
    );
  }
}