import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String bio;
  final String photoUrl;

  User({
    this.id,
    this.username,
    this.email,
    this.displayName,
    this.bio,
    this.photoUrl,
  });

  factory User.fromDocument(DocumentSnapshot doc){
    print("Printing user from User Model");
    // String check = doc['photoUrl'];
    // print("$check");
    return User(
      photoUrl: doc['photoUrl'],
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      // photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}
