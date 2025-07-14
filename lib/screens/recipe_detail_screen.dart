import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogfood/models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late RecipeModel _currentRecipe;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
  }

  Future<void> _toggleLike() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to like recipes.')),
      );
      return;
    }

    String userId = currentUser.uid;
    bool isLiked = _currentRecipe.likedBy.contains(userId);

    try {
      DocumentReference recipeRef = _firestore.collection('recipes').doc(_currentRecipe.id);

      if (isLiked) {
        // Unlike
        await recipeRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
        setState(() {
          _currentRecipe = RecipeModel(
            id: _currentRecipe.id,
            title: _currentRecipe.title,
            description: _currentRecipe.description,
            ingredients: _currentRecipe.ingredients,
            cookingTime: _currentRecipe.cookingTime,
            imageUrl: _currentRecipe.imageUrl,
            authorId: _currentRecipe.authorId,
            authorName: _currentRecipe.authorName,
            likes: _currentRecipe.likes - 1,
            likedBy: List<String>.from(_currentRecipe.likedBy)..remove(userId),
            createdAt: _currentRecipe.createdAt,
          );
        });
      } else {
        // Like
        await recipeRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
        setState(() {
          _currentRecipe = RecipeModel(
            id: _currentRecipe.id,
            title: _currentRecipe.title,
            description: _currentRecipe.description,
            ingredients: _currentRecipe.ingredients,
            cookingTime: _currentRecipe.cookingTime,
            imageUrl: _currentRecipe.imageUrl,
            authorId: _currentRecipe.authorId,
            authorName: _currentRecipe.authorName,
            likes: _currentRecipe.likes + 1,
            likedBy: List<String>.from(_currentRecipe.likedBy)..add(userId),
            createdAt: _currentRecipe.createdAt,
          );
        });
      }
    } catch (e) {
      // print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    bool isLiked = _currentRecipe.likedBy.contains(currentUser?.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecipe.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                _currentRecipe.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 60)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRecipe.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${_currentRecipe.authorName}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Cooking Time: ${_currentRecipe.cookingTime}'),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text('${_currentRecipe.likes} likes'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentRecipe.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _currentRecipe.ingredients
                        .map((ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text('• $ingredient', style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}