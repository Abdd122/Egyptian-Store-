
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:myapp/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Create GoogleSignIn instance
  StreamSubscription? _authSubscription;
  StreamSubscription? _userSubscription;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  bool get isAdmin => _userModel?.role == 'admin';

  UserProvider() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // --- Google Sign-In Method ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Start the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Handle errors (e.g., network issues, user cancellation)
      debugPrint("Error during Google Sign-In: $e");
      return null;
    }
  }

  // --- Auth State Change Listener ---
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User is logged out
      await _userSubscription?.cancel();
      _userModel = null;
    } else {
      // User is logged in, fetch or create their document
      await _userSubscription?.cancel();
      final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);

      _userSubscription = userDocRef.snapshots().listen((snapshot) async {
        if (snapshot.exists) {
          // User document exists, map it to our model
          _userModel = UserModel.fromFirestore(snapshot);
        } else {
          // User document does not exist (e.g., first-time Google sign-in)
          // Create a new user document for them.
          final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? 'No Email',
            displayName: firebaseUser.displayName ?? 'No Name',
            role: 'user', // Default role
          );
          await userDocRef.set(newUser.toFirestore());
          // _userModel will be updated by the stream listener automatically after set()
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // --- Sign Out Method ---
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut();      // Sign out from Firebase
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
