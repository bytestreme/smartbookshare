import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/scoped-models/main.dart';

class FeedBackPage extends StatefulWidget {
  MainModel model;
  String bookId;
  String bookName;

  FeedBackPage(this.bookId, this.bookName, this.model);

  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text("Отзывы к книге ${widget.bookName}"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('feedback').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("loading");
          return ListView.builder(
            itemBuilder: (context, index) {
              return snapshot.data.documents[index]['bookId'] != widget.bookId
                  ? Container()
                  : Material(
                      child: Column(
                        children: <Widget>[
                          FadeInImage(
                            placeholder: AssetImage('assets/noavatar.png'),
                            image: AssetImage('assets/noavatar.png'),
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                          ),
                          Text(snapshot.data.documents[index]['text'])
                        ],
                      ),
                    );
            },
            itemCount: snapshot.data.documents.length,
          );
        },
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 270,),
        IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController _ctrl = TextEditingController();
                    return Container(
                      child: SimpleDialog(
                        children: <Widget>[
                          TextField(
                            controller: _ctrl,
                          ),
                          IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              Firestore.instance.collection('feedback').add({
                                "userId": widget.model.getUser.id,
                                "text": _ctrl.text,
                                "bookId": widget.bookId,
                              }).then((ds) {
                                Navigator.pop(context);
                              });
                            },
                          )
                        ],
                        title: new Text("Добавить отзыв"),
                      ),
                    );
                  });
            })
      ],
    );
  }
}
