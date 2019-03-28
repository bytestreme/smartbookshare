import 'package:flutter/material.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          child: model.getUser == null
              ? Container()
              : Column(
                  children: <Widget>[
                    Text(model.getUser.email == null
                        ? "null"
                        : model.getUser.email),
                    Text(model.getUser.name == null
                        ? "null"
                        : model.getUser.name),
                    Text(model.getUser.phone == null
                        ? "null"
                        : model.getUser.phone),
                    Image(
                        image: NetworkImage(model.getUser.image == null
                            ? "null"
                            : model.getUser.image)),
                    Text(model.getUser.id == null ? "null" : model.getUser.id),
                    Text(model.getUser.token == null
                        ? "null"
                        : model.getUser.token),
                    OutlineButton(
                      borderSide: BorderSide(
                          color: Colors.red,
                          style: BorderStyle.solid,
                          width: 3.0),
                      child: Text('Logout'),
                      onPressed: () {
                        if (model.getUser.userType.startsWith('facebook')) {
                          model.fbLogout().then((onValue) {
                            Navigator.of(context).pushReplacementNamed('/');
                          });
                        } else if (model.getUser.userType
                            .startsWith('github')) {
                          model.ghLogout().then((onValue) {
                            Navigator.of(context).pushReplacementNamed('/');
                          });
                        }
                      },
                    ),
                    FlatButton(
                      child: Text("TEXT"),
                      onPressed: () => Navigator.of(context).pushNamed('/test'),
                    )
                  ],
                ),
        );
      },
    );
  }
}
