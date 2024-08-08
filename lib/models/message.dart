// class Message {
//   Message({
//     required this.toId,
//     required this.msg,
//     required this.read,
//     required this.type,
//     required this.fromId,
//     required this.sent,
//     required this.flagged,
//     required this.liked,
//     this.edited = false,
//     this.editedMessage = '',
//     this.secretmsg = false,
//   });

//   late final String toId;
//   late final String msg;
//   late final String read;
//   late final String fromId;
//   late final String sent;
//   late final Type type;
//   late final bool flagged;
//   late final bool liked;
//   late final bool edited;
//   late final String editedMessage; // Added field for the edited message
//   late final bool secretmsg;

//   Message.fromJson(Map<String, dynamic> json) {
//     toId = json['toId'].toString();
//     msg = json['msg'].toString();
//     read = json['read'].toString();
//     type = _parseMessageType(json['type'].toString());
//     fromId = json['fromId'].toString();
//     sent = json['sent'].toString();
//     flagged = json['flagged'] ?? false;
//     liked = json['liked'] ?? false;
//     edited = json['edited'] ?? false;
//     secretmsg = json['secretmsg'] ?? false;
//     editedMessage =
//         json['editedMessage'] ?? ''; // Added line to initialize editedMessage
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['toId'] = toId;
//     data['msg'] = msg;
//     data['read'] = read;
//     data['type'] = type.name;
//     data['fromId'] = fromId;
//     data['sent'] = sent;
//     data['flagged'] = flagged;
//     data['liked'] = liked;
//     data['edited'] = edited;
//     data['secretmsg'] = secretmsg;
//     data['editedMessage'] =
//         editedMessage; // Added line to include editedMessage in JSON
//     return data;
//   }

//   Type _parseMessageType(String typeString) {
//     switch (typeString) {
//       case 'image':
//         return Type.image;
//       case 'gif':
//         return Type.gif;
//       case 'video':
//         return Type.video;
//       case 'audio':
//         return Type.audio;
//       case 'file':
//         return Type.file;
//       default:
//         return Type.text;
//     }
//   }
// }

// enum Type { text, image, gif, video, audio, file }

class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    this.replyType,
    required this.fromId,
    required this.sent,
    required this.flagged,
    required this.liked,
    this.edited = false,
    this.editedMessage = '',
    this.secretmsg = false,
    this.replyToMessage = '', // Added field for reply message
  });

  late final String toId;
  late final String msg;
  late final String read;
  late final String fromId;
  late final String sent;
  late final Type type;
  late final Type? replyType;
  late final bool flagged;
  late final bool liked;
  late final bool edited;
  late final String editedMessage;
  late final bool secretmsg;
  late final String replyToMessage; // Added field for reply message

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = _parseMessageType(json['type'].toString());
    replyType = _parseMessageType(json['reply_type'].toString());
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
    flagged = json['flagged'] ?? false;
    liked = json['liked'] ?? false;
    edited = json['edited'] ?? false;
    secretmsg = json['secretmsg'] ?? false;
    editedMessage = json['editedMessage'] ?? '';
    replyToMessage = json['replyToMessage'] ?? ''; // Initialize replyToMessage
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['reply_type'] = replyType!.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    data['flagged'] = flagged;
    data['liked'] = liked;
    data['edited'] = edited;
    data['secretmsg'] = secretmsg;
    data['editedMessage'] = editedMessage;
    data['replyToMessage'] = replyToMessage; // Include replyToMessage in JSON
    return data;
  }

  Type _parseMessageType(String typeString) {
    switch (typeString) {
      case 'image':
        return Type.image;
      case 'gif':
        return Type.gif;
      case 'video':
        return Type.video;
      case 'audio':
        return Type.audio;
      case 'file':
        return Type.file;
      default:
        return Type.text;
    }
  }
}

enum Type { text, image, gif, video, audio, file }
