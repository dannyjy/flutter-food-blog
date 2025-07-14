import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blogfood/models/user_model.dart';
import 'package:blogfood/models/recipe_model.dart';
import 'package:blogfood/screens/recipe_detail_screen.dart'; // To view user's recipes
import 'package:blogfood/screens/add_recipe_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userProfile;
  List<RecipeModel> _userRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndRecipes();
  }

  Future<void> _fetchUserProfileAndRecipes() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch user profile
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        _userProfile = UserModel.fromFirestore(userDoc);
      }

      // Fetch user's recipes
      QuerySnapshot recipeSnapshot = await _firestore
          .collection('recipes')
          .where('authorId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userRecipes = recipeSnapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile or recipes: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userProfile?.fullName ?? 'Guest User',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userProfile?.email ?? 'N/A',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Recipes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 20, thickness: 1),
                  _userRecipes.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'You have not added any recipes yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true, // Important for nested list views
                          physics: const NeverScrollableScrollPhysics(), // Important for nested list views
                          itemCount: _userRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _userRecipes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    recipe.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 30),
                                    ),
                                  ),
                                ),
                                title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.red, size: 18),
                                    const SizedBox(width: 4),
                                    Text('${recipe.likes}'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => RecipeDetailScreen(recipe: recipe),
                                  ));
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'ADD RECIPES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'LOGOUT',
          ),
        ],
        currentIndex: 2, // Highlight Profile
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.of(context).pop(); // Go back to Home
          if (index == 1) Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
          // Handle other navigation if needed
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}