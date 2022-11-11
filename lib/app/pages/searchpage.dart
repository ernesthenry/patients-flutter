import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spouts_inventory_odoo/app/data/pojo/partners.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> data = [];

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _result;
  List _partners = [];

  void _getPartners() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    if (preference.getString("offlinecontacts") != null) {
      print(preference.getString("offlinecontacts"));
      var cutomerlist = json.decode(preference.getString("offlinecontacts"));
      setState(() {
        for (var i in cutomerlist) {
          if (i["name"].toString().length > 1) {
            _partners.add(
              new Partner(
                  id: i["id"],
                  email: i["email"] is! bool ? i["email"] : "N/A",
                  name: i["name"].toString(),
                  phone: i["phone"] is! bool ? i["phone"] : "N/A",
                  imageUrl: ""),
            );
            data.add(i["name"].toString());
          }
        }
      });
    }
  }

  void initState() {
    super.initState();

    _getPartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await showSearch<String>(
                  context: context,
                  delegate: CustomDelegate(),
                );
                setState(() => _result = result);
              },
              icon: Icon(Icons.search)),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(_result ?? '', style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () async {
                var result = await showSearch<String>(
                  context: context,
                  delegate: CustomDelegate(),
                );
                setState(() => _result = result);
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDelegate extends SearchDelegate<String> {
  // List<String> data = nouns.take(100).toList();
  // List<String> data = [
  //   'cow',
  //   'goat',
  //   'chicken',
  // ];

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: Icon(Icons.chevron_left), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    var listToShow;
    if (query.isNotEmpty)
      listToShow =
          data.where((e) => e.contains(query) && e.startsWith(query)).toList();
    else
      listToShow = data;

    return ListView.builder(
      itemCount: listToShow.length,
      itemBuilder: (_, i) {
        var noun = listToShow[i];
        return ListTile(
          title: Text(noun),
          onTap: () => close(context, noun),
        );
      },
    );
  }
}
