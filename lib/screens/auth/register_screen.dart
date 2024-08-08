import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../models/chat_user.dart';
import '../home.dart';
import './password_reset_screen.dart';
import 'terms_and_conditions_page.dart';
import 'verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isChecked = false;
  bool _isObscure = true;
  bool isLoginMode = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? passwordError;
  late String currentDeviceId = '';

  @override
  void initState() {
    loadInfo();
    super.initState();
  }

  String getWelcomeMessage() {
    return isLoginMode ? 'Welcome back!' : 'Welcome to Atlas!';
  }

  Future<void> loadInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      currentDeviceId = androidInfo.id;
    });
  }

  Future<void> _registerWithEmailPassword() async {
    try {
      if (!isChecked) {
        _showSnackBar('Please accept the terms and conditions to continue!');
        return;
      }

      _showProgressBar();

      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      if (!await _checkInternetConnectivity()) {
        _showSnackBar(
            'No internet connection. Please check your network settings.');
        _hideProgressBar();
        return;
      }

      if (isLoginMode) {
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          User? user = userCredential.user;
          if (user != null) {
            // Check if current device is blocked
            bool isDeviceBlocked = await checkIfDeviceBlocked();

            if (isDeviceBlocked) {
              _showSnackBar('This device is blocked. Login not allowed.');
              await FirebaseAuth.instance.signOut();
              FirebaseAuth.instance;
              Navigator.pop(context);
            } else {
              _navigateToHomeScreen(context);
            }
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            setState(() {
              passwordError = 'Wrong password. Please try again.';
            });
          } else {
            _showSnackBar('Error during login: $e');
          }
          _hideProgressBar();
        }
      } else {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(name);
          // await user.sendEmailVerification();
        }

        final time = DateTime.now().millisecondsSinceEpoch.toString();
        final chatUser = ChatUser(
          id: user!.uid,
          name: name,
          ghostMode: false,
          email: email,
          about: "Hey, I'm using Atlas!",
          image: 'https://robohash.org/${name}',
          createdAt: time,
          isOnline: false,
          lastActive: time,
          pushToken: '',
          isTyping: false,
          crypticMode: false,
          latitude: 0.0,
          longitude: 0.0,
          devices: [],
        );

        final userRef = APIs.firestore.collection('users').doc(user.uid);
        await userRef.set(chatUser.toJson());

        _navigateToHomeScreen(context);
      }
    } catch (e) {
      _showSnackBar(
          'Error during ${isLoginMode ? "login" : "registration"}: $e');
      _hideProgressBar();
    }
  }

  Future<bool> checkIfDeviceBlocked() async {
    bool isBlocked = false;
    try {
      // Fetch blocked devices for the current user
      QuerySnapshot blockedDevicesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('blocked_devices')
          .where('device_id', isEqualTo: currentDeviceId)
          .get();

      // Check if current device ID exists in blocked_devices collection
      if (blockedDevicesSnapshot.size > 0) {
        isBlocked = true;
      }
    } catch (e) {
      print('Error checking blocked devices: $e');
      // Handle error if needed
    }
    return isBlocked;
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      await InternetAddress.lookup('google.com');
      return true;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _handleTermsAndConditionsLink() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsAndConditionsPage(
          appName: "Atlas",
        ),
      ),
    );
  }

  void _switchAuthMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      passwordError = null;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      isChecked = false;
      FocusScope.of(context).unfocus();
    });
  }

  void _showSnackBar(String message) {
    Dialogs.showSnackBar(context, message);
  }

  void _showProgressBar() {
    Dialogs.showProgressBar(context);
  }

  void _hideProgressBar() {
    Navigator.pop(context);
  }

  void _navigateToHomeScreen(BuildContext context) {
    if (APIs.auth.currentUser!.emailVerified == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => VerificationScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Define your password regex here
    // This regex requires at least 8 characters, including one uppercase letter, one lowercase letter, and one digit.
    RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

    if (!passwordRegex.hasMatch(value)) {
      return 'Invalid password format';
    }

    return null; // Return null if the password is valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isLoginMode ? 'Login' : 'Sign Up',
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/chat_icon.png',
                  height: 100,
                ),
                SizedBox(height: 20),
                // Text(getWelcomeMessage(), // Display welcome message here
                //     style: TextStyle(
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold,
                //     )),
                // SizedBox(height: 20),
                if (!isLoginMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: !isLoginMode
                      ? TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              child: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                          validator: _validatePassword,
                        )
                      : TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              child: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                if (isLoginMode)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PasswordReset()),
                      );
                    },
                    child: Text(
                      'Forgot Password!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      passwordError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                // SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: _handleTermsAndConditionsLink,
                      child: Text(
                        'I accept the terms and conditions',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _registerWithEmailPassword,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  icon: Icon(
                    isLoginMode ? Icons.login : Icons.person_add,
                    size: 20,
                  ),
                  label: Text(
                    isLoginMode ? 'Login' : 'Sign Up',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    isLoginMode
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
