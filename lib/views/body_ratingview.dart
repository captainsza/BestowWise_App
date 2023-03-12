import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../stream/through_db.dart';
import '../utilities/stars_rating.dart';

class CategoryBody extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CategoryBody({Key? key});

  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  late Stream<List<String>> _imageUrlsStream;
  List<String> imageUrls = [];
  PageController controller = PageController(initialPage: 0);
  late double _ratingValue = 0;
  final Map<String, double> _averageRating = {};
  final Map<String, double> _itemRatings = {};

  String? selectedCategory;

  Future<void> getImageUrls() async {
    final storageReference = FirebaseStorage.instance.ref().child('images/');
    final result = await storageReference.listAll();
    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
    setState(() {
      imageUrls = urls;
    });

    // Retrieve existing ratings from Firestore and add them to the _itemRatings map
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc('Object Rating')
        .collection('Rating')
        .where('userId', isEqualTo: userId)
        .get();

    final ratings = snapshot.docs.map((doc) => doc.data()).toList();
    for (final rating in ratings) {
      final fileName = rating['name'];
      final ratingValue = rating['rating'];
      _itemRatings[fileName] = ratingValue;
    }
  }

  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    getImageUrls();
    _imageUrlsStream = FirebaseStorage.instance
        .ref()
        .child('images/')
        .listAll()
        .asStream()
        .asyncMap((result) =>
            Future.wait(result.items.map((ref) => ref.getDownloadURL())))
        .asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getCategoryStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data!;
        final userAddedCategories =
            categories.where((category) => category['name'] != null).toList();

        return Column(
          children: [
            SizedBox(
              height: 50.0,
              child: ListView.separated(
                key: UniqueKey(),
                scrollDirection: Axis.horizontal,
                itemCount: userAddedCategories.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                  width: 8.0,
                ),
                itemBuilder: (context, index) {
                  final category = userAddedCategories[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['name'];
                      });

                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: getObjectsStream(selectedCategory!),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error fetching objects'));
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final objects = snapshot.data ?? [];
                              if (objects.isEmpty) {
                                return const Center(
                                    child: Text('No objects available'));
                              }
                              return SizedBox(
                                height: 300.0,
                                child: ListView.builder(
                                  itemCount: objects.length,
                                  itemBuilder: (context, index) {
                                    final obj = objects[index];
                                    return Card(
                                      child: InkWell(
                                        onTap: () {
                                          final objName = obj['name'] ?? '';
                                          final encodedName =
                                              Uri.encodeComponent(objName);
                                          final index = imageUrls.indexWhere(
                                            (url) => url.contains(encodedName),
                                          );
                                          if (index != -1) {
                                            controller.animateToPage(
                                              index,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                        child: ListTile(
                                          title: Text(
                                            obj['name'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.deepPurpleAccent,
                                            ),
                                          ),
                                          // subtitle: Text(obj['subjects'].join(', ')),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Card(
                      color: selectedCategory == category['name']
                          ? const Color.fromARGB(255, 176, 99, 231)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          category['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: _imageUrlsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final imageUrls = snapshot.data!;
                  return PageView(
                    controller: controller,
                    scrollDirection: Axis.vertical,
                    children: imageUrls.map(
                      (url) {
                        final uri = Uri.parse(url);
                        final fileName = uri.pathSegments.last;

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(url),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  StarsRating(
                                    rating: _itemRatings[fileName] ?? 0,
                                    onRatingChanged: (double rating) {
                                      setState(() {
                                        _itemRatings[fileName] = rating;
                                        _ratingValue = rating;
                                      });
                                    },
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Store the rating in Firestore
                                      await FirebaseFirestore.instance
                                          .collection('categories')
                                          .doc('Object Rating')
                                          .collection('Rating')
                                          .add({
                                        'name': fileName,
                                        'rating': _ratingValue,
                                        'userId': userId,
                                        'PublishDateTime': DateTime.now(),
                                      });

                                      // Add the rating to the _itemRatings map
                                      _itemRatings[fileName] = _ratingValue;

                                      // Get the average rating and display it
                                      final averageRating = _itemRatings.values
                                              .reduce((a, b) => a + b) /
                                          _itemRatings.length;
                                      setState(() {
                                        _averageRating[fileName] =
                                            averageRating;
                                      });
                                    },
                                    child: const Text('Submit'),
                                  ),
                                  if (_averageRating[fileName] != null)
                                    Text(
                                        'Average rating: ${_averageRating[fileName]}'),
                                  if (_itemRatings[fileName] != null)
                                    Text(
                                        'Your rating: ${_itemRatings[fileName]}'),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
