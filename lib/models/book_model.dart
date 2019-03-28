import './author_model.dart';

class BookModel {
  String id;
  String title;
  String ownerUserId;
  String currentUserId;
  String releaseDate;
  bool available;
  String description;
  String author;
  BookModel(
      {this.id,
      this.title,
      this.ownerUserId,
      this.currentUserId,
      this.description,
      this.author,
      this.releaseDate,
      this.available});

  BookModel.fromJson(String id, Map<dynamic, dynamic> json)
      : title = json['title'],
        ownerUserId = json['ownerUserId'],
        currentUserId = json['currentUserId'],
        releaseDate = json['releaseDate'],
        available = json['available'],
        description = json['description'],
        author = json['author'],
        this.id = id;

  @override
  String toString() {
    return "$id $title $description $author $available $currentUserId $ownerUserId $releaseDate";
  }
}
