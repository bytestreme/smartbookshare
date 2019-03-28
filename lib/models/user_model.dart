import 'book_model.dart';

class UserModel {
  String id;
  String phone;
  String hash;
  String token;
  String accessToken;
  String name;
  String email;
  String image;
  String userType;
  List<BookModel> booklist = [];
  UserModel(
      {this.id,
      this.phone,
      this.accessToken,
      this.name,
      this.image,
      this.email,
      this.hash,
      this.token,
      this.userType});

  void addBook(BookModel newBook) {
    booklist.add(newBook);
  }

  String get getId {
    print("GET CALLLLLLLLLLLLLLLLLLLLED");
    return id;
  }
}
