import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import '../bloc/room_bloc.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _topicController = TextEditingController();
  String _selectedCategory = 'general';

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'anxiety',
      'name': 'Anxiety',
      'icon': '😰',
      'color': const Color(0xFFFFF7ED),
      'borderColor': const Color(0xFFFFEDD5),
    },
    {
      'id': 'burnout',
      'name': 'Burnout',
      'icon': '😫',
      'color': const Color(0xFFFEF2F2),
      'borderColor': const Color(0xFFFEE2E2),
    },
    {
      'id': 'relationships',
      'name': 'Relationships',
      'icon': '❤️',
      'color': const Color(0xFFFDF2F8),
      'borderColor': const Color(0xFFFCE7F3),
    },
    {
      'id': 'depression',
      'name': 'Depression',
      'icon': '🌧️',
      'color': const Color(0xFFEFF6FF),
      'borderColor': const Color(0xFFDBEAFE),
    },
    {
      'id': 'sleep',
      'name': 'Sleep',
      'icon': '😴',
      'color': const Color(0xFFEEF2FF),
      'borderColor': const Color(0xFFE0E7FF),
    },
    {
      'id': 'general',
      'name': 'General',
      'icon': '🌟',
      'color': const Color(0xFFFEFCE8),
      'borderColor': const Color(0xFFFFEDD5),
    },
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withValues(alpha: 0.05),
                      ),
                      child: Icon(Icons.arrow_back, size: 20.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Start a Room',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic input
                    Text(
                      "WHAT'S THE TOPIC?",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGrey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: TextField(
                        controller: _topicController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Struggling with Monday anxiety...',
                          hintStyle: TextStyle(
                            color: AppTheme.textGrey.withValues(alpha: 0.5),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20.w),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Category selection
                    Text(
                      'SELECT A TOPIC',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGrey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat['id'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? cat['color'] : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? cat['borderColor']
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (cat['borderColor'] as Color)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  cat['icon'],
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  cat['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer — Go Live Button
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
              ),
              child: BlocListener<RoomBloc, RoomState>(
                listener: (context, state) {
                  if (state is RoomJoined) {
                    context.pushReplacement(
                      '/live_room',
                      extra: {
                        'token': state.token,
                        'url': state.url,
                        'room_id': state.roomId,
                        'title': state.title,
                        'is_host': state.isHost,
                      },
                    );
                  } else if (state is RoomFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: GestureDetector(
                  onTap: _topicController.text.trim().isEmpty
                      ? null
                      : () {
                          context.read<RoomBloc>().add(
                            RoomCreate(
                              _topicController.text.trim(),
                              _selectedCategory,
                            ),
                          );
                        },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _topicController.text.trim().isEmpty ? 0.5 : 1.0,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.butteryYellow, AppTheme.cottonPink],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cottonPink.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.textDark,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Go Live Now',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
