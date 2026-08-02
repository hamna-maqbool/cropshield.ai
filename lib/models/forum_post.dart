import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String title;
  final String description;
  final String? imageUrl;
  final String cropType;
  final DateTime createdAt;
  final int commentCount;
  final bool isResolved;
  final List<String> likedBy;

  ForumPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.cropType,
    required this.createdAt,
    this.commentCount = 0,
    this.isResolved = false,
    this.likedBy = const [],
  });

  factory ForumPost.fromMap(String id, Map<String, dynamic> map) {
    return ForumPost(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userAvatarUrl: map['userAvatarUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      cropType: map['cropType'] ?? 'Other',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      commentCount: map['commentCount'] ?? 0,
      isResolved: map['isResolved'] ?? false,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'cropType': cropType,
      'createdAt': FieldValue.serverTimestamp(),
      'commentCount': commentCount,
      'isResolved': isResolved,
      'likedBy': likedBy,
    };
  }
}
