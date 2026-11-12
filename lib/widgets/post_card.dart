import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/forum_post.dart';

// One community post row in the forum list.
class PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: AppColors.parchment,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.lg,
            AppSpacing.pageH,
            AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.parchment),
            ),
          ),
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
                            CupertinoIcons.person,
                            size: 16,
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
                  Text(
                    post.cropType,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 11,
                          color: AppColors.moss,
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
                Image.network(
                  post.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.heart,
                    size: 16,
                    color: AppColors.stone,
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
                    CupertinoIcons.chat_bubble,
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
                    Text(
                      'Resolved',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
