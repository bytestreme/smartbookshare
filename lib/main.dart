import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/book_add_page.dart';
import 'package:flutter_app/pages/book_page.dart';
import 'package:flutter_app/pages/testprofile/friend_details_page.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth_page.dart';
import './pages/home_page.dart';
import './scoped-models/main.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    print('building main page');
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: new ThemeData(
          primaryColor: Color(0xFF464547), //Changing this will change the color of the TabBar
          textTheme: TextTheme(
              body1: TextStyle(color: Colors.black),
              body2: TextStyle(color: Colors.black),
              button: TextStyle(color: Colors.black),
              title: TextStyle(color: Colors.black),
              caption: TextStyle(color: Colors.black),
              display1: TextStyle(color: Colors.black),
              display2: TextStyle(color: Colors.black),
              display3: TextStyle(color: Colors.black),
              display4: TextStyle(color: Colors.black),
              headline: TextStyle(color: Colors.black),
              overline: TextStyle(color: Colors.black),
              subhead: TextStyle(color: Colors.black),
              subtitle: TextStyle(color: Colors.black)),
          brightness: Brightness.light,
          //Changing this will change the color of the TabBar
          accentColor: Colors.black,
        ),
        routes: {
          '/': (BuildContext context) =>
              !_model.isAuthenticated ? MyHomePage(_model) : HomePage(_model),
          '/addnew': (BuildContext context) => BookAddPage(_model),
          '/test': (BuildContext context) => FriendDetailsPage()
        },
        onUnknownRoute: (RouteSettings settings) {
          if (settings.name.startsWith('/book/')) {
            String bookId = settings.name.split('/book/')[1];
            print(bookId);
            return MaterialPageRoute(
                builder: (BuildContext context) => BookPage(bookId, _model));
          } else {
            return MaterialPageRoute(
                builder: (BuildContext context) => !_model.isAuthenticated
                    ? MyHomePage(_model)
                    : HomePage(_model));
          }
        },
      ),
    );
  }
}
