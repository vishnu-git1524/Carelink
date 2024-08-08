import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../api/apis.dart';
import 'auth/login_screen.dart';
import '../helper/dialogs.dart';
import 'auth/register_screen.dart';
import 'auth/verification_screen.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String currentDeviceId = '';

  @override
  void initState() {
    super.initState();
    loadInfo();
    Future.delayed(const Duration(seconds: 2), () async {
      final isFingerprintEnabled = await _checkFingerprintEnabled();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _setSystemUIOverlayStyle();
      if (isFingerprintEnabled) {
        bool isBiometricAuthenticated = false;
        while (!isBiometricAuthenticated) {
          isBiometricAuthenticated = await _authenticateBiometric();
          if (isBiometricAuthenticated) {
            _openApp();
            return;
          } else {
            // Handle authentication failure (e.g., show a message)
          }
        }
      } else {
        _openApp();
      }
    });
  }

  void _setSystemUIOverlayStyle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  Future<bool> _checkFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprintEnabled') ?? false;
  }

  Future<bool> _authenticateBiometric() async {
    final localAuth = LocalAuthentication();
    final isAuthenticated = await localAuth.authenticate(
      localizedReason: 'Authenticate to access Atlas',
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );
    return isAuthenticated;
  }

  // void _openApp() {
  //   if (APIs.auth.currentUser != null) {
  //     if (APIs.auth.currentUser!.emailVerified == true) {
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (_) => Home()),
  //         (Route<dynamic> route) => false,
  //       );
  //     } else {
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (_) => VerificationScreen()),
  //         (Route<dynamic> route) => false,
  //       );
  //     }
  //   } else {
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (_) => LoginScreen()),
  //       (Route<dynamic> route) => false,
  //     );
  //     // Navigator.pushReplacement(
  //     //     context, MaterialPageRoute(builder: (_) => RegistrationScreen()));
  //   }
  // }

  void _openApp() async {
    bool isDeviceBlocked = await checkIfDeviceBlocked();

    if (APIs.auth.currentUser != null) {
      if (isDeviceBlocked) {
        Dialogs.showSnackBar(
            context, 'This device is blocked. Please contact support.');
        await APIs.auth.signOut();
        APIs.auth = FirebaseAuth.instance;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else if (APIs.auth.currentUser!.emailVerified == true) {
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
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (_) => RegistrationScreen()));
    }
  }

  Future<void> loadInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      currentDeviceId = androidInfo.id;
    });
  }

  Future<bool> checkIfDeviceBlocked() async {
    bool isBlocked = false;
    try {
      // Fetch blocked devices for the current user
      QuerySnapshot blockedDevicesSnapshot = await APIs.firestore
          .collection('users')
          .doc(APIs.auth.currentUser
              ?.uid) // Assuming you have a way to get the current user ID
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

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    _setSystemUIOverlayStyle(); // Ensure the style is set on build
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('assets/chat_icon.png'),
            ),
            Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Column(
                children: [
                  const Text(
                    'Welcome to Atlas ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Get Connected!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: .5,
                    ),
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

Future<void> _authenticateAndNavigate(BuildContext context) async {
  final localAuth = LocalAuthentication();
  try {
    bool authenticated = await localAuth.authenticate(
      localizedReason: 'Authenticate to unlock the app',
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    if (authenticated) {
      // If authenticated, navigate to another screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      // Handle case when authentication fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Authentication Failed'),
            content: const Text('Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    print('Authentication error: $e');
  }
}
