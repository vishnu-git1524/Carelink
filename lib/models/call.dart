class Call {
  late String callerId;
  late String callerName;
  late String callerPic;
  late String receiverId;
  late String receiverName;
  late String receiverPic;
  late String channelId;
  late bool hasDialled;

  Call({
    String? callerId,
    String? callerName,
    String? callerPic,
    String? receiverId,
    String? receiverName,
    String? receiverPic,
    String? channelId,
    bool? hasDialled,
  })  : callerId = callerId ?? "",
        callerName = callerName ?? "",
        callerPic = callerPic ?? "",
        receiverId = receiverId ?? "",
        receiverName = receiverName ?? "",
        receiverPic = receiverPic ?? "",
        channelId = channelId ?? "",
        hasDialled = hasDialled ?? false;

  // to map
  Map<String, dynamic> toMap(Call call) {
    return {
      "caller_id": callerId,
      "caller_name": callerName,
      "caller_pic": callerPic,
      "receiver_id": receiverId,
      "receiver_name": receiverName,
      "receiver_pic": receiverPic,
      "channel_id": channelId,
      "has_dialled": hasDialled,
    };
  }

  Call.fromMap(Map<String, dynamic> callMap) {
    this.callerId = callMap["caller_id"] ?? "";
    this.callerName = callMap["caller_name"] ?? "";
    this.callerPic = callMap["caller_pic"] ?? "";
    this.receiverId = callMap["receiver_id"] ?? "";
    this.receiverName = callMap["receiver_name"] ?? "";
    this.receiverPic = callMap["receiver_pic"] ?? "";
    this.channelId = callMap["channel_id"] ?? "";
    this.hasDialled = callMap["has_dialled"] ?? false;
  }
}
