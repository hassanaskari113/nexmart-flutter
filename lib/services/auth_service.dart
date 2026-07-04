import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexmart/models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _fireStore = FirebaseFirestore.instance;

  // stream that tells us login state changes
  Stream<firebase_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  // quick check who is currently logged in
  firebase_auth.User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      // step 1: trigger the google account picker popup
      await _googleSignIn.initialize();
      final googleUser = await _googleSignIn.authenticate();
      // step 2: get the authentication tokens from that google account
      final googleAuth = googleUser.authentication;
      // step 3: build a firebase credential using those tokens
      final credential = firebase_auth.GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      // step 4: sign into firebase using that credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      // saving user to fireStore if it does not exist there before
      final user = userCredential.user;
      if (user != null) {
        final doc = _fireStore.collection('users').doc(user.uid);
        final docSnapShot = await doc.get();
        if (!docSnapShot.exists) {
          final userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'User',
            phone: '',
            address: '',
            email: user.email ?? '',
            photoUrl: user.photoURL ?? '',
            role: 'customer',
            createdAt: DateTime.now(),
          );
          await doc.set(userModel.toMap());
        }
      }

      return userCredential.user;
    } catch (e) {
      debugPrint("Error in SignIn: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
