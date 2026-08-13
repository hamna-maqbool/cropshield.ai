import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/forum_post.dart';
import '../services/forum_service.dart';
import 'auth/login_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final ForumPost post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  Future<bool> _ensureLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) return true;
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return result == true && FirebaseAuth.instance.currentUser != null;
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final loggedIn = await _ensureLoggedIn();
    if (!loggedIn || !mounted) return;

    setState(() => _isSending = true);
    try {
      await _forumService.addComment(widget.post.id, text);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUid == post.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [
          if (isOwner)
            IconButton(
              icon: Icon(
                post.isResolved ? Icons.check_circle : Icons.check_circle_outline,
                color: post.isResolved ? AppColors.success : null,
              ),
              tooltip: 'Mark as resolved',
              onPressed: () =>
                  _forumService.markResolved(post.id, !post.isResolved),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.userAvatarUrl.isNotEmpty
                          ? NetworkImage(post.userAvatarUrl)
                          : null,
                      child: post.userAvatarUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(post.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(post.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(post.description),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post.imageUrl!),
                  ),
                ],
                const Divider(height: 32),
                const Text('Replies',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<List<ForumComment>>(
                  stream: _forumService.getComments(post.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final comments = snapshot.data!;
                    if (comments.isEmpty) {
                      return const Text('No replies yet.');
                    }
                    return Column(
                      children: comments
                          .map((c) => _CommentTile(comment: c))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a reply...',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ForumComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: comment.isExpert
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.parchment.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: comment.isExpert
            ? Border.all(color: AppColors.success.withValues(alpha: 0.35))
            : Border.all(color: AppColors.parchment),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(comment.userName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (comment.isExpert) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'EXPERT',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.text),
        ],
      ),
    );
  }
}