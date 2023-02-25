import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../stream/RatingStream.dart';
import '../utilities/starsRating.dart';

class CategoryBody extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CategoryBody({Key? key});

  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  final Map<String, double> _itemRatings = {};
  int? _selectedIndex;
  List<String> imageUrls = [];
  PageController controller = PageController(initialPage: 0);
  double _ratingValue = 0;
  late double _averageRating = 0;

  Future<void> getImageUrls() async {
    final storageReference = FirebaseStorage.instance.ref().child('images');
    final result = await storageReference.listAll();
    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
    setState(() {
      imageUrls = urls;
    });
  }

  @override
  void initState() {
    super.initState();
    getImageUrls();
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
                        _selectedIndex = category['index'];
                      });
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream:
                                category != null && category['index'] != null
                                    ? getObjectStream(category['index'])
                                    : null,
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
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No objects available'));
                              }

                              final objects = snapshot.data!;

                              return SizedBox(
                                height: 300.0,
                                child: ListView.builder(
                                  itemCount: objects.length,
                                  itemBuilder: (context, index) {
                                    final obj = objects[index];
                                    return Card(
                                      child: InkWell(
                                        onTap: () {
                                          // Do something when an object is tapped
                                        },
                                        child: ListTile(
                                          title: Text(obj['name'] ?? ''),
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
                      color: _selectedIndex == category['index']
                          ? Colors.deepPurpleAccent
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          category['name'] ?? '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller,
                scrollDirection: Axis.vertical,
                children: imageUrls.map((url) {
                  final uri = Uri.parse(url);
                  final fileName = uri.pathSegments.last;

                  return Column(
                    children: [
                      Expanded(child: Image.network(url)),
                      Text(
                        fileName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      StarsRating(
                          rating: 3.5,
                          onRatingChanged: (double rating) {
                            setState(() {
                              _ratingValue = rating;
                            });
                          }),
                      ElevatedButton(
                        onPressed: () async {
                          // Store the rating in Firestore
                          await FirebaseFirestore.instance
                              .collection('categories')
                              .doc('objects')
                              .collection('items')
                              .doc('rating')
                              .collection('Rating objects')
                              .add({
                            'name': fileName,
                            'rating': _ratingValue,
                          });

                          // Add the rating to the _itemRatings map
                          _itemRatings[fileName] = _ratingValue;

                          // Get the average rating and display it
                          final averageRating = _itemRatings[fileName];
                          setState(() {
                            _averageRating = averageRating!;
                          });
                        },
                        child: const Text('Submit'),
                      ),
                      if (_averageRating != null)
                        Text('Average rating: $_averageRating'),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
