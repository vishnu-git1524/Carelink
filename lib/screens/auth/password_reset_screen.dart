import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helper/dialogs.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({Key? key}) : super(key: key);

  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final TextEditingController _emailController = TextEditingController();
  String? _resetMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetLink() async {
    try {
      // Check for internet connectivity
      if (!await _checkInternetConnectivity()) {
        _showSnackBar(
            'No internet connection. Please check your network settings.');
        return;
      }

      _showProgressBar();
      final String email = _emailController.text;
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _resetMessage =
            'Password reset link sent to $email. Check your email inbox.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _resetMessage = _mapFirebaseErrorToMessage(e.code);
      });
    } finally {
      _hideProgressBar();
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      await InternetAddress.lookup('google.com');
      return true;
    } on SocketException catch (_) {
      return false;
    }
  }

  String _mapFirebaseErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'User not found. Please check your email.';
      case 'invalid-email':
        return 'Invalid email address. Please check the format.';
      default:
        return 'Something went wrong. Please try again later.';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
      ),
      body: GestureDetector(
              onTap: () {
        // This code will unfocus any active text fields when the user taps outside
        FocusScope.of(context).unfocus();
      },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    // Add style for text input
                    // Example: fontSize, color, fontWeight, etc.
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sendPasswordResetLink,
                  child: Text('Send Reset Password Link'),
                ),
                if (_resetMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      _resetMessage!,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
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
