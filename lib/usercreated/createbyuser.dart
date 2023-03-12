import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth/currentuserprofile.dart';
import 'locationusing.dart';

// ...
class UserAdd extends StatefulWidget {
  const UserAdd({super.key});

  @override
  State<UserAdd> createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  String? index;
  List<String> categoryNames = [];
  List<String> objNames = []; // create instance here

// Function to check if category name is empty or already exists
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
    return SpeedDial(
      icon: Icons.add,
      backgroundColor: Colors.deepPurple,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.category, color: Colors.white),
          label: 'Add New Category',
          backgroundColor: Colors.deepPurple,
          onTap: () async {
            final databaseReference =
                FirebaseFirestore.instance.collection('categories');
            final categoryId = databaseReference.doc().id;

            String categoryName = '';
            List<String> categorySubjects = [];
            String? location = await getCurrentLocation();

            // Get user input for the category name
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
                    title: const Text('Role of Category'),
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
              // Add the new category to the Firestore database
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
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.reviews, color: Colors.white),
          label: 'Add Your liked Entity',
          backgroundColor: Colors.deepPurple,
          onTap: () async {
            final categories =
                await FirebaseFirestore.instance.collection('categories').get();
            final categoryNames =
                categories.docs.map((doc) => doc['name'] as String).toList();

            String objName = '';
            String? imageUrl;
            String? selectedCategory;
            String? location = await getCurrentLocation();

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
                                                      .child(
                                                          'images/$objName'); // append user's name to image path
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
                                                      .child(
                                                          'images/$objName'); // append user's name to image path
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
                                          };

                                          final categoryCollection =
                                              FirebaseFirestore.instance
                                                  .collection('categories')
                                                  .doc(selectedCategory)
                                                  .collection('objects');

                                          // Add the obj document to the selected category collection
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
        )
      ],
    );
  }
}
