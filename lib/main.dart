import 'package:BestoWise/constants/routes.dart';
import 'package:BestoWise/services/auth/auth_service.dart';
import 'package:BestoWise/utilities/locationpermission.dart';
import 'package:BestoWise/views/login_view.dart';
import 'package:BestoWise/views/rating_view.dart';
import 'package:BestoWise/views/register_view/register_view.dart';
import 'package:BestoWise/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MaterialApp(
      // showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      title: 'BestowWise',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        ratingRoute: (context) => const RatingView(isDarkMode: false),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLocationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _isLocationPermissionGranted = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocationPermissionGranted) {
      return const LocationPermissionScreen();
    } else {
      return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const RatingView(
                    isDarkMode: false,
                  );
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      );
    }
  }
}
