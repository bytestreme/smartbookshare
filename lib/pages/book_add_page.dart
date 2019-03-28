import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';

class BookAddPage extends StatefulWidget {
  MainModel model;

  BookAddPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _BookAddPageState();
  }
}

class _BookAddPageState extends State<BookAddPage> {
  File _image = null;
  bool _processing = false;
  String imageUrl = 'https://images-na.ssl-images-amazon.com/images/I/515iEcDr1GL._SX385_BO1,204,203,200_.jpg';

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = image;
    });
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _isbn = TextEditingController();
  bool available = true;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _pub = TextEditingController();

  Key a = Key('aaaa');

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return Scaffold(
      key: a,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF464547),
        label: Text("Добавить"),
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => WillPopScope(
                  child: SimpleDialog(
                    key: a,
                    children: <Widget>[
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: isLoading
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Создание новой книги",
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
                              : Text("Книга успешно добавлена"),
                        ),
                      )
                    ],
                  ),
                  onWillPop: () {}));
          widget.model.submitBook({
            "title": _titleController.text,
            "description": _descriptionController.text,
            "releaseDate": _dateController.text,
            "author": _authorController.text,
            "available": available,
            "ownerUserId": widget.model.getUser.id,
            "currentUserId": widget.model.getUser.id,
            'imageUrl': imageUrl,
            'publisher': _pub.text,
            'isbn': _isbn.text
          }).then((_) {
            setState(() {
              isLoading = false;

              Future.delayed(const Duration(seconds: 3), () => "3").then((s) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            });
          });
        },
        tooltip: "Добавить",
        icon: Icon(Icons.done),
      ),
      appBar: AppBar(
        title: Text("Добавление новой книги"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: _image == null
                        ? Image.network(imageUrl)
                        : Image.file(_image),
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => SimpleDialog(
                                key: Key('dasjdl'),
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          RaisedButton(
                                            child: Text("Выбрать из галереи",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            color: Color(0xFF464547),
                                            onPressed: () {
                                              getImage(ImageSource.gallery);
                                            },
                                          ),
                                          RaisedButton(
                                            onPressed: () {
                                              getImage(ImageSource.camera);
                                            },
                                            child: Text(
                                              "Сфотографировать",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            color: Color(0xFF464547),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ));
                    },
                  ),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Название книги'),
                  ),
                  TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(labelText: 'Автор книги'),
                  ),
                  TextFormField(
                    controller: _pub,
                    decoration: InputDecoration(labelText: 'Издатель'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      BarcodeScanner.scan().then((s) {
                        setState(() {
                          _isbn.text = s;
                        });
                      });
                    },
                    child: Text('Сканировать ISBN'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      http
                          .get(
                              'https://www.googleapis.com/books/v1/volumes?q=isbn:' +
                                  _isbn.text)
                          .then((r) {
                        Map<dynamic, dynamic> bd = json.decode(r.body);
                        setState(() {
                          _titleController.text =
                              bd['items'][0]['volumeInfo']['title'];
                          List<String> authors = List.from(bd['items'][0]['volumeInfo']['authors']);
                          _authorController.text = "";
                          authors.forEach((String s) {
                            _authorController.text = _authorController.text + s + ' ';
                          });
                          _pub.text = bd['items'][0]['volumeInfo']['publisher'];
                          _descriptionController.text = bd['items'][0]['volumeInfo']['description'];
                          _dateController.text = bd['items'][0]['volumeInfo']['publishedDate'];
                          imageUrl = bd['items'][0]['volumeInfo']['imageLinks']['thumbnail'];
                        });
                      });
                    },
                    child: Text('Заполнить используя ISBN'),
                  ),
                  TextFormField(
                    controller: _isbn,
                    decoration: InputDecoration(labelText: 'ISBN'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Описание книги'),
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Год выпуска'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: <Widget>[
                      Text("Доступна для чтения"),
                      Switch(
                        value: available,
                        onChanged: (bool value) {
                          setState(() {
                            available = value;
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
