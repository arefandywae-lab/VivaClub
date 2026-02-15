import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/emoji_utils.dart';
import '../bloc/following_bloc.dart';

class FollowingListScreen extends StatefulWidget {
  const FollowingListScreen({super.key});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FollowingBloc>().add(FollowingLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Following',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<FollowingBloc, FollowingState>(
        builder: (context, state) {
          if (state is FollowingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FollowingFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load following list',
                    style: TextStyle(fontSize: 16.sp, color: AppTheme.textGrey),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FollowingBloc>().add(FollowingLoad());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FollowingLoaded) {
            if (state.following.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('👻', style: TextStyle(fontSize: 64.sp)),
                    SizedBox(height: 16.h),
                    Text(
                      'Not following anyone yet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Follow ghosts to see their rooms here',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.following.length,
              itemBuilder: (context, index) {
                final subscription = state.following[index];
                final ghost = subscription['target_details'];
                final followedAt = subscription['followed_at'];

                return _buildGhostCard(ghost, followedAt);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGhostCard(Map<String, dynamic> ghost, String? followedAt) {
    final displayName = ghost['display_name'] ?? 'Unknown Ghost';
    final followerCount = ghost['followers_count'] ?? 0;
    final emoji = EmojiUtils.getEmojiForName(displayName);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 32.sp)),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$followerCount followers',
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.textGrey),
                ),
                if (followedAt != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Following since ${_formatDate(followedAt)}',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
                  ),
                ],
              ],
            ),
          ),

          // Unfollow button
          IconButton(
            onPressed: () {
              _showUnfollowDialog(ghost['id'], displayName);
            },
            icon: Icon(Icons.person_remove, color: Colors.red, size: 24.sp),
          ),
        ],
      ),
    );
  }

  void _showUnfollowDialog(String ghostId, String ghostName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unfollow'),
        content: Text('Stop following $ghostName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FollowingBloc>().add(FollowingToggle(ghostId, true));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()} months ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} days ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hours ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
