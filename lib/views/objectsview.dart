import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class UserObjectScreen extends StatelessWidget {
  UserObjectScreen({super.key});
  User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objects Added By User'),
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

          return ListView.builder(
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
                  title: Text(objects[index].data()['name']),
                  subtitle: Text(objects[index].data()['category']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to the object details page
                    // You can customize this according to your needs
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
