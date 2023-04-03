import 'package:BestoWise/constants/routes.dart';
import 'package:BestoWise/services/auth/auth_exceptions.dart';
import 'package:BestoWise/services/auth/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utilities/deco.dart';
import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Lottie.asset(
              'assets/LOTTIES/register.json',
              height: 200,
            ),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: textInputDecoration.copyWith(
                      // hintText: 'Enter your Email',
                      labelText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: textInputDecoration.copyWith(
                      // hintText: 'Enter password',
                      labelText: 'Password',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      await AuthService.firebase().login(
                        email: email,
                        password: password,
                      );
                      final user = AuthService.firebase().currentUser;
                      if (user?.isEmailVerified ?? false) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.deepPurple,
                            content: Text(
                              'Welcome! to BestowWise',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          ratingRoute,
                          (route) => false,
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyEmailRoute,
                          (route) => true,
                        );
                      }
                    } on UserNOtFoundAuthException {
                      await showErrorDialog(
                        context,
                        'User Not Found',
                      );
                    } on WrongPasswordAuthException {
                      await showErrorDialog(
                        context,
                        'Given Passward is wrong',
                      );
                    } on GenericAuthException {
                      await showErrorDialog(
                        context,
                        'Authentication error',
                      );
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        )),
                    width: MediaQuery.of(context).size.width - 150,
                    height: 50,
                    // padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    // color: Colors.deepPurple,

                    child: const Center(
                      child: Text(
                        'login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Dont have an account?',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          registerRoute,
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          ' Signup.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
