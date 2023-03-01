import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/usercreated/createbyuser.dart';
import 'package:allinbest/views/body_ratingview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enum/menu_action.dart';

class RatingView extends StatefulWidget {
  const RatingView({Key? key, required bool isDarkMode});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  bool isDarkMode = false;
  late String appBarImageAssetPath;

  @override
  void initState() {
    super.initState();
    appBarImageAssetPath =
        'assets/Images/back.png'; // default to light mode image
  }

  @override
  Widget build(BuildContext context) {
    if (isDarkMode) {
      appBarImageAssetPath = 'assets/Images/darkapp.png';
    } else {
      appBarImageAssetPath = 'assets/Images/back.png';
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'All in Best',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'All In Best',
          ),
          flexibleSpace: Image(
            image: AssetImage(appBarImageAssetPath),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: isDarkMode
                  ? const Icon(Icons.wb_sunny)
                  : const Icon(Icons.nightlight_round),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            PopupMenuButton<MenuAction>(
              icon: const Icon(CupertinoIcons.profile_circled),
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout,
                          color: Colors.deepPurple, // Change the icon color
                        ),
                        SizedBox(width: 3), // Add some spacing
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 10, // Change the font size
                            fontWeight: FontWeight.bold, // Add some boldness
                            color: Colors.black, // Change the text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: const CategoryBody(),
        floatingActionButton: const UserAdd(),
      ),
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
