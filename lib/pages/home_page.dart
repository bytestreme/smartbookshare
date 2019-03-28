import 'package:flutter/material.dart';
import 'package:flutter_app/pages/notifications_page.dart';
import 'package:flutter_app/pages/search_page.dart';
import 'package:flutter_app/pages/testprofile/friend_details_page.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:flutter_app/widgets/structs/NavigationIconView.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import './library_page.dart';

class HomePage extends StatefulWidget {
  MainModel model;

  HomePage(this.model);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String uid = '';
  List<NavigationIconView> _navigationViews;
  int _currentIndex = 0;

  @override
  void initState() {
    FirebaseMessaging().getToken().then((s){
      print("TOKEN<$s>");
    });
    // this.uid = '';
    // FirebaseAuth.instance.currentUser().then((val) {
    //   setState(() {
    //     this.uid = val.uid;
    //   });
    // }).catchError((e) {
    //   print(e);
    // });

    _navigationViews = <NavigationIconView>[
      NavigationIconView(
        activeIcon: Icon(
          Icons.list,
          color: Color(0xFF39c2d7),
        ),
        icon: Icon(
          Icons.list,
        ),
        title: 'Библиотека',
        color: Colors.deepOrange,
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(
          Icons.account_circle,
        ),
        activeIcon: const Icon(
          Icons.account_circle,
          color: Color(0xFF39c2d7),
        ),
        title: 'Профиль',
        color: Colors.pink,
        vsync: this,
      ),
      NavigationIconView(
        activeIcon: const Icon(
          Icons.search,
          color: Color(0xFF39c2d7),
        ),
        icon: const Icon(
          Icons.search,
        ),
        title: 'Найти книгу',
        color: Colors.indigo,
        vsync: this,
      ),

      NavigationIconView(
        icon: const Icon(
          Icons.notifications,
        ),
        activeIcon: const Icon(
          Icons.notifications,
          color: Color(0xFF39c2d7),
        ),
        title: 'События',
        color: Colors.pink,
        vsync: this,
      )
    ];
    _navigationViews[_currentIndex].controller.value = 1.0;
    super.initState();
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews) view.controller.dispose();
    super.dispose();
  }

  Widget _buildPageContent(int currentIndex) {
    Widget result = Text("ERROR");
    switch (currentIndex) {
      case 0:
        result = LibraryPage(widget.model);
        break;
      case 1:
        result = FriendDetailsPage();
        break;
      case 2:
        result = SearchPage();
        break;
      case 3:
        result = NotificationsPage(widget.model);
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = BottomNavigationBar(
      fixedColor: Color(0xFF242E3E),
      items: _navigationViews
          .map<BottomNavigationBarItem>(
              (NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      //iconSize: 4.0,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });
      },
    );


    return new Scaffold(
        appBar: _currentIndex == 1
            ? AppBar(
                title: Text(widget.model.getUser.name),
                leading: null,
                automaticallyImplyLeading: false,
              )
            : PreferredSize(
                preferredSize: Size(0, 0),
                child: Container(
                  color: Color(0xFF464547),
                ),
              ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                backgroundColor: Color(0xFF464547),
                icon: Icon(
                  Icons.add,
                ),
                label: Text("Добавить книгу"),
                onPressed: () {
                  Navigator.of(context).pushNamed('/addnew');
                },
              )
            : null,
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: botNavBar,
        body: _buildPageContent(_currentIndex));
  }
}
