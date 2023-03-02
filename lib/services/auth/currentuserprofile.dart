import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  late final String email;
  final String name;
  final String city;
  final String? image;

  UserData({
    required this.email,
    required this.name,
    required this.city,
    this.image,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserData(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      image: data['image'] as String?,
    );
  }

  static Future<UserData?> fetchUser(String email) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    if (snapshot.exists) {
      return UserData.fromFirestore(snapshot);
    } else {
      return null;
    }
  }

  static Stream<List<UserData>> fetchAllUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => UserData.fromFirestore(doc)).toList());
  }
}
