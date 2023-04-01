import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserObjectScreen extends StatefulWidget {
  const UserObjectScreen({Key? key, required this.user}) : super(key: key);

  final User? user;

  @override
  // ignore: library_private_types_in_public_api
  _UserObjectScreenState createState() => _UserObjectScreenState();
}

class _UserObjectScreenState extends State<UserObjectScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: "Search Objects",
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Objects Added By User'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
              });
            },
            icon: _isSearching
                ? const Icon(Icons.close)
                : const Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collectionGroup('objects')
            .where('useremail', isEqualTo: widget.user?.email)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> objects =
              snapshot.data!.docs;

          if (objects.isEmpty) {
            return const Center(
                child: Text('No Objects Added By This User Yet!',
                    style: TextStyle(fontSize: 18.0)));
          }

          if (_isSearching && _searchController.text.isNotEmpty) {
            objects = objects
                .where((object) => object
                    .data()['name']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          return Form(
            child: ListView.builder(
              itemCount: objects.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(objects[index].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    try {
                      final userEmail =
                          FirebaseAuth.instance.currentUser!.email!;
                      final addedByEmail = objects[index]
                          .data()['useremail']
                          .replaceAll(' ', '_');
                      if (userEmail == addedByEmail) {
                        await FirebaseFirestore.instance
                            .collection('categories')
                            .doc(objects[index].data()['category'])
                            .collection('objects')
                            .doc(objects[index].id)
                            .delete();

                        // Delete the image from Firebase Storage
                        final storageReference = FirebaseStorage.instance
                            .ref()
                            .child('images/${objects[index].data()['name']}');
                        await storageReference.delete();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "You can only delete objects you added.")));
                      }
                    } on FirebaseException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message.toString())));
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: ListTile(
                    title: Text(
                      objects[index].data()['name'],
                      style: const TextStyle(
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: Text(
                      objects[index].data()['category'],
                      style: const TextStyle(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
