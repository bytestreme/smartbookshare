import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:scoped_model/scoped_model.dart';

class LibraryPage extends StatefulWidget {
  MainModel model;

  LibraryPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _LibraryPageState();
  }
}

class _LibraryPageState extends State<LibraryPage> {
  List<Widget> result = [];

  @override
  void initState() {
    super.initState();
  }

  List<Widget> getItems(model) {
    List<Widget> result = [];
    for (var item in model.myLibrary) {
      result.add(Card(
        child: Text(item.title),
      ));
    }
    return result;
  }

  Widget buildMyBooks() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Сортировать по"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.sort_by_alpha), onPressed: () {}),
          IconButton(icon: Icon(Icons.sort), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () {},
          )
        ],
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          return StreamBuilder(
            stream: model.firestore.collection('books').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return JumpingDotsProgressIndicator(
                  fontSize: 26,
                  numberOfDots: 5,
                );
              return ListView.builder(
                itemBuilder: (context, index) => _buildListItem(
                      context,
                      snapshot.data.documents[index],
                    ),
                itemCount: snapshot.data.documents.length,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext c, DocumentSnapshot ds) {
    if (ds.data['currentUserId'] == ds.data['ownerUserId'] &&
        ds.data['ownerUserId'] == widget.model.getUser.id) {
      return Container();
    }
    if (ds.data['currentUserId'] == widget.model.getUser.id ||
        ds.data['ownerUserId'] == widget.model.getUser.id) {
      print(ds['title']);
      return ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(ds['title']),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
