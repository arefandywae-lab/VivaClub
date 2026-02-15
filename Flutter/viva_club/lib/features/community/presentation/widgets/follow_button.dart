import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/following_bloc.dart';

class FollowButton extends StatefulWidget {
  final String ghostId;
  final String ghostName;
  final bool initialIsFollowing;

  const FollowButton({
    super.key,
    required this.ghostId,
    required this.ghostName,
    this.initialIsFollowing = false,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
  }

  void _toggleFollow() {
    setState(() {
      _isLoading = true;
    });

    context.read<FollowingBloc>().add(
      FollowingToggle(widget.ghostId, _isFollowing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FollowingBloc, FollowingState>(
      listener: (context, state) {
        if (state is FollowingToggleSuccess) {
          setState(() {
            _isFollowing = state.isNowFollowing;
            _isLoading = false;
          });

          // Show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
              backgroundColor: AppTheme.primary,
            ),
          );
        } else if (state is FollowingFailure) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _toggleFollow,
        icon: _isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(_isFollowing ? Icons.check : Icons.add, size: 18.sp),
        label: Text(
          _isFollowing ? 'Following' : 'Follow',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.grey[600] : AppTheme.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
