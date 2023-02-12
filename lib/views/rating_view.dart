import 'package:allinbest/services/auth/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enum/menu_action.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class RatingView extends StatefulWidget {
  const RatingView({super.key});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('All In Best'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logout();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          )
        ],
      ),
      body: const Center(),
      floatingActionButton: SpeedDial(
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

                var cat = await databaseReference.child(categoryId!).set({
                  "name": "New Category",
                  "subjects": [
                    'hi my name is dude',
                  ],
                });
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.reviews, color: Colors.white),
              label: 'Add new category object',
              backgroundColor: Colors.deepPurple,
              onTap: () {},
            ),
          ]),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('sign out'),
        content: const Text('User you want to Sign ou'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Icon(Icons.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Icon(Icons.logout),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
