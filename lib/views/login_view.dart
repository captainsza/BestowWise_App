import 'package:allinbest/constants/routes.dart';
import 'package:allinbest/services/auth/auth_exceptions.dart';
import 'package:allinbest/services/auth/auth_service.dart';

import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          Image.asset(
            'assets/Images/undraw_Mobile_login_re_9ntv.png',
            height: 200,
            scale: 2.5,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Enter your Email',
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Enter password',
                  ),
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  color: Colors.deepPurple,
                  child: ElevatedButton(
                    onPressed: () async {
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
                    child: const Text(
                      'login',
                      style: TextStyle(
                        color: Colors.white,
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
          ),
        ],
      ),
    );
  }
}
