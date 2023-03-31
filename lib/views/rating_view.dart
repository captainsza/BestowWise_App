import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/usercreated/createbyuser.dart';
import 'package:allinbest/views/body_ratingview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/routes.dart';
import '../services/auth/currentuserprofile.dart';
import '../stream/logoutdialog.dart';

class RatingView extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const RatingView({Key? key, required bool isDarkMode});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  UserData? userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isDarkMode = false;
  late String appBarImageAssetPath;

  @override
  void initState() {
    super.initState();
    appBarImageAssetPath = 'assets/Images/back.png';
    _loadUserData();
    // default to light mode image
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
      title: 'BestowWise',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            iconSize: 40,
            icon: const Icon(CupertinoIcons.line_horizontal_3_decrease_circle),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: const Text(
            'BestowWise',
          ),
          flexibleSpace: Image(
            image: AssetImage(appBarImageAssetPath),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            InkWell(
              onTap: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 40.0),
                child: Lottie.asset(
                  isDarkMode
                      ? 'assets/LOTTIES/lightmode.json' // Replace with your dark mode animation
                      : 'assets/LOTTIES/darkmode.json', // Replace with your light mode animation
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(appBarImageAssetPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Add other items in the drawer here
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.deepPurple),
                title: const Text('Log Out'),
                onTap: () async {
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logout();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
                },
              ),
              // const ExpansionTile(
              //   title: Text(
              //     'My List',
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => UserObjectScreen()),
              //     );
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(vertical: 8),
              //     child: const Text(
              //       'My Objects',
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),

              Lottie.asset('assets/LOTTIES/rateme.json')
            ],
          ),
        ),
        body: const CategoryBody(),
        floatingActionButton: const UserAdd(),
      ),
    );
  }
}
