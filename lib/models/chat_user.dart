import 'device.dart';

class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.isTyping,
    required this.crypticMode,
    this.latitude = 0.0, // Set default values or use nullable types
    this.longitude = 0.0,
    required this.devices,
    required this.ghostMode,
  });

  late String image;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late bool isTyping;
  late bool crypticMode;
  late bool ghostMode;
  late double latitude;
  late double longitude;
  late List<Device> devices;

  ChatUser.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      image = json['image'] ?? '';
      about = json['about'] ?? '';
      name = json['name'] ?? '';
      createdAt = json['created_at'] ?? '';
      isOnline = json['is_online'] ?? false;
      id = json['id'] ?? '';
      lastActive = json['last_active'] ?? '';
      email = json['email'] ?? '';
      pushToken = json['push_token'] ?? '';
      isTyping = json['is_typing'] ?? false;
      crypticMode = json['cryptic_mode'] ?? false;
      ghostMode = json['ghost_mode'] ?? false;
      latitude = json['latitude'] ?? 0.0.toDouble();
      longitude = json['longitude'] ?? 0.0.toDouble();
      if (json['devices'] != null) {
        devices = (json['devices'] as List)
            .map((deviceJson) => Device.fromJson(deviceJson))
            .toList();
      } else {
        devices = [];
      }
    } else {
      // Handle the case when json is null
      // You might want to throw an exception, provide default values, or handle it accordingly
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['is_typing'] = isTyping;
    data['cryptic_mode'] = crypticMode;
    data['ghost_mode'] = ghostMode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['devices'] = devices.map((device) => device.toJson()).toList();
    return data;
  }
}
