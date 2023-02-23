import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

import '../stream/RatingStream.dart';

// ...
class UserAdd extends StatefulWidget {
  const UserAdd({super.key});

  @override
  State<UserAdd> createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  String? index;
  List<String> categoryNames = [];
  List<String> objNames = [];

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
                  FirebaseDatabase.instance.ref().child("categories");

              final categoryId = databaseReference.push().key;

              String categoryName = '';
              List<String> categorySubjects = [];

              // Get user input for the category name
              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Enter Category Name'),
                    content: TextField(
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
              // Get user input for the category subjects
              if (validateCategoryName(categoryName)) {
                // Add category name to list of existing names
                categoryNames.add(categoryName);
                // Get user input for the category subjects
                // ignore: use_build_context_synchronously
                await showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Role of Category'),
                      content: TextField(
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
                // Add the new category to the Firebase database
                await databaseReference.child(categoryId!).set({
                  "index": index,
                  "name": categoryName,
                  "subjects": categorySubjects,
                });
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.reviews, color: Colors.white),
            label: 'Add Your liked Entity',
            backgroundColor: Colors.deepPurple,
            onTap: () async {
              final databaseReference = FirebaseDatabase.instance
                  .ref()
                  .child("categories")
                  .child('object');
              final objId = databaseReference.push().key;
              String objName = '';
              List<String> objSubjects = [];
              String? imageUrl;
// Get user input for the object name and image
              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Enter Object Name'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (value) {
                            objName = value;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              final file = File(pickedFile.path);
                              final storageReference = FirebaseStorage.instance
                                  .ref()
                                  .child('images/$objName');
                              await storageReference.putFile(file);
                              imageUrl =
                                  await storageReference.getDownloadURL();
                            }
                          },
                          child: const Text('Select Image'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (validateobj(objName)) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );

// Get user input for the object category
              if (validateobj(objName)) {
                final categories = await getCategoryStream().first;
                final categoryNames = categories
                    .map((category) => category['name'] as String)
                    .toList();
                // ignore: use_build_context_synchronously
                final selectedCategoryIndex = await showDialog<int>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Select Category'),
                      content: DropdownButton<int>(
                        value: null,
                        isExpanded: true,
                        onChanged: (value) {
                          Navigator.of(context).pop(value);
                        },
                        items: categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(category['name'] as String),
                          );
                        }).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          child: const Text('CANCEL'),
                        ),
                      ],
                    );
                  },
                );
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedCategoryIndex);
                  },
                  child: const Text('OK'),
                );

                if (selectedCategoryIndex != null) {
                  final category = categories[selectedCategoryIndex];
                  final categoryId = category['id'];

                  // Add the new object to the Firebase database
                  await databaseReference.child(objId!).set({
                    "name": objName,
                    "subjects": objSubjects,
                    "imageUrl": imageUrl,
                    "category": categoryId,
                  });
                }
              }
            },
          ),
        ]);
  }
}
