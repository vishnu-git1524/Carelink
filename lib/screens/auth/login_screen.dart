import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../home.dart';
import './terms_and_conditions_page.dart';
import 'register_screen.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isChecked = false;
  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        // await APIs.storeDeviceInfo();
        // await APIs.getFirebaseMessagingToken();
        // log('\nUser: ${user.user}');
        // log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          if (APIs.auth.currentUser!.emailVerified == true) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Home()));
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => VerificationScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          await APIs.createUser().then((value) {
            if (APIs.auth.currentUser!.emailVerified == true) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Home()));
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => VerificationScreen()),
                (Route<dynamic> route) => false,
              );
            }
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      // log('\n_signInWithGoogle: $e');
      Dialogs.showSnackBar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }

  void _handleTermsAndConditionsLink() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TermsAndConditionsPage(
                appName: "Atlas",
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Atlas - Login"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/chat_icon.png',
              height: mq.height * 0.3,
            ),
            SizedBox(height: 32),
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
                  child: Text("I accept the terms and conditions"),
                ),
              ],
            ),
            SizedBox(height: 16),
            FloatingActionButton.extended(
              onPressed: isChecked ? _handleGoogleBtnClick : null,
              icon: Icon(Icons.security),
              label: Text("Sign in with Google"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegistrationScreen()),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          // textAlign: TextAlign.end,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Use Email",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              WidgetSpan(
                                child: Icon(
                                  Icons.lock,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
