import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserObjectScreen extends StatelessWidget {
  const UserObjectScreen({Key? key, required this.user}) : super(key: key);

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objects Added By User'),
        backgroundColor: Colors.deepPurple, // Set app bar color to deep purple
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collectionGroup('objects')
            .where('useremail', isEqualTo: user?.email)
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
                  onDismissed: (direction) {
                    // Delete the object from the database
                    FirebaseFirestore.instance
                        .collection('categories')
                        .doc(objects[index].data()['category'])
                        .collection('objects')
                        .doc(objects[index].id)
                        .delete();
                  },
                  child: ListTile(
                    title: TextFormField(
                      initialValue: objects[index].data()['name'],
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Colors
                              .deepPurple, // Set label color to deep purple
                        ),
                      ),
                      style: const TextStyle(
                        color:
                            Colors.deepPurple, // Set text color to deep purple
                      ),
                      onSaved: (newValue) {
                        // Save the new name to the database
                        FirebaseFirestore.instance
                            .collection('categories')
                            .doc(objects[index].data()['category'])
                            .collection('objects')
                            .doc(objects[index].id)
                            .update({'name': newValue});
                      },
                    ),
                    subtitle: Text(
                      objects[index].data()['category'],
                      style: const TextStyle(
                        color: Colors
                            .deepPurple, // Set subtitle color to deep purple
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.save),
                      color: Colors.deepPurple, // Set icon color to deep purple
                      onPressed: () {
                        // Save the changes to the database
                        Form.of(context).save();
                      },
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
