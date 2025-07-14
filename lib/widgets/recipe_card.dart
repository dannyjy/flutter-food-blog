import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/firestore_service.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  RecipeCard({super.key, required this.recipe, required this.userId});

  @override
  Widget build(BuildContext context) {
    final bool isLiked = recipe.likedBy.contains(userId);

    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(
            recipe.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 200),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              recipe.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(recipe.description),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  _firestoreService.likeRecipe(recipe.id, userId);
                },
              ),
              Text('${recipe.likes} likes'),
            ],
          ),
        ],
      ),
    );
  }
}
