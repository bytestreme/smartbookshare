import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/models/book_model.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

import '../models/user_model.dart';

mixin ConnectedProductsModel on Model {
  FacebookLogin facebookLogin = FacebookLogin();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  List<BookModel> _myLibrary = [];
  bool _isLoading = false;
  UserModel _user;
}

mixin UserScopedModel on ConnectedProductsModel {
  bool _isAuthenticated = false;

  Future<void> fbLogout() {
    return facebookLogin.logOut().then((onValue) {
      _myLibrary = [];
      _isLoading = false;
      setBoolAuth(false);
      deauthenticate();
      notifyListeners();
    });
  }

  Future<DocumentReference> fbAuth() {
    _isLoading = true;
    notifyListeners();
    return facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']).then((onValue) {
      if (onValue.status == FacebookLoginStatus.loggedIn) {
        final FacebookAccessToken fbToken = onValue.accessToken;
        AuthCredential creds =
            FacebookAuthProvider.getCredential(accessToken: fbToken.token);
        FirebaseAuth.instance.signInWithCredential(creds).then((faceBookUser) {
          faceBookUser.getIdToken(refresh: false).then((onValue) {
            UserModel newUser = UserModel(
                id: faceBookUser.uid,
                name: faceBookUser.displayName,
                email: faceBookUser.email,
                phone: faceBookUser.phoneNumber,
                image: faceBookUser.photoUrl + '?width=720&height=720',
                token: fbToken.token,
                accessToken: onValue,
                userType: "facebook");
            setAuthenticated(newUser);
            createProfile(newUser).then((createProfileResponse) {
              initUserList(newUser).then((onValue) {
                _isLoading = false;
                notifyListeners();
              });
            });
          });
        });
      } else if (onValue.status == FacebookLoginStatus.cancelledByUser) {
        _isLoading = false;
        notifyListeners();
      }
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> ghLogout() {
    return firebaseAuth.signOut().then((onValue) {
      _myLibrary = [];

      _isLoading = false;
      setBoolAuth(false);
      deauthenticate();
      notifyListeners();
    });
  }

  Future<void> ghLogin(String gitHubToken) {
    _isLoading = true;
    notifyListeners();
    AuthCredential ghCreds =
        GithubAuthProvider.getCredential(token: gitHubToken);
    return firebaseAuth.signInWithCredential(ghCreds).then((ghUser) {
      return http.get('https://api.github.com/user?access_token=$gitHubToken',
          headers: {"Authorization": "Bearer " + gitHubToken}).then((apiValue) {
        var ghApiResponse = apiValue.body;
        UserModel newUser = UserModel(
            id: ghUser.uid,
            name: json.decode(ghApiResponse)['login'],
            email: ghUser.email,
            phone: ghUser.phoneNumber,
            image: ghUser.photoUrl,
            token: gitHubToken,
            accessToken: gitHubToken,
            userType: "github");
        setAuthenticated(newUser);
        setBoolAuth(true);

        createProfile(newUser).then((v) {
          initUserList(newUser).then((_) {
            _isLoading = false;
            notifyListeners();
          });
        });
      });
    });
  }

  UserModel get getUser {
    return _user;
  }

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  void setBoolAuth(bool value) {
    _isAuthenticated = value;
  }

  void setAuthenticated(UserModel user) {
    _user = user;
  }

  void deauthenticate() {
    _user = null;
    _isAuthenticated = false;
  }

  Future<void> createProfile(UserModel user) {
    return firebaseMessaging.getToken().then((token) {
      firestore.collection('users').document(user.id).setData({
        "id": user.id,
        "email": user.email,
        "imageUrl": user.image,
        "pushId": token,
        "phone": user.phone != null ? user.phone : "NOT_SET",
      });
    });

//    FirebaseDatabase database =
//        FirebaseDatabase(databaseURL: 'https://hack-btsd.firebaseio.com/');
//    DatabaseReference _userRef = database.reference().child('users');
//    return _userRef.update({
//      user.id: {
//        "imageUrl": user.image,
//        "email": user.email,
//        "name": user.name,
//        'phone': user.phone == null ? "null" : user.phone
//      }
//    });
  }

  Future<void> initUserList(UserModel user) {
    return firestore
        .collection('userIdList')
        .document(user.id)
        .setData({"name": user.name});
//    FirebaseDatabase database =
//        FirebaseDatabase(databaseURL: 'https://hack-btsd.firebaseio.com/');
//    DatabaseReference _userListRef = database.reference().child('userlist');
//    return _userListRef.update({user.id: user.name});
  }

// Future<void> initBookShelf(UserModel user) {
//   FirebaseDatabase database =
//       FirebaseDatabase(databaseURL: 'https://hack-btsd.firebaseio.com/');
//   DatabaseReference _bookShelfRef =
//       database.reference().child('/bookshelf/' + user.id);
//   return _bookShelfRef.push().set(<String, String>{"owner": user.id});
// }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool val) {
    this._isLoading = val;
    notifyListeners();
  }
}

