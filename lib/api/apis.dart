import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:googleapis_auth/auth_io.dart' as authio;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';

import '../models/chat_user.dart';
import '../models/device.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static ChatUser me = ChatUser(
      id: user?.uid ?? '',
      ghostMode: false,
      name: user?.displayName?.toString() ?? '',
      email: user?.email?.toString() ?? '',
      about: "Hey, I'm using Atlas!",
      image: user?.photoURL?.toString() ?? '',
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '',
      isTyping: false,
      crypticMode: false,
      latitude: 0.0, // default value, update it with the actual value
      longitude: 0.0, // default value, update it with the actual value
      devices: []);

  static User get user => auth.currentUser!;

  // static Future<void> storeDeviceInfo() async {
  //   User? user = auth.currentUser;
  //   if (user == null) return;

  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  //   String deviceId = androidInfo.id ?? '';
  //   String deviceName = androidInfo.model ?? '';
  //   String model = androidInfo.model ?? '';
  //   String manufacturer = androidInfo.manufacturer ?? '';
  //   String device = androidInfo.device ?? '';

  //   String lastLogin = DateTime.now().toIso8601String();

  //   Device deviceInfoObj = Device(
  //     deviceId: deviceId,
  //     deviceName: deviceName,
  //     lastLogin: lastLogin,
  //     model: model,
  //     manufacturer: manufacturer,
  //     device: device, verified: false,
  //   );

  //   CollectionReference users = firestore.collection('users');
  //   DocumentReference userDoc = users.doc(user.uid);

  //   // Get the current user document
  //   DocumentSnapshot userSnapshot = await userDoc.get();

  //   // Update devices list
  //   if (userSnapshot.exists) {
  //     var userData = userSnapshot.data() as Map<String, dynamic>;
  //     var deviceList = userData['devices'] as List<dynamic>? ?? [];
  //     List<Device> devices =
  //         deviceList.map((device) => Device.fromJson(device)).toList();

  //     // Check if the device is already in the list
  //     bool deviceExists = devices.any((d) => d.deviceId == deviceId);

  //     if (!deviceExists) {
  //       // Add the new device to the list
  //       devices.add(deviceInfoObj);
  //     } else {
  //       // Update the last login time for the existing device
  //       devices = devices.map((d) {
  //         if (d.deviceId == deviceId) {
  //           return Device(
  //             deviceId: d.deviceId,
  //             deviceName: d.deviceName,
  //             lastLogin: lastLogin,
  //             model: d.model,
  //             manufacturer: d.manufacturer,
  //             device: d.device, verified: false,
  //           );
  //         }
  //         return d;
  //       }).toList();
  //     }

  //     await userDoc.update({
  //       'devices': devices.map((device) => device.toJson()).toList(),
  //     });
  //   } else {
  //     // If the user document doesn't exist, create it with the device info
  //     await userDoc.set({
  //       'devices': [deviceInfoObj.toJson()],
  //     });
  //   }
  // }

  static Future<void> storeDeviceInfo() async {
    User? user = auth.currentUser;
    if (user == null) return;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    String deviceId = androidInfo.id ?? '';
    String deviceName = androidInfo.model ?? '';
    String model = androidInfo.model ?? '';
    String manufacturer = androidInfo.manufacturer ?? '';
    String device = androidInfo.device ?? '';

    String lastLogin = DateTime.now().toIso8601String();

    // Default primaryDevice to false, will be updated if necessary
    Device deviceInfoObj = Device(
      deviceId: deviceId,
      deviceName: deviceName,
      lastLogin: lastLogin,
      model: model,
      manufacturer: manufacturer,
      device: device,
      verified: false,
      primaryDevice: false, isBlocked: false,
    );

    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(user.uid);

    // Get the current user document
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      var userData = userSnapshot.data() as Map<String, dynamic>;
      var deviceList = userData['devices'] as List<dynamic>? ?? [];
      List<Device> devices =
          deviceList.map((device) => Device.fromJson(device)).toList();

      // Check if the device is already in the list
      bool deviceExists = devices.any((d) => d.deviceId == deviceId);

      if (!deviceExists) {
        // If it's the first device, set primaryDevice to true
        if (devices.isEmpty) {
          deviceInfoObj.primaryDevice = true;
        }
        // Add the new device to the list
        devices.add(deviceInfoObj);
      } else {
        // Update the last login time for the existing device
        devices = devices.map((d) {
          if (d.deviceId == deviceId) {
            return Device(
              deviceId: d.deviceId,
              deviceName: d.deviceName,
              lastLogin: lastLogin,
              model: d.model,
              manufacturer: d.manufacturer,
              device: d.device,
              verified: d.verified,
              primaryDevice: d.primaryDevice, isBlocked: false,
            );
          }
          return d;
        }).toList();
      }

      await userDoc.update({
        'devices': devices.map((device) => device.toJson()).toList(),
      });
    } else {
      // If the user document doesn't exist, create it with the first device marked as primary
      deviceInfoObj.primaryDevice = true;
      await userDoc.set({
        'devices': [deviceInfoObj.toJson()],
      });
    }
  }

  static Future<void> blockDevice(String deviceId) async {
    try {
      // Add device ID to blocked_devices collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('blocked_devices')
          .add({
        'device_id': deviceId,
        'timestamp':
            Timestamp.now(), // Add timestamp or any other relevant data
      });
    } catch (e) {
      print('Error while blocking device: $e');
      // Handle error if needed
    }
  }

  // static Future<void> getFirebaseMessagingToken() async {
  //   try {
  //     await fMessaging.requestPermission();
  //     String? token = await fMessaging.getToken();

  //     if (token != null) {
  //       me.pushToken = token;
  //       log('Push Token: $token');
  //     } else {
  //       log('Failed to get Firebase Messaging token.');
  //     }
  //   } catch (e) {
  //     log('Error while getting Firebase Messaging token: $e');
  //   }
  // }

  static Future<void> getFirebaseMessagingToken() async {
    try {
      await fMessaging.requestPermission();
      String? token = await fMessaging.getToken();

      if (token != null) {
        me.pushToken = token;
        await firestore.collection('users').doc(user.uid).update({
          'push_token': token,
        });
        log('Push Token: $token');
      } else {
        log('Failed to get Firebase Messaging token.');
      }
    } catch (e) {
      log('Error while getting Firebase Messaging token: $e');
    }
  }

  static Future<void> getSelfInfo() async {
    try {
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        me = ChatUser.fromJson(userDoc.data()!);
        await getFirebaseMessagingToken();

        // For setting user status to active
        await updateActiveStatus(true);
        log('My Data: ${userDoc.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    } catch (e) {
      log('Error while getting self info: $e');
    }
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "atlas-edaca",
      "private_key_id": "4402a86b3a064f0274a98bdc0575853d77dbae0a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDIU9nZyRf78lwB\nQwF3FJZsqqngO4I9D7u3tzGOdhkaC5N5UNluB+9aCsekQKBtPkimRWgP86iB8UMw\n8QMK46A9WLPOXrNulHKQWEjKu4Gm8+p0j14gHvmFkvtYpNjOByVouTg8skn63KX8\nVx1wHdaHnYHxDgVM+uZYg5fK7df3qgzRuzWrfwTWCfZEuCYyPbVi7N/Yih9xU8rr\nTcIBEN7uEF90C9mO1isnGMcH2cukk/T7ymcXPd6afb0xFdgGS96TP9BhbQC1wDZR\nr2KlwxppPMC/Kj2gKhmFwlT3XKadQsp/HpY/6cVJb0FI9Ktwb/5sxdBYp/4Ns3TL\nFl4DpCPRAgMBAAECggEACRnyKFhgDBTPRElojCH10ZsRW7woZyDLXQXoLPpFmq7S\n9OyM7FhU8gjSWC6Ne1kckN1PZIYj7j9pV5RjmH+N/KuGg8Y+rbP13oP8TqWlNtIX\nIVOQKbJukLiETdszdGzTsMXVfcB15v1WVzgYAMuCPygTSsHh0MUHaRcVcuVKbhiJ\nlci8Zy/y7ZkxfvLRzCm+Ktbw+BpIIfXLYPE5VoBHZfXiDcujKDwFD+ASem91vNit\nk+EiKzWBk81Jb3KimUYSmfhuc6zVIDsjRM/xz+6HPFO0nqjsVrpP3Xc44yGmczFO\nTwempk1a34K09Hw7H51irdwRaE3nvJXtAW7MGDaCTwKBgQD18Bed6gTU3sVfSwMi\nKviOSzmnXU/wTrG0x5SKUwbYnVj3lXZenLVKsnm07QuFIW2xqrVIB9eOWXTzZSPf\ne4oADUqZM/2d4QTk7xkCqW2kzAm0S7pqhUnrB8S7+z0FfH/iZ/ikFOBJuk3Uf7dC\nwiL8xS43Ct6rIKNHyb8AClG9GwKBgQDQhgtwNmCZU/wlIMzPf0rMgeqxZ+dS7KUn\nDpBlkqUjT/YgJfjrB4WTIJDwnZV404DY9PBRivpt49h9upJQ73dLPSytmm5UFIw+\nsGwbILdfyb28arTSfXrOLDfGQ9N9HdvtF13b/WHaZ5LgR/+qz7PapHnI0Vlgd+dq\nD9h2AQINgwKBgAI/cofP9sFXU+h+EAZE7Eaoq1s7QBrLLVagqFvnTF24enKw3Acb\nWZDYNsKPlBZgatc/3y5MXA0CBk6fMwe84lMDzBXAYuYJg3jwMoNStxzVfJU4R/jn\nRPiv9n1dW35sV+Li3mPpiO9Dk6iIjk0+5wD2cGiyYbygrL1gO62tanfXAoGAHFse\nExRR7ofNMf9T2qOkuEqyb42Bl3U2wCjq2eUnL7Yf8h83yj4rm+ZBz3aebN/WFaq5\nQ11y0J67Qd2tJ/RodILNII5vkl948s1q5gV86jm043pfPIBzwrWgoAV5LPpyfbs/\nuDqso9aR0o335nJ4MrNLHFPbo5KqlXGyLdnVPaECgYEAhS7Suyskuw8B/VLlBDG0\nu5jJXMivVypjRo5Ot+CTwZge3SFbs/vQDa0NosOPtLIBtpuQCT9lwjKJXr2sYSL8\nSKRkhBXh3bvF1R8/OneWiLRawcKXtXZ6EIsrDuFaO1qE0GVsG/+tYRhE7RUtwwPv\nKvLiP34acg21O9EGmQYplEw=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-v4nd7@atlas-edaca.iam.gserviceaccount.com",
      "client_id": "117526301158271543931",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-v4nd7%40atlas-edaca.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await authio.clientViaServiceAccount(
        authio.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    authio.AccessCredentials credentials =
        await authio.obtainAccessCredentialsViaServiceAccount(
            authio.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  // static Future<void> sendPushNotification(
  //     ChatUser chatUser, String msg) async {
  //   final String serverKey = await getAccessToken();

  //   final fcmEndpoint =
  //       'https://fcm.googleapis.com/v1/projects/atlas-edaca/messages:send';
  //   final url = Uri.parse(fcmEndpoint);

  //   final body = {
  //     "message": {
  //       "token": chatUser.pushToken,
  //       "notification": {"body": msg, "title": me.name}
  //     }
  //   };

  //   final headers = {
  //     HttpHeaders.contentTypeHeader: 'application/json',
  //     HttpHeaders.authorizationHeader: 'Bearer $serverKey',
  //   };

  //   try {
  //     final response =
  //         await http.post(url, headers: headers, body: jsonEncode(body));

  //     if (response.statusCode == 200) {
  //       print('Push notification sent successfully!');
  //     } else {
  //       print('Push notification failed. Status code: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //     }
  //   } catch (error) {
  //     print('Error sending push notification: $error');
  //   }
  // }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    final String serverKey = await getAccessToken();

    final fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/atlas-edaca/messages:send';
    final url = Uri.parse(fcmEndpoint);

    final body = {
      "message": {
        "token": chatUser.pushToken,
        "notification": {"body": msg, "title": me.name},
        "data": {"chatUser": jsonEncode(chatUser.toJson())}
      }
    };

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $serverKey',
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        print('Push notification sent successfully!');
      } else {
        print('Push notification failed. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error sending push notification: $error');
    }
  }

  static Future<bool> userExists() async {
    try {
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      return userDoc.exists;
    } catch (e) {
      log('Error while checking user existence: $e');
      return false;
    }
  }

  static Future<bool> addChatUser(String email) async {
    try {
      final userSnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userDoc = userSnapshot.docs.first;

        if (userDoc.id != user.uid) {
          // User exists and is not the current user
          final currentUserRef = firestore
              .collection('users')
              .doc(user.uid)
              .collection('my_users')
              .doc(userDoc.id);

          final otherUserRef = firestore
              .collection("users")
              .doc(userDoc.id)
              .collection("my_users")
              .doc(user.uid);

          await Future.wait([
            currentUserRef.set({}),
            otherUserRef.set({}),
          ]);

          return true;
        }
      }
      // User doesn't exist or is the current user
      return false;
    } catch (e) {
      log('Error while adding chat user: $e');
      return false;
    }
  }

  static Future<void> updateLocation(double latitude, double longitude) async {
    try {
      final userRef = firestore.collection('users').doc(user.uid);
      await userRef.update({
        'latitude': latitude,
        'longitude': longitude,
      });
      log('Location updated successfully!');
    } catch (e) {
      log('Error while updating location: $e');
    }
  }

  static Future<User?> getCurrentUser() async {
    User? currentUser = auth.currentUser;
    return currentUser;
  }

  Future<ChatUser?> getUserDetails() async {
    User? currentUser = await getCurrentUser();

    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firestore.collection('users').doc(currentUser.uid).get();

      return ChatUser.fromJson(documentSnapshot.data());
    } else {
      return null; // or handle the case when the user is not signed in
    }
  }

  static Future<bool> removeChatUser(String userId) async {
    try {
      final currentUserRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(userId);

      final otherUserRef = firestore
          .collection("users")
          .doc(userId)
          .collection("my_users")
          .doc(user.uid);

      await Future.wait([
        currentUserRef.delete(),
        otherUserRef.delete(),
      ]);

      return true;
    } catch (e) {
      log('Error while removing chat user: $e');
      return false;
    }
  }

  static Future<bool> isUserInList(String userId) async {
    try {
      final currentUserRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(userId);

      final currentUserDoc = await currentUserRef.get();

      return currentUserDoc.exists;
    } catch (e) {
      log('Error while checking if the user is in the list: $e');
      return false;
    }
  }

  static Future<void> createUser() async {
    try {
      final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName?.split(' ').first ?? '',
        email: user.email!,
        about: "Hey, I'm using Atlas!",
        image: user.photoURL!,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        isOnline: false,
        lastActive: '',
        pushToken: '',
        isTyping: false,
        crypticMode: false,
        latitude: 0.0,
        ghostMode: false,
        longitude: 0.0,
        devices: [],
      );

      final userRef = firestore.collection('users').doc(user.uid);
      await userRef.set(chatUser.toJson());

      print('User data added to Firestore successfully.');
    } catch (e, stackTrace) {
      print('Error creating user: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  static Future<void> deleteUserDocuments() async {
    try {
      final userRef = firestore.collection('users').doc(user.uid);
      final subCollections = await userRef.collection('my_users').get();
      for (var doc in subCollections.docs) {
        await userRef.collection('my_users').doc(doc.id).delete();
      }
      await userRef.delete();
      print('User documents deleted successfully.');
    } catch (e) {
      log('Error while deleting user documents: $e');
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  // static Future<void> sendFirstMessage(
  //     ChatUser chatUser, String msg, Type type) async {
  //   try {
  //     await firestore
  //         .collection('users')
  //         .doc(chatUser.id)
  //         .collection('my_users')
  //         .doc(user.uid)
  //         .set({});

  //     await sendMessage(chatUser, msg, type);
  //   } catch (e) {
  //     log('Error while sending the first message: $e');
  //   }
  // }

  static Future<void> updateUserInfo() async {
    try {
      await firestore.collection('users').doc(user.uid).update({
        'name': me.name,
        'about': me.about,
      });
    } catch (e) {
      log('Error while updating user info: $e');
    }
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    try {
      await firestore.collection('users').doc(user.uid).update({
        'is_online': isOnline,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me.pushToken,
      });
    } catch (e) {
      log('Error while updating active status: $e');
    }
  }

  static Future<void> updateGhostModeStatus(bool ghostMode) async {
    try {
      await firestore.collection('users').doc(user.uid).update({
        'ghost_mode': ghostMode,
      });
    } catch (e) {
      log('Error while updating active status: $e');
    }
  }

  static Future<List<ChatUser>> getOnlineUsers() async {
    List<ChatUser> onlineUsers = [];

    try {
      // Get the documents in the current user's my_users collection
      final myUsersSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .get();

      // Get the user IDs from the my_users documents
      List<String> userIds = myUsersSnapshot.docs.map((doc) => doc.id).toList();

      if (userIds.isNotEmpty) {
        // Query users who are online
        final usersSnapshot = await firestore
            .collection('users')
            .where('id', whereIn: userIds)
            .where('is_online', isEqualTo: true)
            .where('gohst_mode', isEqualTo: false)
            .get();

        // Convert the documents to ChatUser objects
        for (var doc in usersSnapshot.docs) {
          onlineUsers.add(ChatUser.fromJson(doc.data()));
        }
      }
    } catch (e) {
      log('Error while getting online users: $e');
    }

    return onlineUsers;
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  // Function to get conversation ID
//   static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
//       ? '${user.uid}_$id'
//       : '${id}_${user.uid}';

// // Function to get all messages of a specific conversation from Firestore database
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
//       ChatUser user) {
//     return firestore
//         .collection('chats/${getConversationID(user.id)}/messages/')
//         .orderBy('sent', descending: true)
//         .snapshots();
//   }

  // static Future<void> sendMessage(ChatUser chatUser, String msg, Type? type,
  //     {bool secretmsg = false}) async {
  //   try {
  //     final time = DateTime.now().millisecondsSinceEpoch.toString();

  //     final Message message = Message(
  //       toId: chatUser.id,
  //       msg: msg,
  //       read: '',
  //       type: type!,
  //       fromId: user.uid,
  //       sent: time,
  //       flagged: false,
  //       liked: false,
  //       secretmsg: secretmsg, // Add the secretmsg field here
  //     );

  //     final ref = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/');
  //     await ref.doc(time).set(message.toJson()).then((value) async {
  //       sendPushNotification(
  //           chatUser,
  //           type == Type.text
  //               ? Encryption.decrypt(msg)
  //               : type == Type.image
  //                   ? 'image'
  //                   : type == Type.gif
  //                       ? 'Gif'
  //                       : type == Type.video
  //                           ? 'video'
  //                           : type == Type.file
  //                               ? 'Document'
  //                               : '');
  //       // Store notification only if message is not sent by the current user
  //       // if (user.uid != chatUser.id) {
  //       //   await storeNotification(chatUser, msg, time);
  //       // }
  //     });
  //   } catch (e) {
  //     log('Error while sending message: $e');
  //     rethrow;
  //   }
  // }

  // static Future<int> getUnreadMessagesCount(String userId) async {
  //   try {
  //     final snapshot = await firestore
  //         .collection('chats/${getConversationID(userId)}/messages/')
  //         .where('read', isEqualTo: '')
  //         .where('toId', isEqualTo: user.uid)
  //         .get();
  //     return snapshot.docs.length;
  //   } catch (e) {
  //     log('Error while fetching unread messages count: $e');
  //     rethrow;
  //   }
  // }

  // static Future<void> sendReplyMessage(
  //     ChatUser chatUser, Message replyingToMessage, String replyMsg, Type? type,
  //     {bool secretmsg = false}) async {
  //   try {
  //     final time = DateTime.now().millisecondsSinceEpoch.toString();

  //     final Message message = Message(
  //       toId: chatUser.id,
  //       msg: replyMsg,
  //       read: '',
  //       type: type!,
  //       fromId: user.uid,
  //       sent: time,
  //       flagged: false,
  //       liked: false,
  //       secretmsg: secretmsg,
  //       replyToMessage:
  //           replyingToMessage.msg, // Include the message being replied to
  //     );

  //     final ref = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/');
  //     await ref.doc(time).set(message.toJson()).then((value) async {
  //       sendPushNotification(
  //           chatUser,
  //           type == Type.text
  //               ? Encryption.decrypt(replyMsg)
  //               : type == Type.image
  //                   ? 'image'
  //                   : type == Type.gif
  //                       ? 'Gif'
  //                       : type == Type.video
  //                           ? 'video'
  //                           : type == Type.file
  //                               ? 'Document'
  //                               : '');
  //     });
  //   } catch (e) {
  //     log('Error while sending reply message: $e');
  //     rethrow;
  //   }
  // }

  // static Future<void> sendMessageToMultipleUsers(
  //     List<ChatUser> chatUsers, String msg, Type type,
  //     {bool secretmsg = false}) async {
  //   try {
  //     final time = DateTime.now().millisecondsSinceEpoch.toString();

  //     // Create the message object once
  //     final Message message = Message(
  //       toId: '', // To be set for each user
  //       msg: msg,
  //       read: '',
  //       type: type,
  //       fromId: user.uid,
  //       sent: time,
  //       flagged: false,
  //       liked: false,
  //       secretmsg: secretmsg, // Add the secretmsg field here
  //     );

  //     for (ChatUser chatUser in chatUsers) {
  //       message.toId = chatUser.id;
  //       final ref = firestore
  //           .collection('chats/${getConversationID(chatUser.id)}/messages/');
  //       await ref.doc(time).set(message.toJson());

  //       sendPushNotification(
  //           chatUser,
  //           type == Type.text
  //               ? Encryption.decrypt(msg)
  //               : type == Type.image
  //                   ? 'image'
  //                   : type == Type.gif
  //                       ? 'Gif'
  //                       : type == Type.video
  //                           ? 'video'
  //                           : type == Type.file
  //                               ? 'Document'
  //                               : '');
  //       // Store notification only if message is not sent by the current user
  //       // if (user.uid != chatUser.id) {
  //       //   await storeNotification(chatUser, msg, time);
  //       // }
  //     }
  //   } catch (e) {
  //     log('Error while sending message to multiple users: $e');
  //     rethrow;
  //   }
  // }

  // static Future<List<ChatUser>> getUsersWithUnreadMessages() async {
  //   List<ChatUser> usersWithUnreadMessages = [];

  //   try {
  //     // Query messages where the current user is the recipient and 'read' field is not equal to user.uid
  //     final messagesSnapshot = await firestore
  //         .collectionGroup('messages')
  //         .where('toId', isEqualTo: user.uid)
  //         .where('read',
  //             isEqualTo:
  //                 '') // assuming 'read' is the field indicating read status
  //         .get();

  //     // Extract unique user IDs from the messages
  //     Set<String> userIds = {};
  //     messagesSnapshot.docs.forEach((doc) {
  //       userIds
  //           .add(doc.data()['fromId']); // assuming 'fromId' is the sender's ID
  //     });

  //     // Retrieve user details for each unique user ID
  //     await Future.forEach(userIds, (userId) async {
  //       final userDoc = await firestore.collection('users').doc(userId).get();
  //       if (userDoc.exists) {
  //         usersWithUnreadMessages.add(ChatUser.fromJson(userDoc.data()!));
  //       }
  //     });
  //   } catch (e) {
  //     log('Error while getting users with unread messages: $e');
  //   }

  //   return usersWithUnreadMessages;
  // }

// Function to store a notification
  static Future<void> storeNotification(
      ChatUser chatUser, message, String time) async {
    final notificationData = {
      'fromId': user.uid,
      'message': message,
      'sent': time,
      'read': false,
    };
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('notifications')
        .doc(time)
        .set(notificationData);
  }

// Function to update read status of a message
//   static Future<void> updateMessageReadStatus(Message message) async {
//     try {
//       await firestore
//           .collection('chats/${getConversationID(message.fromId)}/messages/')
//           .doc(message.sent)
//           .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
//     } catch (e) {
//       log('Error while updating message read status: $e');
//       // Handle the error as needed.
//       // For example, you might want to show an error message to the user.
//     }
//   }

// // Function to get only the last message of a specific chat
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
//       ChatUser user) {
//     return firestore
//         .collection('chats/${getConversationID(user.id)}/messages/')
//         .orderBy('sent', descending: true)
//         .limit(1)
//         .snapshots();
//   }

// // Function to send a chat image
//   static Future<void> sendChatImage(ChatUser chatUser, File file) async {
//     final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     try {
//       final ext = file.path.split('.').last;

//       final compressedImageData = await FlutterImageCompress.compressWithFile(
//         file.absolute.path,
//         quality: 80,
//       );

//       final ref = storage.ref().child(
//             'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
//           );

//       final uploadTask = ref.putData(
//           compressedImageData!, SettableMetadata(contentType: 'image/$ext'));
//       await showUploadProgressNotification(
//           notificationId, 'Sending Image', uploadTask);
//       final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

//       log('Data Transferred: ${taskSnapshot.bytesTransferred / 1000} kb');

//       final imageUrl = await ref.getDownloadURL();
//       await sendMessage(chatUser, imageUrl, Type.image);
//     } catch (e) {
//       log('Error while sending chat image: $e');
//       rethrow;
//     }
//   }

//   static Future<void> sendChatAudio(ChatUser chatUser, File file) async {
//     final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     try {
//       final ext = file.path.split('.').last;

//       final ref = storage.ref().child(
//             'audio/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
//           );

//       final uploadTask =
//           ref.putFile(file, SettableMetadata(contentType: 'audio/$ext'));
//       await showUploadProgressNotification(
//           notificationId, 'Sending Audio', uploadTask);
//       final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

//       log('Data Transferred: ${taskSnapshot.bytesTransferred / 1000} kb');

//       final audioUrl = await ref.getDownloadURL();
//       await sendMessage(chatUser, audioUrl, Type.audio);
//     } catch (e) {
//       log('Error while sending chat audio: $e');
//       rethrow;
//     }
//   }

// Function to delete a message
  // static Future<void> deleteMessage(Message message) async {
  //   try {
  //     final messageDocRef = firestore
  //         .collection('chats/${getConversationID(message.toId)}/messages/')
  //         .doc(message.sent);

  //     await messageDocRef.delete();

  //     // Delete associated media file if message type is image or video
  //     if (message.type == Type.image || message.type == Type.video) {
  //       final storageRef = storage.refFromURL(message.msg);
  //       final storageFileExists = await storageRef
  //           .getMetadata()
  //           .then((metaData) => metaData.size! > 0)
  //           .catchError((_) => false);

  //       if (storageFileExists) {
  //         await storageRef.delete();
  //       }
  //     }
  //   } catch (e) {
  //     log('Error while deleting message: $e');
  //     rethrow;
  //   }
  // }

//   static Future<void> deleteMessage(Message message) async {
//     try {
//       final String conversationID = getConversationID(message.toId);
//       final DocumentReference messageDocRef = firestore
//           .collection('chats/$conversationID/messages')
//           .doc(message.sent);

//       // Check if the message document exists before attempting to delete
//       final DocumentSnapshot messageSnapshot = await messageDocRef.get();
//       if (!messageSnapshot.exists) {
//         throw Exception('Message document does not exist.');
//       }

//       await messageDocRef.delete();

//       // Delete associated media file if message type is image or video
//       if (message.type == Type.image || message.type == Type.video) {
//         final Reference storageRef = storage.refFromURL(message.msg);

//         // Check if the storage file exists before attempting to delete
//         final bool storageFileExists = await storageRef
//             .getMetadata()
//             .then((metaData) => metaData.size! > 0)
//             .catchError((_) => false);

//         if (storageFileExists) {
//           await storageRef.delete();
//         } else {
//           log('Storage file does not exist or could not be found.');
//         }
//       }

//       log('Message and associated media (if any) deleted successfully.');
//     } catch (e, stackTrace) {
//       log('Error while deleting message: $e');
//       log('Stack trace: $stackTrace');
//       rethrow;
//     }
//   }

//   static Future<void> updateMessage(Message message, String updatedMsg) async {
//     try {
//       final collectionPath =
//           'chats/${getConversationID(message.toId)}/messages/';
//       final docReference =
//           firestore.collection(collectionPath).doc(message.sent);

//       // Check if the message has already been edited
//       if (!message.edited) {
//         // Update the message content
//         await docReference.update(
//             {'msg': message.msg, 'edited': true, 'editedMessage': updatedMsg});
//       } else {
//         // Handle the case where the message has already been edited
//         // You might want to inform the user or take other actions
//         log('Error: Message has already been edited.');
//       }
//     } catch (e) {
//       log('Error while updating message: $e');
//       // Handle the error as needed.
//       // For example, you might want to show an error message to the user.
//     }
//   }

// // Function to delete a chat
//   static Future<void> deleteChat(ChatUser chatUser) async {
//     final conversationId = getConversationID(chatUser.id);
//     final messagesRef = firestore.collection('chats/$conversationId/messages');

//     try {
//       final querySnapshot = await messagesRef.get();
//       for (final doc in querySnapshot.docs) {
//         final message = Message.fromJson(doc.data());
//         await deleteMessages(message);
//       }

//       await firestore.doc('chats/$conversationId').delete();
//     } catch (e) {
//       print('Error deleting chat: $e');
//       throw e;
//     }
//   }

//   static Future<void> deleteChatUser(id) async {
//     final userref = firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('my_users')
//         .doc(id);

//     try {
//       userref.delete();
//       print('ChatUser deleted successfully');
//     } catch (e) {
//       print('Error deleting chatuser: $e');
//       throw e;
//     }
//   }

// // Function to delete messages
//   static Future<void> deleteMessages(Message message) async {
//     try {
//       await firestore
//           .collection('chats/${getConversationID(message.toId)}/messages')
//           .doc(message.sent)
//           .delete();

//       if (message.type == Type.image) {
//         await storage.refFromURL(message.msg).delete();
//       }

//       if (message.type == Type.video) {
//         await storage.refFromURL(message.msg).delete();
//       }
//     } catch (e) {
//       print('Error deleting message: $e');
//       throw e;
//     }
//   }

// Function to search user details
// Function to search users using name or email
  static Future<List<ChatUser>> searchUsers(String query) async {
    try {
      final nameQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      final emailQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + 'z')
          .get();

      final List<ChatUser> users = [];

      nameQuerySnapshot.docs.forEach((doc) {
        final user = ChatUser.fromJson(doc.data());
        if (!users.contains(user)) {
          users.add(user);
        }
      });

      emailQuerySnapshot.docs.forEach((doc) {
        final user = ChatUser.fromJson(doc.data());
        if (!users.contains(user)) {
          users.add(user);
        }
      });

      return users;
    } catch (e) {
      print('Error searching users: $e');
      throw e;
    }
  }

// Function to update chat background
  static Future<void> updateChatBackground(String backgroundImageUrl) async {
    final String userId = user.uid;

    try {
      await firestore.collection('users').doc(userId).update({
        'background_image': backgroundImageUrl,
      });
    } catch (e) {
      print('Error updating chat background: $e');
      throw e;
    }
  }

// Function to send a GIF message
//   static Future<void> sendGifMessage(ChatUser chatUser, String gifUrl) async {
//     final time = DateTime.now().millisecondsSinceEpoch.toString();

//     final Message gifMessage = Message(
//       toId: chatUser.id,
//       msg: gifUrl,
//       read: '',
//       type: Type.gif,
//       fromId: user.uid,
//       sent: time,
//       flagged: false,
//       liked: false,
//     );

//     try {
//       final ref = firestore
//           .collection('chats/${getConversationID(chatUser.id)}/messages/');
//       await ref.doc(time).set(gifMessage.toJson()).then((value) async {
//         sendPushNotification(chatUser, 'GIF');
//       });
//     } catch (e) {
//       print('Error sending GIF message: $e');
//       throw e;
//     }
//   }

// // Function to update typing status
//   static Future<void> updateTypingStatus(String chatUser, bool isTyping) async {
//     try {
//       final userRef =
//           FirebaseFirestore.instance.collection('users').doc(chatUser);
//       await userRef.update({'is_typing': isTyping});
//     } catch (e) {
//       print("Error updating typing status: $e");
//     }
//   }

// // Function to send a chat video
//   static Future<void> sendChatVideo1(ChatUser chatUser, File videoFile) async {
//     final ext = videoFile.path.split('.').last;
//     final ref = storage.ref().child(
//           'videos/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
//         );

//     try {
//       final uploadTask = ref.putFile(videoFile);
//       final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

//       final videoUrl = await taskSnapshot.ref.getDownloadURL();

//       // ignore: unnecessary_null_comparison
//       if (videoUrl == null) {
//         print('Error uploading video');
//         throw Exception('Error uploading video');
//       }

//       final time = DateTime.now().millisecondsSinceEpoch.toString();
//       final videoMessage = Message(
//         toId: chatUser.id,
//         msg: videoUrl,
//         read: '',
//         type: Type.video,
//         fromId: user.uid,
//         sent: time,
//         flagged: false,
//         liked: false,
//       );

//       final messageRef = firestore
//           .collection('chats/${getConversationID(chatUser.id)}/messages/');
//       await messageRef.doc(time).set(videoMessage.toJson());

//       sendPushNotification(chatUser, 'Video');
//     } catch (e) {
//       print('Error sending video message: $e');
//       throw e;
//     }
//   }

// Function to delete the chat background
  static Future<void> deleteChatBackground() async {
    try {
      final String userId = user.uid;
      final chatUserRef = firestore.collection('users').doc(userId);

      // Update th chat user document in Firestore to remove the background image URL
      await chatUserRef.update({'background_image': FieldValue.delete()});
    } catch (e) {
      print('Error checking background image existence: $e');
    }
  }

  static Future<bool> checkBackgroundImageExists() async {
    final String userId = APIs.me.id;
    // ignore: unnecessary_null_comparison
    if (userId == null) {
      // If the user is not logged in or user ID is null, consider the background image does not exist.
      return false;
    }

    try {
      // Check if the 'background_image' field exists in the user's Firestore document
      final snapshot = await firestore.collection('users').doc(userId).get();
      final data = snapshot.data();
      if (data != null && data.containsKey('background_image')) {
        // If the 'background_image' field exists and is not null, consider the background image exists.
        return true;
      } else {
        // If the 'background_image' field does not exist or is null, consider the background image does not exist.
        return false;
      }
    } catch (e) {
      // Handle any errors that occur during the check process
      print('Error checking background image existence: $e');
      return false;
    }
  }

  // static Future<void> markMessageAsUnread(Message message) async {
  //   try {
  //     await firestore
  //         .collection('chats/${getConversationID(message.fromId)}/messages/')
  //         .doc(message.sent)
  //         .update({'read': ''});
  //   } catch (e) {
  //     log('Error while marking message as unread: $e');
  //     // Handle the error as needed.
  //     // For example, you might want to show an error message to the user.
  //   }
  // }

  // static Future<void> flagMessage(ChatUser chatUser, Message message) async {
  //   try {
  //     final messageRef = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/')
  //         .doc(message.sent);

  //     await messageRef.update({'flagged': true});
  //   } catch (e) {
  //     print('Error flagging message: $e');
  //     throw e;
  //   }
  // }

  // static Future<void> unflagMessage(ChatUser chatUser, Message message) async {
  //   try {
  //     final messageRef = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/')
  //         .doc(message.sent);

  //     await messageRef.update({'flagged': false});
  //   } catch (e) {
  //     print('Error unflagging message: $e');
  //     throw e;
  //   }
  // }

  // static Future<List<Message>> getFlaggedMessages(ChatUser chatUser) async {
  //   try {
  //     final messageCollection = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/');
  //     final querySnapshot =
  //         await messageCollection.where('flagged', isEqualTo: true).get();

  //     final flaggedMessages = querySnapshot.docs
  //         .map((doc) => Message.fromJson(doc.data()))
  //         .toList();
  //     return flaggedMessages;
  //   } catch (e) {
  //     print('Error getting flagged messages: $e');
  //     throw e;
  //   }
  // }

  static Future<void> blockUser(String blockUserId) async {
    if (blockUserId == null || blockUserId.isEmpty) {
      throw ArgumentError("blockUserId cannot be null or empty");
    }

    final currentUserUid = user?.uid;
    if (currentUserUid == null) {
      throw StateError("Current user is not logged in");
    }

    final batch = firestore.batch();

    try {
      // Update the 'blocked_users' array in the current user's document
      final currentUserRef = firestore.collection('users').doc(currentUserUid);
      batch.update(currentUserRef, {
        'blocked_users': FieldValue.arrayUnion([blockUserId]),
      });

      // Remove the blocked user from 'my_users' subcollection
      final myUsersRef = currentUserRef.collection('my_users').doc(blockUserId);
      batch.delete(myUsersRef);

      // Update the 'blocked_by' array in the target user's document
      final targetUserRef = firestore.collection('users').doc(blockUserId);
      batch.update(targetUserRef, {
        'blocked_by': FieldValue.arrayUnion([currentUserUid]),
      });

      await batch.commit();
    } catch (e) {
      print('Error blocking user: $e');
      throw e;
    }
  }

  static Future<void> unblockUser(String blockUserId) async {
    if (blockUserId == null || blockUserId.isEmpty) {
      throw ArgumentError("blockUserId cannot be null or empty");
    }

    final currentUserUid = user?.uid;
    if (currentUserUid == null) {
      throw StateError("Current user is not logged in");
    }

    final batch = firestore.batch();

    try {
      // Remove the target user's ID from the 'blocked_users' array in the current user's document
      final currentUserRef = firestore.collection('users').doc(currentUserUid);
      batch.update(currentUserRef, {
        'blocked_users': FieldValue.arrayRemove([blockUserId]),
      });

      // Add the user back to the current user's 'my_users' subcollection
      final myUsersRef = currentUserRef.collection('my_users').doc(blockUserId);
      batch.set(myUsersRef, {'uid': blockUserId});

      // Remove the current user's ID from the 'blocked_by' array in the target user's document
      final targetUserRef = firestore.collection('users').doc(blockUserId);
      batch.update(targetUserRef, {
        'blocked_by': FieldValue.arrayRemove([currentUserUid]),
      });

      await batch.commit();
    } catch (e) {
      print('Error unblocking user: $e');
      throw e;
    }
  }

  static Future<bool> checkIfBlocked(String userId) async {
    if (userId == null || userId.isEmpty) {
      throw ArgumentError("userId cannot be null or empty");
    }

    final currentUserUid = user?.uid;
    if (currentUserUid == null) {
      throw StateError("Current user is not logged in");
    }

    try {
      // Fetch the current user's document to check if they have blocked the target user
      final currentUserDoc =
          await firestore.collection('users').doc(currentUserUid).get();
      if (currentUserDoc.exists) {
        List<dynamic> blockedUsers =
            currentUserDoc.data()?['blocked_users'] ?? [];
        if (blockedUsers.contains(userId)) {
          return true;
        }
      }

      // Check if the target user has blocked the current user
      final targetUserDoc =
          await firestore.collection('users').doc(userId).get();
      if (targetUserDoc.exists) {
        List<dynamic> blockedByUsers =
            targetUserDoc.data()?['blocked_by'] ?? [];
        if (blockedByUsers.contains(currentUserUid)) {
          return true;
        }
      }

      // If neither condition is met, the users are not blocked from each other
      return false;
    } catch (e) {
      print('Error checking blocked status: $e');
      throw e;
    }
  }

  // Block a user
  // static Future<void> blockUser(String blockUserId) async {
  //   try {
  //     final currentUserUid = user.uid;

  //     // Update the 'blocked_users' array in the current user's document
  //     await firestore.collection('users').doc(currentUserUid).update({
  //       'blocked_users': FieldValue.arrayUnion([blockUserId]),
  //     });

  //     await firestore
  //         .collection('users')
  //         .doc(currentUserUid)
  //         .collection('my_users')
  //         .doc(blockUserId)
  //         .delete();

  //     // Update the 'blocked_by' array in the target user's document
  //     await firestore.collection('users').doc(blockUserId).update({
  //       'blocked_by': FieldValue.arrayUnion([currentUserUid]),
  //     });
  //   } catch (e) {
  //     print('Error blocking user: $e');
  //     throw e;
  //   }
  // }

  // // Unblock a user
  // static Future<void> unblockUser(String blockuser) async {
  //   try {
  //     final currentUserUid = user.uid;

  //     // Remove the target user's ID from the 'blocked_users' array in the current user's document
  //     await firestore.collection('users').doc(currentUserUid).update({
  //       'blocked_users': FieldValue.arrayRemove([blockuser]),
  //     }).whenComplete(() async {
  //       await firestore
  //           .collection('users')
  //           .doc(currentUserUid)
  //           .collection('my_users')
  //           .doc(blockuser)
  //           .set({});
  //     });

  //     // Add the user back to the current user's 'my_users' subcollection
  //     // Assuming you want to set some data, here just adding the uid field

  //     // Remove the current user's ID from the 'blocked_by' array in the target user's document
  //     await firestore.collection('users').doc(blockuser).update({
  //       'blocked_by': FieldValue.arrayRemove([currentUserUid]),
  //     });
  //   } catch (e) {
  //     print('Error unblocking user: $e');
  //     throw e;
  //   }
  // }

  // static Future<bool> checkIfBlocked(String userId) async {
  //   try {
  //     final currentUserUid = user.uid;

  //     // Fetch the current user's document to check if they have blocked the target user
  //     final currentUserDoc =
  //         await firestore.collection('users').doc(currentUserUid).get();
  //     if (currentUserDoc.exists) {
  //       List<dynamic> blockedUsers =
  //           currentUserDoc.data()?['blockedUsers'] ?? [];
  //       if (blockedUsers.contains(userId)) {
  //         // The target user is blocked by the current user
  //         return true;
  //       }
  //     }

  //     // If the target user is not blocked by the current user, check if the target user
  //     // has blocked the current user
  //     final targetUserDoc =
  //         await firestore.collection('users').doc(userId).get();
  //     if (targetUserDoc.exists) {
  //       List<dynamic> blockedByUsers =
  //           targetUserDoc.data()?['blocked_by'] ?? [];
  //       if (blockedByUsers.contains(currentUserUid)) {
  //         // The current user is blocked by the target user
  //         return true;
  //       }
  //     }

  //     // If neither of the above conditions is met, the users are not blocked from each other
  //     return false;
  //   } catch (e) {
  //     print('Error checking blocked status: $e');
  //     throw e;
  //   }
  // }

  static Future<List<String>> getBlockedUsers() async {
    try {
      final currentUserUid = user.uid;

      final DocumentSnapshot userDoc =
          await firestore.collection('users').doc(currentUserUid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final blockedUsers = data['blocked_users'] ?? <String>[];
        return blockedUsers.cast<String>();
      } else {
        return <String>[];
      }
    } catch (e) {
      print('Error fetching blocked users: $e');
      throw e;
    }
  }

  static Future<List<ChatUser>> getUsersByIds(List<String> userIds) async {
    try {
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      final users =
          userDocs.docs.map((doc) => ChatUser.fromJson(doc.data())).toList();

      return users; // Ensure that it returns a List<ChatUser>.
    } catch (e) {
      print('Error fetching users by IDs: $e');
      throw e;
    }
  }

  static Future<void> crypticMode(String chatUser, bool crypticMode) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(chatUser);
      await userRef.update({'cryptic_mode': crypticMode});
    } catch (e) {
      // Handle the error
      print("Error updating typing status: $e");
    }
  }

  // static Future<void> likeMessage(ChatUser chatUser, Message message) async {
  //   try {
  //     final messageRef = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/')
  //         .doc(message.sent);

  //     await messageRef.update({'liked': true});
  //   } catch (e) {
  //     print('Error : $e');
  //     throw e;
  //   }
  // }

  // static Future<void> unlikeMessage(ChatUser chatUser, Message message) async {
  //   try {
  //     final messageRef = firestore
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/')
  //         .doc(message.sent);

  //     await messageRef.update({'liked': false});
  //   } catch (e) {
  //     print('Error : $e');
  //     throw e;
  //   }
  // }

  static Future<bool> areUsersMutualFriends(
      String currentUserId, String targetUserId) async {
    final followersRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection('followers')
        .doc(targetUserId);

    final followingRef = FirebaseFirestore.instance
        .collection("users")
        .doc(targetUserId)
        .collection('following')
        .doc(currentUserId);

    final isFollowingCurrent = await followersRef.get();
    final isFollowingUser = await followingRef.get();

    return isFollowingCurrent.exists && isFollowingUser.exists;
  }

  static Future<ChatUser?> getUserByEmail(String email) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with the given email found
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final user = ChatUser.fromJson(userData);
        return user;
      } else {
        // User with the given email not found
        return null;
      }
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  static Future<void> updateCrypticModeStatus(bool isCrypticModeEnabled) async {
    try {
      // Update the user's cryptic mode status in the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'cryptic_mode': isCrypticModeEnabled});

      // You can also update the local user object if needed
      // Example: currentUser.crypticMode = isCrypticModeEnabled;
    } catch (e) {
      // Handle any errors that may occur during the update
      print('Error updating cryptic mode status: $e');
    }
  }

  static Future<bool> getCrypticModeStatus() async {
    try {
      // Fetch the user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Check if the 'cryptic_mode' field exists in the document
        if (userDoc.data() != null &&
            userDoc.data()!.containsKey('cryptic_mode')) {
          // Retrieve the cryptic mode status and return it
          final isCrypticModeEnabled = userDoc.data()!['cryptic_mode'] as bool;
          return isCrypticModeEnabled;
        }
      }
    } catch (e) {
      // Handle any errors that may occur during the retrieval
      print('Error retrieving cryptic mode status: $e');
    }

    // Return false by default (cryptic mode is disabled or an error occurred)
    return false;
  }


  static Future<List<String>> getLockedChats() async {
    try {
      final currentUserUid = user.uid;

      // Retrieve the document of the current user
      DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .get();

      // Check if the document exists and contains the 'locked_chats' field
      if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
        List<String>? lockedChats =
            (userDocSnapshot.data()!['locked_chats'] as List<dynamic>?)
                ?.cast<String>();

        // Return the list of locked chat IDs (or an empty list if 'locked_chats' is null)
        return lockedChats ?? [];
      } else {
        // Document doesn't exist or 'locked_chats' field is missing
        return [];
      }
    } catch (e) {
      print('Error fetching locked chats: $e');
      throw e;
    }
  }

  // static Future<void> sendChatVideo2(ChatUser chatUser, File videoFile) async {
  //   final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //   final ext = videoFile.path.split('.').last;
  //   final ref = storage.ref().child(
  //         'videos/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
  //       );

  //   try {
  //     final uploadTask = ref.putFile(videoFile);
  //     await showUploadProgressNotification(
  //         notificationId, 'Sending Video', uploadTask);
  //     final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

  //     final videoUrl = await taskSnapshot.ref.getDownloadURL();

  //     if (videoUrl == null) {
  //       print('Error uploading video');
  //       throw Exception('Error uploading video');
  //     }

  //     final time = DateTime.now().millisecondsSinceEpoch.toString();

  //     // Use FirebaseFirestore.instance instead of firestore
  //     final messageRef = FirebaseFirestore.instance
  //         .collection('chats/${getConversationID(chatUser.id)}/messages/');

  //     // Update Message creation
  //     await messageRef.doc(time).set({
  //       'toId': chatUser.id,
  //       'msg': videoUrl,
  //       'read': '',
  //       'type': 'video', // assuming type is a string
  //       'fromId': user.uid, // assuming user is a global variable
  //       'sent': time,
  //       'flagged': false,
  //       'liked': false,
  //     });

  //     sendPushNotification(chatUser, 'Video');
  //   } catch (e) {
  //     print('Error sending video message: $e');
  //     throw e;
  //   }
  // }

  // static Future<void> sendChatFile(ChatUser chatUser, File file) async {
  //   // Getting file extension
  //   final ext = file.path.split('.').last;
  //   print('Extension: $ext');

  //   // storage file ref with path
  //   final ref = storage.ref().child(
  //       'uploads/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

  //   // uploading file
  //   await ref
  //       .putFile(
  //           file,
  //           SettableMetadata(
  //             contentType: 'file/$ext',
  //           ))
  //       .then((p0) {
  //     print('Data transferred: ${p0.bytesTransferred / 1000} kb');
  //   });

  //   // Updating file in firestore database
  //   final fileURL = await ref.getDownloadURL();
  //   await sendMessage(chatUser, fileURL, Type.file);
  // }

  // static Future<void> sendChatFile(ChatUser chatUser, File file) async {
  //   final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //   final originalFileName = file.path.split('/').last;

  //   // Replace spaces with hyphens in the filename
  //   final fileNameWithoutSpaces = originalFileName.replaceAll(' ', '-');
  //   print('Original file name: $originalFileName');
  //   print('File name without spaces: $fileNameWithoutSpaces');

  //   final ref = storage.ref().child(
  //       'uploads/${getConversationID(chatUser.id)}/$fileNameWithoutSpaces');

  //   try {
  //     final uploadTask = ref.putFile(
  //       file,
  //       SettableMetadata(
  //         contentType: 'file/${file.path.split('.').last}',
  //       ),
  //     );

  //     await showUploadProgressNotification(
  //         notificationId, 'Sending File', uploadTask);

  //     final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

  //     final fileURL = await taskSnapshot.ref.getDownloadURL();

  //     if (fileURL == null) {
  //       print('Error uploading file');
  //       throw Exception('Error uploading file');
  //     }

  //     await sendMessage(chatUser, fileURL, Type.file);
  //   } catch (e) {
  //     print('Error sending file message: $e');
  //     throw e;
  //   }
  // }
}

// https://github.com/furkansarihan/firestore_collection/blob/master/lib/firestore_document.dart
extension FirestoreDocumentExtension on DocumentReference {
  Future<DocumentSnapshot> getSavy() async {
    try {
      DocumentSnapshot ds = await this.get(GetOptions(source: Source.cache));
      if (!ds.exists) return this.get(GetOptions(source: Source.server));
      return ds;
    } catch (_) {
      return this.get(GetOptions(source: Source.server));
    }
  }
}

// https://github.com/furkansarihan/firestore_collection/blob/master/lib/firestore_query.dart
extension FirestoreQueryExtension on Query {
  Future<QuerySnapshot> getSavy() async {
    try {
      QuerySnapshot qs = await this.get(GetOptions(source: Source.cache));
      if (qs.docs.isEmpty) return this.get(GetOptions(source: Source.server));
      return qs;
    } catch (_) {
      return this.get(GetOptions(source: Source.server));
    }
  }
}
