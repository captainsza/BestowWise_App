import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:multi_state_button/multi_state_button.dart';
import '../services/auth/currentuserprofile.dart';
import '../stream/through_db.dart';
import '../utilities/stars_rating.dart';

class CategoryBody extends StatefulWidget {
  const CategoryBody({super.key});
  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  static const String _submit = "Submit";
  static const String _loading = "Loading";
  static const String _success = "Success";
  final MultiStateButtonController multiStateButtonController =
      MultiStateButtonController(initialStateName: _submit);
  late Stream<List<String>> _imageUrlsStream;
  List<String> imageUrls = [];
  final PageController controller = PageController(initialPage: 0);
  double _ratingValue = 0;
  final Map<String, double> _averageRating = {};
  final Map<String, double> _itemRatings = {};
  String? selectedCategory, userId;

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
        .asyncMap(
          (result) => Future.wait(
            result.items.map(
              (ref) => ref.getDownloadURL(),
            ),
          ),
        )
        .asBroadcastStream();
  }

  Future<void> getImageUrls() async {
    final storageReference = FirebaseStorage.instance.ref().child('images/');
    final result = await storageReference.listAll();
    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
    setState(() {
      imageUrls = urls;
    });
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
                    const SizedBox(width: 8.0),
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
                          List<Map<String, dynamic>> allObjects = [];
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: getObjectsStream(selectedCategory!),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error fetching objects'));
                              }
                              final objects = snapshot.data ?? [];
                              allObjects.addAll(objects);
                              if (objects.isEmpty) {
                                return const Center(
                                    child: Text('No objects available'));
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TypeAheadField(
                                      suggestionsCallback: (pattern) async {
                                        // retrieve all objects from database
                                        List<Map<String, dynamic>> objects =
                                            await getObjectsStream(
                                                    selectedCategory!)
                                                .first;
                                        // filter out objects that do not match the pattern
                                        return objects.where((obj) =>
                                            obj['name']
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    pattern.toLowerCase()));
                                      },
                                      itemBuilder: (context, suggestion) {
                                        final objName =
                                            suggestion['name'] ?? '';
                                        return ListTile(
                                          title: Text(
                                            objName,
                                            style: const TextStyle(
                                              color: Colors.deepPurpleAccent,
                                            ),
                                          ),
                                        );
                                      },
                                      onSuggestionSelected: (suggestion) {
                                        final objName =
                                            suggestion['name'] ?? '';
                                        final encodedName =
                                            Uri.encodeComponent(objName);
                                        final index = imageUrls.indexWhere(
                                            (url) => url.contains(encodedName));
                                        if (index != -1) {
                                          controller.animateToPage(
                                            index,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeOut,
                                          );
                                          Navigator.of(context).pop(Duration
                                              .microsecondsPerMillisecond);
                                        }
                                      },
                                      textFieldConfiguration:
                                          const TextFieldConfiguration(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Search objects...',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
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
                                              final index = imageUrls
                                                  .indexWhere((url) => url
                                                      .contains(encodedName));
                                              if (index != -1) {
                                                controller.animateToPage(
                                                  index,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeOut,
                                                );
                                                Navigator.of(context).pop(Duration
                                                    .microsecondsPerMillisecond);
                                              }
                                            },
                                            child: ListTile(
                                              title: Text(
                                                obj['name'] ?? '',
                                                style: const TextStyle(
                                                  color:
                                                      Colors.deepPurpleAccent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: category['name'] == selectedCategory
                            ? Colors.deepPurple[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        category['name'],
                        style: const TextStyle(color: Colors.black),
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
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                              ),
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
                                    rating: (_itemRatings[fileName] ?? 0)
                                        .toDouble(),
                                    onRatingChanged: (double rating) {
                                      setState(() {
                                        _itemRatings[fileName] = rating;
                                        _ratingValue = rating;
                                      });
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MultiStateButton(
                                        multiStateButtonController:
                                            multiStateButtonController,
                                        buttonStates: [
                                          ButtonState(
                                            stateName: _submit,
                                            child: const Text(
                                              _submit,
                                            ),
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                            size: const Size(160, 48),
                                            color: Colors.transparent,
                                            onPressed: () async {
                                              multiStateButtonController
                                                  .setButtonState = _loading;
                                              final user =
                                                  await UserData.fetchUser(
                                                FirebaseAuth.instance
                                                    .currentUser!.email!,
                                              );
                                              await FirebaseFirestore.instance
                                                  .collection('categories')
                                                  .doc('Object Rating')
                                                  .collection('Ratings')
                                                  .add({
                                                'name': fileName,
                                                'rating': _ratingValue,
                                                'userId': user?.email,
                                                'username': user?.name,
                                                'PublishDateTime':
                                                    DateTime.now(),
                                              });
                                              _itemRatings[fileName] =
                                                  _ratingValue;

                                              // Count all ratings
                                              double totalRatings = 0;
                                              _itemRatings
                                                  .forEach((key, value) {
                                                totalRatings += value;
                                              });

                                              // Calculate average rating
                                              double averageRating =
                                                  totalRatings /
                                                      _itemRatings.length;
                                              _averageRating[fileName] =
                                                  averageRating;
                                              await FirebaseFirestore.instance
                                                  .collection("categories")
                                                  .doc('Object Rating')
                                                  .collection('Average Rating')
                                                  .doc('avg ratings')
                                                  .set({
                                                "name": user?.name,
                                                "rating": averageRating,
                                                "object": fileName,
                                              });
                                              multiStateButtonController
                                                  .setButtonState = _success;
                                            },
                                          ),
                                          const ButtonState(
                                            stateName: _loading,
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.white,
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(48)),
                                            ),
                                            size: Size(48, 48),
                                          ),
                                          ButtonState(
                                            stateName: _success,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  _success,
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22),
                                            color: Colors.transparent,
                                            size: const Size(200, 48),
                                            onPressed: () =>
                                                multiStateButtonController
                                                    .setButtonState = _submit,
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final snapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('categories')
                                                  .doc('Object Rating')
                                                  .collection('Ratings')
                                                  .where('name',
                                                      isEqualTo: fileName)
                                                  .get();
                                          if (snapshot.docs.isNotEmpty) {
                                            final ratings = snapshot.docs
                                                .map((doc) => doc.data())
                                                .toList();
                                            // ignore: use_build_context_synchronously
                                            showModalBottomSheet<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: ratings
                                                        .map(
                                                            (rating) =>
                                                                ListTile(
                                                                  leading:
                                                                      StarsRating(
                                                                    rating:
                                                                        rating['rating']?.toDouble() ??
                                                                            0,
                                                                    onRatingChanged:
                                                                        (double
                                                                            ratingVal) {},
                                                                  ),
                                                                  title: Text(
                                                                      rating['username'] ??
                                                                          ''),
                                                                  subtitle: Text(
                                                                      rating['PublishDateTime']
                                                                              ?.toDate()
                                                                              .toString() ??
                                                                          ''),
                                                                ))
                                                        .toList(),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              0, 252, 250, 250),
                                        ),
                                        child: const Icon(Icons.person),
                                      ),
                                    ],
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
