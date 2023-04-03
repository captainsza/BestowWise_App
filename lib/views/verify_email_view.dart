import 'package:BestoWise/constants/routes.dart';
import 'package:BestoWise/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Images/Cave.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const Text(
                "we've sent you an email verification .please open it to verify your account",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "If you haven't recieve a verification email yet ,press the button below here",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                },
                child: const Text('Email verification'),
              ),
              TextButton(
                onPressed: () async {
                  await AuthService.firebase().logout();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text('Back to Register'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'If you verified your email then go to page ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    ' Login.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
