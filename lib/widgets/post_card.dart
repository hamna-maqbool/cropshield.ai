import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import '../models/forum_post.dart';

class PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        0,
        AppSpacing.pageH,
        AppSpacing.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.parchment),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.parchment,
                      backgroundImage: post.userAvatarUrl.isNotEmpty
                          ? NetworkImage(post.userAvatarUrl)
                          : null,
                      child: post.userAvatarUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: AppColors.stone,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        post.userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.moss.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.cropType,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 11,
                              color: AppColors.moss,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      post.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 16,
                      color: AppColors.danger.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likedBy.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: AppColors.stone,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                    ),
                    const Spacer(),
                    if (post.isResolved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Resolved',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.success,
                                  ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
