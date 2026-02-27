import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/emoji_utils.dart';
import '../../../profile/data/profile_repository.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _repo = ProfileRepository();
  List<dynamic> _blockedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlocked();
  }

  Future<void> _loadBlocked() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _repo.getBlockedUsers();
      setState(() {
        _blockedUsers = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _unblock(dynamic block) async {
    // The block object has a 'blocked' field which is the user id to unblock
    final blockedId = block['blocked']?.toString() ?? '';
    if (blockedId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Unblock User'),
        content: const Text(
          'Allow this ghost to appear in rooms and contact you again?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unblock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repo.unblockUser(blockedId);
        await _loadBlocked();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ User unblocked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to unblock: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textDark,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '🚫 Blocked Users',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _blockedUsers.isEmpty
          ? _buildEmpty()
          : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load blocked users',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: _loadBlocked, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✅', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 16.h),
          Text(
            'No blocked users',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'When you block a ghost,\nthey will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadBlocked,
      child: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: _blockedUsers.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final block = _blockedUsers[index];
          final blockedName =
              block['blocked_details']?['display_name'] ?? 'Ghost User';
          final emoji = EmojiUtils.getEmojiForName(blockedName);

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Center(
                    child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
                  ),
                ),
                SizedBox(width: 14.w),
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blockedName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Blocked',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                // Unblock button
                TextButton.icon(
                  onPressed: () => _unblock(block),
                  icon: const Icon(
                    Icons.lock_open,
                    size: 16,
                    color: Colors.green,
                  ),
                  label: const Text(
                    'Unblock',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
