import 'package:firebase_database/firebase_database.dart';

Stream<List<Map<String, dynamic>>> getCategoryStream() {
  final databaseReference = FirebaseDatabase.instance.ref().child("categories");
  return databaseReference.onValue.map((event) {
    final categories = <Map<String, dynamic>>[];
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      // ignore: avoid_function_literals_in_foreach_calls
      data.entries.forEach((entry) {
        final category = Map<String, dynamic>.from(entry.value);
        categories.add(category);
      });
    }
    return categories;
  });
}

Stream<List<Map<String, dynamic>>> getobjectStream(int? selectedCategoryIndex) {
  final databaseReference =
      FirebaseDatabase.instance.ref().child("categories").child('object');
  return databaseReference.onValue.map((event) {
    final obj = <Map<String, dynamic>>[];
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      // ignore: avoid_function_literals_in_foreach_calls
      data.entries.forEach((entry) {
        final objs = Map<String, dynamic>.from(entry.value);
        objs['objid'] = entry.key;
        obj.add(objs);
      });
    }
    return obj;
  });
}
