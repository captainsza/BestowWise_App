import 'package:allinbest/constants/routes.dart';
import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/views/login_view.dart';
import 'package:allinbest/views/rating_view.dart';
import 'package:allinbest/views/register_view/register_view.dart';
import 'package:allinbest/views/verify_email_view.dart';

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'All in Best',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        RegisterRoute: (context) => const RegisterView(),
        RatingRoute: (context) => const RatingView(),
        VerifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const RatingView();
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
