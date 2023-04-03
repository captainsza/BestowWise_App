import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arc_speed_dial/flutter_speed_dial_menu_button.dart';
import 'package:flutter_arc_speed_dial/main_menu_floating_action_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth/currentuserprofile.dart';
import '../views/objectsview.dart';
import 'locationusing.dart';

class UserAdd extends StatefulWidget {
  const UserAdd({Key? key}) : super(key: key);

  @override
  State<UserAdd> createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  bool _isShowDial = false;
  String? index;
  List<String> categoryNames = [];
  List<String> objNames = [];

  bool validateCategoryName(String categoryName) {
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name cannot be empty!'),
        ),
      );
      return false;
    } else if (categoryNames.contains(categoryName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name already exists!'),
        ),
      );
      return false;
    }
    return true;
  }

  bool validateobj(String objName) {
    if (objName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This entity name cannot be empty!'),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDialMenuButton(
      isShowSpeedDial: _isShowDial,
      updateSpeedDialStatus: (isShow) {
        _isShowDial = isShow;
      },
      isMainFABMini: false,
      mainMenuFloatingActionButton: MainMenuFloatingActionButton(
        child: const Icon(
          Icons.edit,
        ),
        onPressed: () {},
        focusColor: Colors.deepPurple,
        closeMenuChild: const Icon(Icons.close),
        closeMenuBackgroundColor: Colors.deepPurple,
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonWidgetChildren: <FloatingActionButton>[
        FloatingActionButton(
          onPressed: () async {
            final databaseReference =
                FirebaseFirestore.instance.collection('categories');
            final categoryId = databaseReference.doc().id;

            String categoryName = '';
            List<String> categorySubjects = [];
            String? location = await getCurrentLocation();

            // ignore: use_build_context_synchronously
            await showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Enter Category Name'),
                  content: TextField(
                    maxLength: 15,
                    onChanged: (value) {
                      categoryName = value;
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (validateCategoryName(categoryName)) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );

            if (validateCategoryName(categoryName)) {
              categoryNames.add(categoryName);

              // ignore: use_build_context_synchronously
              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Category Role'),
                    content: TextField(
                      maxLength: 100,
                      onChanged: (value) {
                        categorySubjects = value.split(',');
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );

              final user = await UserData.fetchUser(
                  FirebaseAuth.instance.currentUser!.email!);
              await databaseReference.doc(categoryId).set({
                "index": index,
                "name": categoryName,
                "subjects": categorySubjects,
                'publishDateTime': DateTime.now(),
                'addedBy': user?.name,
                "location": location,
                'useremail': user?.email,
              });
            }

            _isShowDial = !_isShowDial;
            setState(() {});
          },
          backgroundColor: Colors.orange,
          tooltip: 'Add Categories',
          child: const Icon(
            Icons.category,
          ),
        ),
        FloatingActionButton(
          tooltip: 'Add Your Entities',
          onPressed: () async {
            final categories =
                await FirebaseFirestore.instance.collection('categories').get();
            final categoryNames =
                categories.docs.map((doc) => doc['name'] as String).toList();

            String objName = '';
            String? imageUrl;
            String? selectedCategory;
            String? location = await getCurrentLocation();

            // ignore: use_build_context_synchronously
            LatLng? pickedLocation = await showLocationPicker(context);

            if (pickedLocation == null) {
              return;
            }

            // ignore: use_build_context_synchronously
            await showDialog<void>(
              context: context,
              builder: (context) {
                String searchTerm = '';
                List<String> filteredCategories = categoryNames;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Select a Category'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                searchTerm = value;
                                filteredCategories = categoryNames
                                    .where((name) => name
                                        .toLowerCase()
                                        .contains(searchTerm.toLowerCase()))
                                    .toList();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search categories...',
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: selectedCategory,
                            items: filteredCategories
                                .map((categoryName) => DropdownMenuItem(
                                      value: categoryName,
                                      child: Text(categoryName),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (selectedCategory != null) {
                              Navigator.of(context).pop();
                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title:
                                        const Text('Enter your good caption!'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          maxLength: 25,
                                          onChanged: (value) {
                                            objName = value;
                                          },
                                        ),
                                        const SizedBox(height: 20.0),
                                        TextButton(
                                          onPressed: () async {
                                            final pickedFile =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.gallery,
                                            );

                                            if (pickedFile != null) {
                                              final file =
                                                  File(pickedFile.path);
                                              final storageReference =
                                                  FirebaseStorage.instance
                                                      .ref()
                                                      .child('images/$objName');
                                              await storageReference
                                                  .putFile(file);
                                              imageUrl = await storageReference
                                                  .getDownloadURL();
                                            }
                                          },
                                          child: const Icon(Icons
                                              .add_photo_alternate_outlined),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final pickedFile =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.camera,
                                            );

                                            if (pickedFile != null) {
                                              final file =
                                                  File(pickedFile.path);
                                              final storageReference =
                                                  FirebaseStorage.instance
                                                      .ref()
                                                      .child('images/$objName');
                                              await storageReference
                                                  .putFile(file);
                                              imageUrl = await storageReference
                                                  .getDownloadURL();
                                            }
                                          },
                                          child: const Icon(
                                              Icons.add_a_photo_outlined),
                                        ),
                                        if (imageUrl != null)
                                          Image.network(imageUrl!),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final user = await UserData.fetchUser(
                                              FirebaseAuth.instance.currentUser!
                                                  .email!);
                                          final obj = {
                                            'name': objName,
                                            'category': selectedCategory,
                                            'image': imageUrl,
                                            'publishDateTime': DateTime.now(),
                                            'addedBy': user?.name,
                                            "location": location,
                                            'useremail': user?.email,
                                            'Mark_location': GeoPoint(
                                                pickedLocation.latitude,
                                                pickedLocation.longitude),
                                          };

                                          final categoryCollection =
                                              FirebaseFirestore.instance
                                                  .collection('categories')
                                                  .doc(selectedCategory)
                                                  .collection('objects');

                                          await categoryCollection.add(obj);

                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: const Text('Next'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add_card),
        ),
        FloatingActionButton(
          tooltip: 'Your List',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserObjectScreen(
                        user: null,
                      )),
            );
            _isShowDial = false;
            setState(() {});
          },
          backgroundColor: Colors.pink,
          child: const Icon(Icons.list),
        ),
      ],
      isSpeedDialFABsMini: true,
      paddingBtwSpeedDialButton: 30.0,
    );
  }
}
