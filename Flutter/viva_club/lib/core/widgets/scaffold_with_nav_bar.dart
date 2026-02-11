import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import 'package:viva_club/features/community/data/livekit_room_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
          // Minimized Room Overlay
          Consumer<LiveKitRoomService>(
            builder: (context, service, child) {
              if (!service.isActive) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () => context.push(
                  '/live_room',
                  extra: {
                    'token': '', // Handled by service
                    'url': '', // Handled by service
                    'room_id': service.activeRoomId,
                    'is_host': service.isHost,
                  },
                ),
                child: Container(
                  height: 60.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.mintGreen.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          size: 20.sp,
                          color: AppTheme.mintGreen,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.currentTitle ?? 'Live Room',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Tap to return',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => service.leave(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.skyBlue.withValues(alpha: 0.1),
          height: 65,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppTheme.skyBlue),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam, color: AppTheme.skyBlue),
              label: 'Telemed',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups, color: AppTheme.mintGreen),
              label: 'Clubhouse',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.skyBlue),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
