import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;

  // Corrected Constructor with named parameters
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  // Factory constructor to create a UserModel from a Firestore snapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'user', // Default to 'user' if no role is specified
    );
  }

  // Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }
}
