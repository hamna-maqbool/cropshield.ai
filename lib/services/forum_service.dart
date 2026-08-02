import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/forum_post.dart';
import '../models/comment.dart';

class ForumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _postsRef => _db.collection('forum_posts');

  /// Stream of all posts, newest first. Optionally filter by crop type.
  Stream<List<ForumPost>> getPosts({String? cropType}) {
    Query query = _postsRef.orderBy('createdAt', descending: true);
    if (cropType != null && cropType != 'All') {
      query = query.where('cropType', isEqualTo: cropType);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => ForumPost.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  /// Stream of comments for a single post, oldest first.
  Stream<List<ForumComment>> getComments(String postId) {
    return _postsRef
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                ForumComment.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Upload an optional image and create a new post.
  Future<void> createPost({
    required String title,
    required String description,
    required String cropType,
    File? image,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    String? imageUrl;
    if (image != null) {
      imageUrl = await _uploadImage(image, 'forum_posts');
    }

    // Pull display name / avatar from the users collection (set at signup)
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final post = ForumPost(
      id: '',
      userId: user.uid,
      userName: userData['name'] ?? user.displayName ?? 'Farmer',
      userAvatarUrl: userData['avatarUrl'] ?? '',
      title: title,
      description: description,
      imageUrl: imageUrl,
      cropType: cropType,
      createdAt: DateTime.now(),
    );

    await _postsRef.add(post.toMap());
  }

  /// Add a comment/reply. Automatically tags it as an expert reply
  /// if the replying user has isExpert == true in their user profile.
  Future<void> addComment(String postId, String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final bool isExpert = userData['isExpert'] ?? false;

    final comment = ForumComment(
      id: '',
      userId: user.uid,
      userName: userData['name'] ?? user.displayName ?? 'Farmer',
      userAvatarUrl: userData['avatarUrl'] ?? '',
      text: text,
      createdAt: DateTime.now(),
      isExpert: isExpert,
    );

    final postRef = _postsRef.doc(postId);
    await postRef.collection('comments').add(comment.toMap());
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }

  /// Toggle like on a post for the current user.
  Future<void> toggleLike(String postId, List<String> currentLikedBy) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final postRef = _postsRef.doc(postId);
    if (currentLikedBy.contains(user.uid)) {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([user.uid])
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([user.uid])
      });
    }
  }

  /// Let the original poster (or an expert) mark a question as resolved.
  Future<void> markResolved(String postId, bool resolved) async {
    await _postsRef.doc(postId).update({'isResolved': resolved});
  }

  Future<String> _uploadImage(File image, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser!.uid}.jpg';
    final ref = _storage.ref().child('$folder/$fileName');
    final uploadTask = await ref.putFile(image);
    return await uploadTask.ref.getDownloadURL();
  }
}
