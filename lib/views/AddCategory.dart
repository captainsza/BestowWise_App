import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String _categoryName;
  late File _categoryImage;

  get addCategory => null;

  void _chooseImage() async {
    var image = await addCategory.pickImage(source: ImageSource.gallery);
    setState(() {
      _categoryImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Category"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Category Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a category name";
                  }
                  return null;
                },
                onSaved: (value) {
                  _categoryName = value!;
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: _categoryImage == null
                  ? Center(
                      child: TextButton(
                        onPressed: _chooseImage,
                        child: const Text("Choose Image"),
                      ),
                    )
                  : Image.file(_categoryImage),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: const Text("Save"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Save the category to Firebase here
                    // ...
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
