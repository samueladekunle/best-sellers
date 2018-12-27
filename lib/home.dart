import "dart:convert";

import "package:flutter/material.dart";

import "./config.dart";
import "./categories_list.dart";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<Config> _loadConfig() async {
    final String config = await DefaultAssetBundle.of(context).loadString("assets/config/config.json");
    final String base = json.decode(config)["base"];
    final String key = json.decode(config)["key"];
    return Config(base: base, key: key);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The New York Times Best Sellers"),
      ),
      body: FutureBuilder(
        future: _loadConfig(),
        builder: (BuildContext context, AsyncSnapshot<Config> snapshot) {
          if (snapshot.hasData) {
            return CategoriesList(
              config: snapshot.data,
            );
          }

          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}