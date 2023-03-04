import 'dart:io';

import 'package:allinbest/constants/routes.dart';
import 'package:allinbest/services/auth/auth_exceptions.dart';
import 'package:allinbest/services/auth/auth_service.dart';
import 'package:allinbest/utilities/deco.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _username;
  late final TextEditingController _city;

  File? _image;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _username = TextEditingController();
    _city = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();

    _city.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _username,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Username',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: textInputDecoration.copyWith(
                        // hintText: 'Enter Your Email',
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
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
                          // hintText: 'Enter a new password',
                          labelText: 'New Password',
                        )),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _image = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt),
                          const SizedBox(width: 10),
                          Text(
                            _image != null ? 'Image Selected' : 'Select Image',
                            style: TextStyle(
                              color:
                                  _image != null ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _city,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'City',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final email = _email.text;
                      final password = _password.text;
                      final name = _username.text;
                      final city = _city.text;
                      final image = _image;

                      try {
                        // create the user in Firebase Authentication
                        await AuthService.firebase().createUser(
                          email: email,
                          password: password,
                        );

                        // send email verification to the user
                        AuthService.firebase().sendEmailVerification();

                        // create the user document in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(email)
                            .set({
                          'email': email,
                          'name': name,
                          'city': city,
                        });

                        // upload the user's profile picture to Firebase Storage
                        if (image != null) {
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child('users')
                              .child(email)
                              .child('profile.jpg');
                          await ref.putFile(image);
                          final url = await ref.getDownloadURL();
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(email)
                              .update({'image': url});
                        }

                        // navigate to the email verification screen
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
                          'This email is already in use',
                        );
                      } on InvalidEmailAuthException {
                        await showErrorDialog(
                          context,
                          'Invalid email address',
                        );
                      } on GenericAuthException {
                        await showErrorDialog(
                          context,
                          'Failed to register',
                        );
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width - 150,
                      height: 50,
                      child: const Center(
                        child: Text(
                          'Sign Up',
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
      ),
    );
  }
}
