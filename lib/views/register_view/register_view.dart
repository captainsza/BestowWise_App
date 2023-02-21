import 'package:allinbest/constants/routes.dart';
import 'package:allinbest/services/auth/auth_exceptions.dart';
import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/utilities/deco.dart';
import 'package:flutter/material.dart';
import '../../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/Images/signup.png',
            height: 200,
            scale: 2.5,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Enter Your Email',
                  ),
                ),
                TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Enter a new password',
                    )),
                Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          await AuthService.firebase().createUser(
                            email: email,
                            password: password,
                          );
                          AuthService.firebase().sendEmailVerification();
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushNamed(verifyEmailRoute);
                        } on WeakPasswordAuthException {
                          await showErrorDialog(
                            context,
                            'Too weak password to use!',
                          );
                        } on EmailAlreadyInUSeAuthException {
                          await showErrorDialog(
                            context,
                            'This mail already in use',
                          );
                        } on InvalidEmailAuthException {
                          await showErrorDialog(
                            context,
                            'Its invalid email to use',
                          );
                        } on GenericAuthException {
                          await showErrorDialog(
                            context,
                            'Failed to register',
                          );
                        }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.deepPurple,
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
                        'Already have an account?',
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
