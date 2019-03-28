import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:scoped_model/scoped_model.dart';

class MyHomePage extends StatefulWidget {
  MainModel model;

  MyHomePage(this.model);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FocusNode myFocusNode;
  String token;
  String githubToken = '';

  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      print("onStateChanged: ${state.type} ${state.url}");
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          print("URL changed: $url");
          if (url.startsWith(
              'https://hack-btsd.firebaseapp.com/__/auth/handler')) {
            this.token = url.split(
                'https://hack-btsd.firebaseapp.com/__/auth/handler?code=')[1];
            print("code $token");
            http
                .post(
                    'https://github.com/login/oauth/access_token?client_id=9470dd791c3a81661c7f&client_secret=367fe8d6fb0941af99777e9425f5d1692b2a1699&code=$token')
                .then((responseWithToken) {
              String body = responseWithToken.body;
              body = body.split('access_token=')[1];
              body = body.split('&scope=user')[0];
              githubToken = body;
              widget.model.ghLogin(githubToken).then((onValue) {
                flutterWebviewPlugin.close();
                print(widget.model.isAuthenticated);
                Navigator.pop(context);

                Navigator.of(context).pushReplacementNamed('/');
              });
            });
          }
        });
      }
    });
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String ghloginurl =
        'https://github.com/login/oauth/authorize?client_id=9470dd791c3a81661c7f&scope=user';

    String vkLoginUrl =
        'https://oauth.vk.com/authorize?client_id=6900033&redirect_uri=https://hack-btsd.firebaseapp.com/__/auth/handler&scope=email&response_type=token&v=5.92&revoke=1';
    return WillPopScope(
      child: Scaffold(
        appBar: PreferredSize(
          child: Container(
            color: Colors.transparent,
          ),
          preferredSize: Size(0, 0),
        ),
        resizeToAvoidBottomPadding: false,
        body: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel model) {
                  return model.isLoading
                      ? JumpingDotsProgressIndicator(
                          numberOfDots: 5,
                          color: Color(0xFF464547),
                          fontSize: 26,
                        )
                      : Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Добро пожаловать в SmartBookShare",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 26),
                              ),
                              SizedBox(
                                height: 150,
                              ),
                              Text("чтобы приступить, авторизуйтесь"),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.facebook,
                                      color: Color.fromRGBO(59, 89, 152, 1),
                                    ),
                                    onPressed: () {
                                      model.fbAuth().then((onValue) {
                                        model.setBoolAuth(true);
                                        Navigator.of(context)
                                            .pushReplacementNamed('/');
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.github,
                                      color: Color(0xFF333333),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WebviewScaffold(
                                                  appBar: AppBar(
                                                    elevation: 4,
                                                    primary: true,
                                                    leading: IconButton(
                                                        icon: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context)),
                                                    iconTheme: IconThemeData(
                                                      color: Colors
                                                          .black, //change your color here
                                                    ),
                                                    backgroundColor:
                                                        Color(0xFF464547),
                                                    automaticallyImplyLeading:
                                                        false,
                                                    title: Text(
                                                        "Авторизация с Github",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                  enableAppScheme: true,
                                                  clearCache: true,
                                                  clearCookies: true,
                                                  hidden: true,
                                                  initialChild: Center(
                                                    child: Icon(
                                                      FontAwesomeIcons.github,
                                                      color: Color(0xFF464547),
                                                    ),
                                                  ),
                                                  url: ghloginurl,
                                                )),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.vk,
                                      color: Color.fromRGBO(59, 89, 152, 1),
                                    ),
                                    onPressed: () {},
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}
