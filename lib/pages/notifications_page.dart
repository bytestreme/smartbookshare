import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:scoped_model/scoped_model.dart';

class NotificationsPage extends StatefulWidget {
  MainModel model;

  NotificationsPage(this.model);

  Firestore firestore = Firestore.instance;
  bool isLoading = false;

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    setState(() {
      widget.isLoading = true;
    });
    widget.model.fetchRequests().then((v) {
      widget.model.fetchReturnRequests().then((s) {
        if (mounted) {
          setState(() {
            widget.isLoading = false;
          });
        }
      });
    });
    super.initState();
  }

  Widget _buildReturnRequest(Map<String, String> request) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Card(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      child: Container(
                        color: Color(0xFF464547),
                        child: FadeInImage(
                            width: 70,
                            height: 100,
                            placeholder: AssetImage('assets/loadingbook.png'),
                            image: AssetImage('assets/cleancode.jpg')),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(
                        "Запрос от пользователя ${request['currentUserName']} на возврат"),
                  ),
                  Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            widget.isLoading = true;
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: widget.isLoading
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(
                                                      "Возврат книги ${request['bookName']} в вашу библиотеку",
                                                      textAlign:
                                                          TextAlign.center,
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
                                              : Text(
                                                  "Книга успешно возвращена"),
                                        ),
                                      )
                                    ],
                                  ),
                                  onWillPop: () {}));
                          widget.model.acceptReturnRequest(request).then((vd) {
                            setState(() {
                              widget.isLoading = false;
                              Future.delayed(
                                      const Duration(seconds: 3), () => "3")
                                  .then((s) {
                                Navigator.of(context).pop();
                              });
                            });
                          });
                        },
                        child: Text(
                          "Подтвердить",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(0xFF39c2d7),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequest(Map<String, String> request) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Card(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      child: Container(
                        color: Color(0xFF464547),
                        child: FadeInImage(
                            width: 70,
                            height: 100,
                            placeholder: AssetImage('assets/loadingbook.png'),
                            image: AssetImage('assets/cleancode.jpg')),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text("Запрос на книгу ${request['bookName']}"),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child:
                        Text("От пользователя ${request['newHolderUserName']}"),
                  ),
                  Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            widget.isLoading = true;
                          });
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => WillPopScope(
                                  child: SimpleDialog(
                                    key: Key("ACCEPTING"),
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: widget.isLoading
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(
                                                      "Передача книги пользователю\n${request['newHolderUserName']}",
                                                      textAlign:
                                                          TextAlign.center,
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
                                              : Text("Книга успешно передана"),
                                        ),
                                      )
                                    ],
                                  ),
                                  onWillPop: () {}));
                          widget.model.acceptRequest(request).then((vd) {
                            setState(() {
                              widget.isLoading = false;
                              Future.delayed(
                                      const Duration(seconds: 3), () => "3")
                                  .then((s) {
                                Navigator.of(context).pop();
                              });
                            });
                          });
                        },
                        child: Text(
                          "Принять",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(0xFF39c2d7),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            widget.isLoading = true;
                          });
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => WillPopScope(
                                  child: SimpleDialog(
                                    key: Key("ACCEPTING"),
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: widget.isLoading
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(
                                                      "Отклонение запроса пользователя\n${request['newHolderUserName']}",
                                                      textAlign:
                                                          TextAlign.center,
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
                                              : Text("Запрос отклонен"),
                                        ),
                                      )
                                    ],
                                  ),
                                  onWillPop: () {}));
                          widget.model.acceptRequest(request).then((vd) {
                            setState(() {
                              widget.isLoading = false;
                              Future.delayed(
                                      const Duration(seconds: 3), () => "3")
                                  .then((s) {
                                Navigator.of(context).pop();
                              });
                            });
                          });
                        },
                        child: Text(
                          "Отклонить",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(0xFF8e244d),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBorrowRequests() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Center(
          child: widget.isLoading
              ? JumpingDotsProgressIndicator(
                  numberOfDots: 5,
                  fontSize: 26,
                )
              : (model.requests.length == 0
                  ? Text("Новых запросов пока нет")
                  : (ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildRequest(model.requests[index]);
                      },
                      itemCount: model.requests.length,
                    ))),
        );
      },
    );
  }

  Widget _buildReturnRequests() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Center(
          child: widget.isLoading
              ? JumpingDotsProgressIndicator(
                  numberOfDots: 5,
                  fontSize: 26,
                )
              : (model.returnRequests.length == 0
                  ? Text("Новых запросов за возврат пока нет")
                  : (ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildReturnRequest(model.returnRequests[index]);
                      },
                      itemCount: model.returnRequests.length,
                    ))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
            child: Material(
              elevation: 8,
              child: Container(
                color: Color(0xFF464547),
                child: TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.arrow_upward),
                      text: "Запросы на книгу",
                    ),
                    Tab(
                      icon: Icon(Icons.arrow_downward),
                      text: "Запросы на возврат",
                    ),
                  ],
                  unselectedLabelColor: Colors.white,
                  indicatorColor: Color(0xFF39c2d7),
                  labelColor: Color(0xFF39c2d7),
                  labelStyle: TextStyle(color: Colors.white, inherit: false),
                  unselectedLabelStyle:
                      TextStyle(color: Colors.white, inherit: false),
                  indicator: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.1)),
                ),
              ),
            ),
            preferredSize: Size(MediaQuery.of(context).size.width, 75)),
        body: Container(
          child: TabBarView(
              children: [_buildBorrowRequests(), _buildReturnRequests()]),
        ),
      ),
    );
  }
}
