import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: new FlutterStream(),
    );
  }
}

class FlutterStream extends StatelessWidget {
  const FlutterStream({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("saved").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        List<DocumentSnapshot> documents = snapshot.data.documents;

        final List<WordPair> saved = documents.map((doc) => WordPair(doc['word1'], doc['word2'])).toList();

        final keys = documents.map((doc) => doc.documentID).toList();

        return RandomWords(saved, keys);
//        return _buildList(context, snapshot.data.documents);
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  List<WordPair> saved;
  List<String> keys;

  RandomWords(this.saved, this.keys);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final wordSuggestions = <WordPair>[];
//  final saved = Set<WordPair>();
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
//    wordSuggestions.addAll(widget.saved);
    add10NewSuggestions();
  }

  void add10NewSuggestions() {
    for (int i = 0; i < 10; ++i) {
      wordSuggestions.add(WordPair.random());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Flutter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return buildSelectedListPage();
                  }
                )
              );
            },
          )
        ],
      ),
      body: Center(
        child: buildListView(),
      ),
    );
  }

  Widget buildSelectedListPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved names")
      ),
      body: ListView(
        children: widget.saved.map((wordPair) => ListTile(title: Text(wordPair.asPascalCase),)).toList(),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
    itemBuilder: (BuildContext context, int i) {
      if (i.isOdd) {
        return Divider();
      }
      int index = i ~/ 2;
      while (index >= wordSuggestions.length) {
        add10NewSuggestions();
      }
      final wordPair = wordSuggestions[index];

      final alreadySaved = widget.saved.contains(wordPair);

      return ListTile(
        title: Text(
          "hello ${wordPair.asPascalCase}",
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
          if (alreadySaved) {
            setState(() {
              String key = widget.keys[widget.saved.indexOf(wordPair)];
              Firestore.instance.collection("saved").document(key).delete();

//              saved.remove(wordPair);
            });
          } else {
            setState(() {
//              saved.add(wordPair);
              Firestore.instance.collection("saved").add({
                'word1': wordPair.first,
                'word2': wordPair.second,
              });
            });
          }
        },
      );
    }
  );
  }
}
