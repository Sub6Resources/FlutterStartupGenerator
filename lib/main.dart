import 'dart:async';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];

  final _saved = Set<String>();

  final _biggerFont = const TextStyle(fontSize: 18.0);

  final Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    List<String> _oldData = await _sharedPreferences.then((SharedPreferences prefs) {
      return (prefs.getStringList('_saved')) ?? List<String>();
    });
    setState(() {
      _saved.addAll(_oldData);
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair.asPascalCase);

    return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: IconButton(
          icon: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onPressed: () {
            setState(() {
              if (alreadySaved) {
                _saved.remove(pair.asPascalCase);
              } else {
                _saved.add(pair.asPascalCase);
              }
              _saveSaved();
            });

          }
        ),
    );
  }

  void _saveSaved() async {
    SharedPreferences sharedPreferences = await _sharedPreferences;
    sharedPreferences.setStringList("_saved", _saved.toList());
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
              return ListTile(
                title: Text(
                  pair,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}