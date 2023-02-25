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

Stream<List<Map<String, dynamic>>> getObjectStream(int categoryIndex) {
  return FirebaseFirestore.instance
      .collection('categories')
      .doc('objects')
      .collection('items')
      .where('categoryIndex', isEqualTo: categoryIndex)
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

class RatingStream {
  static Stream<double> getRatingStream(String fileName) {
    return FirebaseFirestore.instance
        .collection('categories')
        .doc('objects')
        .collection('items')
        .doc('rating')
        .collection('Rating objects')
        .where('name', isEqualTo: fileName)
        .snapshots()
        .map((snapshot) {
      final ratings = snapshot.docs.isNotEmpty
          ? snapshot.docs.map((doc) => doc.data()['rating'] ?? 0).toList()
          : [];
      if (ratings.isEmpty) {
        return 0;
      }
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      return averageRating;
    });
  }
}
