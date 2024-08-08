class Device {
  String deviceId;
  String deviceName;
  String lastLogin;
  String model;
  String manufacturer;
  String device;
  bool verified;
  bool primaryDevice;
  bool isBlocked;

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.lastLogin,
    required this.model,
    required this.manufacturer,
    required this.device,
    required this.verified,
    required this.primaryDevice,
    required this.isBlocked,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? '',
      lastLogin: json['last_login'] ?? '',
      model: json['model'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      device: json['device'] ?? '',
      verified: json['verified'] ??
          false, // Check for "verified" in JSON and default to false
      primaryDevice: json['primaryDevice'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'last_login': lastLogin,
      'model': model,
      'manufacturer': manufacturer,
      'device': device,
      'verified': verified, // Include "verified" in the JSON output
      'primaryDevice': primaryDevice,
      'isBlocked': isBlocked,
    };
  }
}
