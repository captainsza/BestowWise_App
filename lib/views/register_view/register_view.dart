import 'package:allinbest/constants/routes.dart';
import 'package:allinbest/services/auth/auth_exceptions.dart';
import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/style/deco.dart';
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
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: [
            TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                decoration:
                    textInputDecoration.copyWith(hintText: 'Enter Your Email')),
            TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Enter a new password',
                )),
            TextButton(
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text(
                'Already Register?Login here!',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
