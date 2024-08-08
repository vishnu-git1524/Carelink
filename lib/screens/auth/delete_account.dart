import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../api/apis.dart';
import '../auth/login_screen.dart';

class DeleteAccount extends StatefulWidget {
  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  bool isVerifying = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              PhosphorIcons.user_minus,
              size: 80,
              color: Colors.redAccent,
            ),
            SizedBox(height: 30),
            Text(
              'Your app data will also be deleted and you won’t be able to retrieve it.\n'
              'Since this is a security-sensitive operation, you will eventually be asked to log in before your account can be deleted.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 30),
            isVerifying
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                : SizedBox.shrink(),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                setState(() {
                  isVerifying = true;
                });
                await deleteUserAccount();
                setState(() {
                  isVerifying = false;
                });
              },
              child: Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteUserAccount() async {
    try {
      await APIs.deleteUserDocuments(); // Delete user documents first
      await FirebaseAuth.instance.currentUser!.delete();
      APIs.auth = FirebaseAuth.instance;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
     

      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
     
      // Handle general exception
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData =
          FirebaseAuth.instance.currentUser?.providerData.first;

      if (providerData != null) {
        if (providerData.providerId == GoogleAuthProvider.PROVIDER_ID) {
          final googleProvider = GoogleAuthProvider();
          final result = await FirebaseAuth.instance.currentUser!
              .reauthenticateWithProvider(googleProvider);

          if (result.user != null) {
            await APIs.deleteUserDocuments();
            await FirebaseAuth.instance.currentUser!.delete();
            APIs.auth = FirebaseAuth.instance;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        }
      }
    } catch (e) {
      ;
      // Handle exceptions
    }
  }
}
