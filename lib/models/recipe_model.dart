import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String cookingTime;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final int likes;
  final List<String> likedBy;
  final Timestamp createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.cookingTime,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt,
  });

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      cookingTime: data['cookingTime'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'cookingTime': cookingTime,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt,
    };
  }
}