import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getter for the current user
  User? get currentUser => _auth.currentUser;

  Future<String> signUpUser({
    required String fullName,
    required String email,
    required String password,
    File? imageFile,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && fullName.isNotEmpty) {
        // Register user with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String? imageUrl;
        if (imageFile != null) {
          // Upload image to Firebase Storage
          final ref = _storage.ref().child('user_images').child(cred.user!.uid + '.jpg');
          await ref.putFile(imageFile);
          imageUrl = await ref.getDownloadURL();
        }

        // Store additional user data in Firestore
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'uid': cred.user!.uid,
          if (imageUrl != null) 'imageUrl': imageUrl,
        });

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? 'An unknown error occurred.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> signInUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? 'An unknown error occurred.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