mixin PersonalLibraryScopedModel on ConnectedProductsModel {
  List<Map<String, String>> _requests = [];

  List<Map<String, String>> get requests {
    return _requests;
  }

  List<Map<String, String>> _returnNotifications = [];

  List<Map<String, String>> get returnNotifications {
    return _returnNotifications;
  }

  List<Map<String, String>> _returnRequests = [];

  List<Map<String, String>> get returnRequests {
    return _returnRequests;
  }

  Future<void> submitBook(Map<dynamic, dynamic> bookSubmitData) {
    return firestore.collection('books').add({
      "title": bookSubmitData['title'],
      "description": bookSubmitData['description'],
      "releaseDate": bookSubmitData['releaseDate'],
      "author": bookSubmitData['author'],
      "available": bookSubmitData['available'],
      "ownerUserId": bookSubmitData['ownerUserId'],
      "currentUserId": bookSubmitData['currentUserId']
    }).then((DocumentReference dr) {
      var bookId = dr.documentID;
      firestore
          .collection('bookshelf')
          .document(bookSubmitData['ownerUserId'])
          .setData({bookId: true}, merge: true);
      FirebaseDatabase database =
          FirebaseDatabase(databaseURL: 'https://hack-btsd.firebaseio.com/');
      DatabaseReference _booksRef = database.reference().child('books');
      _booksRef.child(bookId).set({
        "title": bookSubmitData['title'],
        "description": bookSubmitData['description'],
        "releaseDate": bookSubmitData['releaseDate'],
        "author": bookSubmitData['author'],
        "available": bookSubmitData['available'],
        "ownerUserId": bookSubmitData['ownerUserId'],
        "currentUserId": bookSubmitData['currentUserId']
      }).then((onValue) {});
    });
  }

  List<BookModel> get myLibrary {
    return _myLibrary;
  }

  Future<DocumentSnapshot> getBook(String bookId) async {
    return firestore.collection('books').document(bookId).get();
  }

  Future<void> sendBookRequest(
      String bookId, String newHolderUserId, String ownerUserId) async {
    return firestore.collection('requests').add({
      'bookId': bookId,
      'newHolderUserId': newHolderUserId,
      'ownerUserId': ownerUserId
    });
  }

  Future<void> fetchRequests() {
    _isLoading = true;
    notifyListeners();
    List<Map<String, String>> _newRequests = [];
    return firestore
        .collection('requests')
        .getDocuments()
        .then((querySnapshots) {
      querySnapshots.documents.forEach((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.data['ownerUserId'].toString() == _user.id) {
          _newRequests.add({
            'bookId': documentSnapshot.data['bookId'],
            'newHolderUserId': documentSnapshot.data['newHolderUserId'],
            'requestId': documentSnapshot.documentID
          });
        }
      });
      _newRequests.forEach((map) {
        firestore
            .collection('userIdList')
            .document(map['newHolderUserId'])
            .get()
            .then((ds) {
          map['newHolderUserName'] = ds.data['name'];
          firestore
              .collection('books')
              .document(map['bookId'])
              .get()
              .then((bs) {
            map['bookName'] = bs['title'];
            _requests = _newRequests;
            _isLoading = false;
            notifyListeners();
            print(map);
          });
        });
      });
    });
  }

  Future<void> notifyToReturn(String bookId, String currentUserId,
      String bookName, String ownerUserName) {
    return firestore.collection('returnnotify').add({
      'bookId': bookId,
      'currentUserId': currentUserId,
      'bookName': bookName,
      'ownerUserName': ownerUserName
    });
  }

  Future<void> fetchReturnNotifications() {
    List<Map<String, String>> _newNotifications = [];

    return firestore
        .collection('returnnotify')
        .getDocuments()
        .then((QuerySnapshot qs) {
      qs.documents.forEach((DocumentSnapshot ds) {
        if (ds.data['currentUserId'] == _user.id) {
          _newNotifications.add({
            'requestId': ds.documentID,
            'bookId': ds.data['bookId'],
            'bookName': ds.data['bookName'],
            'currentUserId': ds.data['currentUserId'],
            'ownerUserName': ds.data['ownerUserName']
          });
          _returnNotifications = _newNotifications;
        }
      });
    });
  }

  Future<void> acceptRequest(Map<String, String> request) {
    print(
        "transfering book to ${request['newHolderUserName']} from ${_user.name} with bookName ${request['bookName']}");
    return firestore
        .collection('books')
        .document(request['bookId'])
        .updateData({
      'currentUserId': request['newHolderUserId'],
      'available': false
    }).then((s) {
      firestore
          .collection('requests')
          .document(request['requestId'])
          .delete()
          .then((s) {
        _requests
            .removeWhere((req) => req['requestId'] == request['requestId']);
        notifyListeners();
      });
    });
  }

  Future<void> declineRequest(Map<String, String> request) {
    return firestore
        .collection('requests')
        .document(request['requestId'])
        .delete()
        .then((s) {
      _requests.removeWhere((req) => req['requestId'] == request['requestId']);
      notifyListeners();
    });
  }

  Future<void> sendReturnRequest(
      String bookId, String currentUserId, String ownerUserId) async {
    return firestore.collection('returnRequests').add({
      'bookId': bookId,
      'currentUserId': currentUserId,
      'ownerUserId': ownerUserId
    });
  }

  Future<void> acceptReturnRequest(Map<String, String> request) {
    return firestore
        .collection('returnRequests')
        .document(request['requestId'])
        .delete()
        .then((s) {
      firestore
          .collection('books')
          .document(request['bookId'])
          .updateData({'currentUserId': request['ownerUserId']}).then((s) {
        _returnRequests
            .removeWhere((req) => req['requestId'] == request['requestId']);
        notifyListeners();
      });
    });
  }

  Future<void> fetchReturnRequests() {
    List<Map<String, String>> _newReturnRequests = [];
    return firestore
        .collection('returnRequests')
        .getDocuments()
        .then((QuerySnapshot qs) {
      qs.documents.forEach((DocumentSnapshot ds) {
        if (ds.data['ownerUserId'] == _user.id) {
          String ownerUserId = ds.data['ownerUserId'];
          String reqId = ds.documentID;
          String bookId = ds.data['bookId'];
          print(ds.data['bookId']);
          String bookName = '';
          String currentUserName = "";
          firestore
              .collection('books')
              .document(ds.data['bookId'])
              .get()
              .then((DocumentSnapshot ds) {
            bookName = ds.data['title'];
            firestore
                .collection('userIdList')
                .document(ds.data['currentUserId'])
                .get()
                .then((DocumentSnapshot dsname) {
              currentUserName = dsname.data['name'];
              _newReturnRequests.add({
                'bookId': bookId,
                'bookName': bookName,
                'currentUserName': currentUserName,
                'requestId': reqId,
                'ownerUserId': ownerUserId
              });
              _returnRequests = _newReturnRequests;
              _isLoading = false;
              print(_newReturnRequests);
              notifyListeners();
            });
          });
        }
      });
    });
  }

  Future<QuerySnapshot> getBookRequests(String bookId) {
    return firestore.collection('requests').getDocuments();
  }
}
