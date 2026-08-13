import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/forum_post.dart';
import '../services/forum_service.dart';
import '../widgets/post_card.dart';
import 'auth/login_screen.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});
  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();
  String _selectedCrop = 'All';
  final List<String> _cropOptions = [
    'All',
    'Wheat',
    'Rice',
    'Cotton',
    'Sugarcane',
    'Maize',
    'Other',
  ];

  Future<bool> _ensureLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) return true;
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return result == true && FirebaseAuth.instance.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: _cropOptions.map((crop) {
                final selected = crop == _selectedCrop;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(crop),
                    selected: selected,
                    selectedColor: AppColors.moss,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _selectedCrop = crop),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<ForumPost>>(
        stream: _forumService.getPosts(cropType: _selectedCrop),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 40,
                      color: AppColors.moss.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No questions yet. Be the first to ask!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Ask a Question'),
        onPressed: () async {
          final loggedIn = await _ensureLoggedIn();
          if (!loggedIn || !context.mounted) return;
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
      ),
    );
  }
}
