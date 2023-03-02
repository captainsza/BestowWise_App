import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/usercreated/createbyuser.dart';
import 'package:allinbest/views/body_ratingview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enum/menu_action.dart';
import '../services/auth/currentuserprofile.dart';

class RatingView extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const RatingView({Key? key, required bool isDarkMode});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  UserData? userData;

  bool isDarkMode = false;
  late String appBarImageAssetPath;

  @override
  void initState() {
    super.initState();
    appBarImageAssetPath = 'assets/Images/back.png';
    _loadUserData(); // default to light mode image
  }

  Future<void> _loadUserData() async {
    final currentUser = AuthService.firebase().currentUser;

    if (currentUser != null) {
      userData = await UserData.fetchUser(currentUser.email);
      setState(() {});
    } else {
      userData = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDarkMode) {
      appBarImageAssetPath = 'assets/Images/darkbar.jpg';
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
                      // ignore: use_build_context_synchronously
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
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName:
                    userData?.name != null ? Text(userData!.name) : null,
                accountEmail:
                    userData?.email != null ? Text(userData!.email) : null,
                currentAccountPicture: userData?.image != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(userData!.image!),
                      )
                    : null,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Images/OREKI.jfif'),
                    fit: BoxFit.cover,
                  ),
                ),
                otherAccountsPictures: [
                  userData?.city != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            child: Text(
                              userData!.city[0].toUpperCase(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ],
          ),
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
