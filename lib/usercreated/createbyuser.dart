import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

// ...
class UserAdd extends StatefulWidget {
  const UserAdd({super.key});

  @override
  State<UserAdd> createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  get index => null;

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
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
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

              // Get user input for the category name and image
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final pickedFile =
                                    await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (pickedFile != null) {
                                  final file = File(pickedFile.path);
                                  final uploadTask = FirebaseStorage.instance
                                      .ref()
                                      .child('images/$objId.jpg')
                                      .putFile(file);
                                  final snapshot =
                                      await uploadTask.whenComplete(() {});
                                  final url =
                                      await snapshot.ref.getDownloadURL();
                                  imageUrl = url;
                                }
                              },
                              child: const Text('Gallery'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final pickedFile =
                                    await ImagePicker().pickImage(
                                  source: ImageSource.camera,
                                );
                                if (pickedFile != null) {
                                  final file = File(pickedFile.path);
                                  final uploadTask = FirebaseStorage.instance
                                      .ref()
                                      .child('images/$objId.jpg')
                                      .putFile(file);
                                  final snapshot =
                                      await uploadTask.whenComplete(() {});
                                  final url =
                                      await snapshot.ref.getDownloadURL();
                                  imageUrl = url;
                                }
                              },
                              child: const Text('Camera'),
                            ),
                          ],
                        ),
                      ],
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

              // Get user input for the category subjects
              // ignore: use_build_context_synchronously
              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Enter your summary about this thing:'),
                    content: TextField(
                      onChanged: (value) {
                        objSubjects = value.split(',');
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
              await databaseReference.child(objId!).set({
                "index": index,
                "name": objName,
                "subjects": objSubjects,
                "imageUrl": imageUrl,
              });
            },
          ),
        ]);
  }
}
