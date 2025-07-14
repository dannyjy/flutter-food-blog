import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<RecipeModel>> getRecipes() {
    return _db.collection('recipes').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList());
  }

  Future<void> addRecipe(RecipeModel recipe) {
    return _db.collection('recipes').add(recipe.toFirestore());
  }

  Future<void> likeRecipe(String recipeId, String userId) {
    return _db.collection('recipes').doc(recipeId).update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }
}
