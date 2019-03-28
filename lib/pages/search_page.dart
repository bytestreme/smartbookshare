import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  List<Item> books = List();
  Item item;
  DatabaseReference itemRef;
  TextEditingController controller = new TextEditingController();
  String filter = '';
  FocusNode searchFn = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "", "", "", "");
    final FirebaseDatabase database =
        FirebaseDatabase(databaseURL: 'https://hack-btsd.firebaseio.com/');
    itemRef = database.reference().child('books');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
    controller.addListener(() {
      if (mounted) {
        setState(() {
          filter = controller.text;
        });
      }
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      books.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = books.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      books[books.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF464547),
            leading: Icon(Icons.search),
            title: TextField(
              focusNode: searchFn,
              decoration: new InputDecoration(
                  labelText: "Название, автор, описание...",
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white)),
              controller: controller,
            ),
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                child: FirebaseAnimatedList(
                  query: itemRef,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    if (filter != null) {
                      return books[index].title.contains(filter) ||
                              books[index].author.contains(filter) ||
                              books[index].description.contains(filter)
                          ? ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed('/book/' + books[index].key);
                              },
                              leading: Icon(Icons.search),
                              title: Text(
                                  '${books[index].title} (${books[index].releaseDate}) ${books[index].author}'),
                              subtitle: Text(
                                books[index].description,
                                maxLines: 3,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : new Container();
                    } else {
                      return Container(
                        child: Text("NOSOSOS"),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
        onWillPop: () {
          FocusScope.of(context).requestFocus(FocusNode());
        });
  }
}

class Item {
  String key;
  String description;
  String title;
  String ownerUserId;
  String releaseDate;
  String author;

  Item(this.description, this.title, this.ownerUserId, this.releaseDate,
      this.author);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        releaseDate = snapshot.value['releaseDate'],
        description = snapshot.value['description'],
        title = snapshot.value['title'],
        ownerUserId = snapshot.value['ownerUserId'],
        author = snapshot.value['author'];

  toJson() {
    return {
      "releaseDate": releaseDate,
      "description": description,
      "title": title,
      "ownerUserId": ownerUserId,
      "author": author
    };
  }
}
