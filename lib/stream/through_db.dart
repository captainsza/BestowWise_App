import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Map<String, dynamic>>> getCategoryStream() {
  return FirebaseFirestore.instance
      .collection('categories')
      .orderBy('index')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

Stream<List<Map<String, dynamic>>> getObjectsStream(String selectedCategory) {
  final categoryCollection = FirebaseFirestore.instance
      .collection('categories')
      .doc(selectedCategory)
      .collection('objects');

  return categoryCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

Stream<List<Map<String, dynamic>>> getObjectStreamByUser(String? userEmail) {
  final collection = FirebaseFirestore.instance.collection('objects');

  return collection.where('user_email', isEqualTo: userEmail).snapshots().map(
      (querySnapshot) => querySnapshot.docs.map((doc) => doc.data()).toList());
}
