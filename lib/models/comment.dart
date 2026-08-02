import 'package:cloud_firestore/cloud_firestore.dart';

class ForumComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String text;
  final DateTime createdAt;
  final bool isExpert; // true if the replier is a verified agronomist/expert

  ForumComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.text,
    required this.createdAt,
    this.isExpert = false,
  });

  factory ForumComment.fromMap(String id, Map<String, dynamic> map) {
    return ForumComment(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userAvatarUrl: map['userAvatarUrl'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isExpert: map['isExpert'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isExpert': isExpert,
    };
  }
}
