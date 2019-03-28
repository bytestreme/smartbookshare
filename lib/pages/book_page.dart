import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/book_model.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:share/share.dart';

import 'feedback_page.dart';

class BookPage extends StatefulWidget {
  var firestore = Firestore.instance;
  bool like = false;
  bool bookmark = false;
  String bookId;
  MainModel model;

  BookPage(this.bookId, this.model);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  BookModel book = null;
  String title = "";
  String author = "";
  String date = "";
  String imageUrl = "";
  String description = "";
  String ownerUserId = "";
  String ownerUserName = "";
  String currentUserId = "";
  String currentUserName = "";
  bool isRequested = false;
  bool isOwner = true;
  bool isCurrent = true;
  DocumentSnapshot requestSnapshot = null;
  Widget button = Container();
  bool available = false;
  bool isLoading = true;
  String publisher = '';
  String isbn = '';
  @override
  void initState() {
    widget.firestore
        .collection('books')
        .document(widget.bookId)
        .get()
        .then((ds) {
      title = ds['title'];
      author = ds['author'];
      date = ds['releaseDate'];
      description = ds['description'];
      available = ds['available'];
      currentUserId = ds['currentUserId'];
      ownerUserId = ds['ownerUserId'];
      publisher = ds['publisher'];
      isbn = ds['isbn'];
      imageUrl = ds['imageUrl'];

      widget.firestore
          .collection('userIdList')
          .document(ds['ownerUserId'])
          .get()
          .then((owner) {
        ownerUserName = owner.data['name'].toString();

        widget.firestore
            .collection('userIdList')
            .document(ds['currentUserId'])
            .get()
            .then((curr) {
          currentUserName = curr.data['name'].toString();
          widget.model.getBookRequests(widget.bookId).then((qs) {
            requestSnapshot = qs.documents.firstWhere(
                (DocumentSnapshot ds) =>
                    ds.data['newHolderUserId'] == widget.model.getUser.id,
                orElse: () => null);
            isRequested = requestSnapshot != null;
            isOwner = widget.model.getUser.id == ownerUserId;
            isCurrent = widget.model.getUser.id == currentUserId;
            print('$isOwner $isCurrent $isRequested');
            if (isOwner && !isCurrent) {
              print(89);
              button = RaisedButton(
                color: Color(0xFF464547),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => WillPopScope(
                          child: SimpleDialog(
                            key: Key("GETMYBOOK!"),
                            children: <Widget>[
                              Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: isLoading
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              "Отправка запроса вернуть книгу",
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            JumpingDotsProgressIndicator(
                                              color: Color(0xFF464547),
                                              numberOfDots: 5,
                                              fontSize: 40,
                                            )
                                          ],
                                        )
                                      : Text("Запрос отправлен"),
                                ),
                              )
                            ],
                          ),
                          onWillPop: () {}));
                  widget.model
                      .notifyToReturn(
                          widget.bookId, currentUserId, title, ownerUserName)
                      .then((_) {
                    setState(() {
                      isLoading = false;
                      Future.delayed(const Duration(seconds: 3), () => "3")
                          .then((s) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                    });
                  });
                },
                child: Text(
                  "Запросить возврат",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (isOwner && isCurrent) {
              print(99);
              button = RaisedButton(
                color: Color(0xFF464547),
                onPressed: null,
                child: Text("Ваша книга у вас",
                    style: TextStyle(color: Colors.white)),
              );
            } else if (!isOwner && isCurrent && !isRequested) {
              print(106);
              button = RaisedButton(
                color: Color(0xFF464547),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => WillPopScope(
                          child: SimpleDialog(
                            key: Key("RETURNING"),
                            children: <Widget>[
                              Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: isLoading
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              "Отправка запроса на возврат книги\n$title",
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            JumpingDotsProgressIndicator(
                                              color: Color(0xFF464547),
                                              numberOfDots: 5,
                                              fontSize: 40,
                                            )
                                          ],
                                        )
                                      : Text("Запрос отправлен"),
                                ),
                              )
                            ],
                          ),
                          onWillPop: () {}));
                  widget.model
                      .sendReturnRequest(
                          widget.bookId, widget.model.getUser.id, ownerUserId)
                      .then((_) {
                    setState(() {
                      isLoading = false;
                      Future.delayed(const Duration(seconds: 3), () => "3")
                          .then((s) {
                        Navigator.of(context).pop();
                      });
                    });
                  });
                },
                child: Text(
                  "Вернуть владельцу",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!isOwner && !isCurrent && !isRequested) {
              print(113);
              button = RaisedButton(
                color: Color(0xFF464547),
                onPressed: currentUserId == ownerUserId
                    ? () {
                        setState(() {
                          isLoading = true;
                        });
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => WillPopScope(
                                child: SimpleDialog(
                                  key: Key("REQUESITNG"),
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: isLoading
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Text(
                                                    "Отправка запроса пользователю\n$ownerUserName",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  JumpingDotsProgressIndicator(
                                                    color: Color(0xFF464547),
                                                    numberOfDots: 5,
                                                    fontSize: 40,
                                                  )
                                                ],
                                              )
                                            : Text("Запрос отправлен"),
                                      ),
                                    )
                                  ],
                                ),
                                onWillPop: () {}));
                        widget.model
                            .sendBookRequest(widget.bookId,
                                widget.model.getUser.id, ownerUserId)
                            .then((_) {
                          setState(() {
                            isLoading = false;
                            Future.delayed(
                                    const Duration(seconds: 3), () => "3")
                                .then((s) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            });
                          });
                        });
                      }
                    : null,
                child: Text(
                  "Запросить книгу",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            } else if (!isOwner && !isCurrent && isRequested) {
              print(120);
              button = RaisedButton(
                color: Color(0xFF464547),
                onPressed: null,
                child: Text(
                  "Запрошено",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              throw Exception("HUILO!!");
            }
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          });
        });
      });
    });
    super.initState();
  }

  Widget _buildBody() {
    return Padding(
        padding: EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            Container(
                              color: Color(0xFF464547),
                              child: FadeInImage(
                                fit: BoxFit.fill,
                                  height: 250,
                                  width: 175,
                                  placeholder:
                                      AssetImage('assets/loadingbook.png'),
                                  image: imageUrl != null ? NetworkImage(imageUrl) : AssetImage('assets/loadingbook.png')),
                            ),
                            Container(
                              width: 175,
                              margin: EdgeInsets.only(bottom: 5),
                              height: 17,
                              child: Text(
                                available
                                    ? "Книга доступна"
                                    : "Книга недоступна",
                                style: TextStyle(
                                    color: available
                                        ? Colors.green
                                        : Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 350,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Column(

                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[

                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 190,
                            child: Text(
                              "Автор:\n$author",
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 190,
                            child: Text(
                              "Год издания:\n$date",
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 190,
                            child: Text(
                              "Издатель:\n$publisher",
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 190,
                            child: Text(
                              "ISBN:\n$isbn",
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 190,
                            child: Text(
                              "Владелец книги:\n$ownerUserName ${ownerUserId == widget.model.getUser.id ? "(вы)" : ""}",
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 190,
                            child: Text(
                              "Текущий владелец:\n$currentUserName",
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          button,
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: isLoading
          ? null
          : AppBar(
              centerTitle: false,
              leading: null,
              automaticallyImplyLeading: false,
              title: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 22),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Color(0xFF464547),
              elevation: 8,
            ),
      persistentFooterButtons: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              tooltip: "Назад",
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.navigate_before),
            ),
            IconButton(
              tooltip: "Комментарии",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FeedBackPage(widget.bookId, title, widget.model)),
                );
              },
              icon: Icon(Icons.comment),
            ),
            IconButton(
              tooltip: "В закладки",
              onPressed: () {
                setState(() {
                  widget.bookmark = !widget.bookmark;
                });
              },
              icon: Icon(
                widget.bookmark ? Icons.bookmark : Icons.bookmark_border,
                color: widget.bookmark ? Color(0xFF464547) : Colors.black,
              ),
            ),
            IconButton(
              tooltip: "В избранное",
              icon: Icon(
                widget.like ? Icons.star : Icons.star_border,
                color: widget.like ? Color(0xFF39c2d7) : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  widget.like = !widget.like;
                });
              },
            ),
            Text("1"),
            IconButton(
              tooltip: "Поделиться",
              onPressed: () {
                Share.share(
                    'Советую прочитать книгу "$title" в приложении SmartBookshare http://smartbookshare.com/book/${widget.bookId}');
              },
              icon: Icon(Icons.share),
            ),
            SizedBox(
              width: 95,
            ),
            ownerUserId == widget.model.getUser.id
                ? IconButton(
                    tooltip: "Редактировать",
                    onPressed: () {},
                    icon: Icon(Icons.mode_edit),
                  )
                : Container(),
          ],
        )
      ],
      body: isLoading
          ? Center(
              child: JumpingDotsProgressIndicator(
                fontSize: 26,
                numberOfDots: 5,
              ),
            )
          : _buildBody(),
    );
  }
}
