import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_app/scoped-models/main.dart';

class FriendDetailsPage extends StatefulWidget {
  final Widget avatarTag = Icon(Icons.ac_unit);

  @override
  _FriendDetailsPageState createState() => new _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.getUser == null
            ? Container()
            : SingleChildScrollView(
                child: new Container(
                  // decoration: linearGradient,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          new Align(
                            alignment: FractionalOffset.bottomCenter,
                            heightFactor: 1.2,
                            child: new Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: new BorderRadius.circular(100),
                                  child: FadeInImage(
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.scaleDown,
                                    image: NetworkImage(model.getUser.image),
                                    placeholder: AssetImage('assets/noavatar.png'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Text('Some facts about me'),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    left: 16.0,
                                    right: 16.0,
                                  ),
                                  child: new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      MaterialButton(
                                        minWidth: 140,
                                        color: Color(0xff39c2d7),
                                        textColor: Colors.black,
                                        onPressed: () {},
                                        child: new Text("Список книг", style: TextStyle(color: Colors.white),),
                                      ),
                                      MaterialButton(
                                        minWidth: 140,
                                        color: Color(0xFF464547),
                                        textColor: Colors.black,
                                        onPressed: () {
                                          if (model.getUser.userType
                                              .startsWith('facebook')) {
                                            model.fbLogout().then((onValue) {
                                              Navigator.of(context)
                                                  .pushReplacementNamed('/');
                                            });
                                          } else if (model.getUser.userType
                                              .startsWith('github')) {
                                            model.ghLogout().then((onValue) {
                                              Navigator.of(context)
                                                  .pushReplacementNamed('/');
                                            });
                                          }
                                        },
                                        child: new Text("Выйти", style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              model.getUser.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .copyWith(color: Colors.black),
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.place,
                                    color: Colors.black,
                                    size: 16.0,
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: new Text(
                                      "widget.friend.location",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.email,
                                    color: Colors.black,
                                    size: 16.0,
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: new Text(
                                      model.getUser.email,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: new Text(
                                'Lorem Ipsum is simply dummy text of the printing and typesetting '
                                    'industry. Lorem Ipsum has been the industry\'s standard dummy '
                                    'text ever since the 1500s.',
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(
                                        color: Colors.black, fontSize: 16.0),
                              ),
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
