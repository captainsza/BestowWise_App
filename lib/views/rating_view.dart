import 'package:BestoWise/services/auth/auth_service.dart';
import 'package:BestoWise/usercreated/SpeedDial.dart';
import 'package:BestoWise/views/body_ratingview.dart';
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
        appBar: PreferredSize(
          preferredSize: const Size(100, 50),
          child: SafeArea(
            child: AppBar(
              centerTitle: true,
              leading: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                child: userData?.image != null
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.transparent,
                            width: 5.0,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(userData!.image!),
                          radius: 18.0,
                          backgroundColor:
                              Colors.grey[300], // optional background color
                          foregroundColor:
                              Colors.black, // optional foreground color
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 5.0,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18.0,
                          backgroundColor:
                              Colors.grey[300], // optional background color
                          foregroundColor: Colors.black,
                          child: const Icon(
                              Icons.person), // optional foreground color
                        ),
                      ),
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
          ),
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

              // Lottie.asset('assets/LOTTIES/rateme.json')
            ],
          ),
        ),
        body: const CategoryBody(),
        floatingActionButton: const UserAdd(),
      ),
    );
  }
}
