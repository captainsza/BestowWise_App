import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/usercreated/createbyuser.dart';
import 'package:allinbest/views/body_ratingview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enum/menu_action.dart';

class RatingView extends StatefulWidget {
  const RatingView({super.key});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  get index => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'All In Best',
          ),
          flexibleSpace: const Image(
            image: AssetImage('assets/Images/back.png'),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            PopupMenuButton<MenuAction>(
              icon: const Icon(CupertinoIcons.profile_circled),
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
                    child: Text(
                      'Log Out',
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: const CategoryBody(),
        floatingActionButton: const UserAdd());
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
