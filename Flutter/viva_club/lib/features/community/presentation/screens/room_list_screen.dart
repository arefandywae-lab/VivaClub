import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import '../../../../core/utils/emoji_utils.dart';
import '../../../../core/network/dio_client.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../data/following_repository.dart';
import '../bloc/room_bloc.dart';
import '../bloc/following_bloc.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  bool _isJoining = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _sortMode = 'recent'; // 'recent' | 'trending' | 'scheduled'

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'general',
      'name': 'All Topics',
      'icon': '🌟',
      'color': const Color(0xFFFEFCE8),
      'borderColor': const Color(0xFFFFEDD5),
    },
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
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RoomBloc>().add(RoomLoad());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
            _buildHeader(),

            // Content
            Expanded(
              child: BlocConsumer<RoomBloc, RoomState>(
                listener: (context, state) {
                   if (state is RoomFailure) {
                    _isJoining = false;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is RoomJoined) {
                    _isJoining = false;
                    debugPrint('--- Navigating to Room: ${state.title} ---');
                    debugPrint('URL: ${state.url}');
                    context.pushReplacement(
                      '/live_room',
                      extra: {
                        'token': state.token,
                        'url': state.url,
                        'room_id': state.roomId,
                        'title': state.title,
                        'is_host': state.isHost,
                      },
                    ).then((_) {
                      if (mounted) {
                        _isJoining = false;
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is RoomLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RoomFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<RoomBloc>().add(RoomLoad()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is RoomLoaded) {
                    if (_selectedCategory == null) {
                      return _buildCategoryGrid();
                    } else {
                      return _buildRoomListWithTabs(
                        List<Map<String, dynamic>>.from(state.rooms),
                      );
                    }
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedCategory != null
          ? BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                final isDoctor = (profileState is ProfileLoaded) && 
                    (profileState.user['role'] == 'doctor' || profileState.user['is_staff'] == true);
                
                return FloatingActionButton.extended(
                  onPressed: () => context.push('/create_room'),
                  backgroundColor: isDoctor ? const Color(0xFF0D9488) : AppTheme.butteryYellow,
                  label: Text(
                    isDoctor ? 'Host Medical Room' : 'Create Room',
                    style: TextStyle(
                      color: isDoctor ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(
                    isDoctor ? Icons.medical_services_outlined : Icons.add, 
                    color: isDoctor ? Colors.white : AppTheme.textDark
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          if (_selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() => _selectedCategory = null);
                context.read<RoomBloc>().add(RoomLoad(
                  search: _searchController.text.trim(),
                  sort: _sortMode,
                ));
              },
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedCategory == null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: AppTheme.cottonPink,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Safe Space',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Clubhouse',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ] else
                  Text(
                    _categories.firstWhere(
                      (c) => c['id'] == _selectedCategory,
                    )['name'],
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
              ],
            ),
          ),
          // Search icon + User Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search icon hidden (disabled for now)
              // User Avatar from ghost profile
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  final ghostName = (profileState is ProfileLoaded)
                      ? (profileState.user['ghost_profile']?['display_name'] ??
                            'User')
                      : 'User';
                  return Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      EmojiUtils.getEmojiForName(ghostName),
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element — kept for future use (search disabled)
  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '🔍 Search Rooms',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12.h),
              // Search field
              TextField(
                controller: _searchController,
                autofocus: true,
                onSubmitted: (val) {
                  Navigator.pop(ctx);
                  setState(() {});
                  context.read<RoomBloc>().add(
                    RoomLoad(
                      search: val.trim(),
                      category: _selectedCategory,
                      sort: _sortMode
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search by room name or topic...',
                  hintStyle: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setModalState(() {});
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16.w,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setModalState(() {}),
              ),
              SizedBox(height: 16.h),
              // Sort chips inside modal
              Text(
                'SORT BY',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGrey,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: ['recent', 'trending', 'scheduled'].map((mode) {
                  final isSelected = _sortMode == mode;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        setModalState(() => _sortMode = mode);
                        setState(() => _sortMode = mode);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          mode == 'recent'
                              ? '🕐 Recent'
                              : mode == 'trending'
                              ? '🔥 Trending'
                              : '📅 Scheduled',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
              // Search button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  label: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {});
                    context.read<RoomBloc>().add(
                      RoomLoad(
                        search: _searchController.text.trim(),
                        category: _selectedCategory,
                        sort: _sortMode,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guidelines
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.cottonPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppTheme.cottonPink.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room Guidelines',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'This is a safe space. Please be respectful and kind. All conversations are anonymous.',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            'Explore Topics',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.1,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = cat['id']);
                  context.read<RoomBloc>().add(
                    RoomLoad(
                      search: _searchController.text.trim(),
                      category: cat['id'],
                      sort: _sortMode,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cat['color'],
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: cat['borderColor']),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat['icon'], style: TextStyle(fontSize: 32.sp)),
                      SizedBox(height: 8.h),
                      Text(
                        cat['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildRoomListWithTabs(List<Map<String, dynamic>> allRooms) {
    return Column(
      children: [
        // Pill-style TabBar (matching Upcoming/History style)
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TabBar(
            controller: _tabController,
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            labelColor: AppTheme.textDark,
            unselectedLabelColor: AppTheme.textGrey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            tabs: const [
              Tab(text: '🏠 All Rooms'),
              Tab(text: '👥 Following'),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Rooms Tab
              _buildRoomList(allRooms),

              // Following Feed Tab
              BlocProvider(
                create: (context) =>
                    FollowingBloc(FollowingRepository(DioClient()))
                      ..add(FollowingFeedLoad()),
                child: BlocBuilder<FollowingBloc, FollowingState>(
                  builder: (context, state) {
                    if (state is FollowingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is FollowingFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48.sp,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Failed to load following feed',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<FollowingBloc>().add(
                                  FollowingFeedLoad(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is FollowingFeedLoaded) {
                      if (state.rooms.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('👻', style: TextStyle(fontSize: 64.sp)),
                              SizedBox(height: 16.h),
                              Text(
                                'No rooms from followed ghosts',
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

                      return _buildRoomList(state.rooms);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomList(List<dynamic> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No rooms yet', style: TextStyle(color: AppTheme.textGrey)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.push('/create_room'),
              child: const Text('Create the first room!'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<RoomBloc>().add(RoomLoad()),
      child: ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          // Assuming room structure from API: {id, title, host_details: {display_name}, listeners_count}
          final String title = room['title'] ?? 'Untitled Room';
          final String hostName =
              room['host_details']?['display_name'] ?? 'Unknown Host';
          final int listeners = room['listeners_count'] ?? 0;
          final String roomId = room['id'] ?? '';
          final DateTime? lastActiveAt = room['last_active_at'] != null
              ? DateTime.tryParse(room['last_active_at'])?.toLocal()
              : null;

          final String hostRole = room['host_details']?['role'] ?? 'patient';

          return _RoomCard(
            index: index,
            title: title,
            hostName: hostName,
            hostRole: hostRole,
            listeners: listeners,
            participantCount: room['participant_count'] ?? 0,
            lastActiveAt: lastActiveAt,
            createdAt: room['created_at'] != null 
                ? DateTime.parse(room['created_at']).toLocal() 
                : DateTime.now(),
            onTap: () => _joinRoom(context, roomId),
          );
        },
      ),
    );
  }

  void _joinRoom(BuildContext context, String roomId) {
    if (_isJoining) return; // Prevent double-tap
    _isJoining = true;
    context.read<RoomBloc>().add(RoomJoin(roomId));
  }
}

class _RoomCard extends StatefulWidget {
  final int index;
  final String title;
  final String hostName;
  final String hostRole;
  final int listeners;
  final int participantCount;
  final DateTime? lastActiveAt;
  final DateTime createdAt;
  final VoidCallback onTap;

  const _RoomCard({
    required this.index,
    required this.title,
    required this.hostName,
    required this.hostRole,
    required this.listeners,
    required this.participantCount,
    this.lastActiveAt,
    required this.createdAt,
    required this.onTap,
  });

  @override
  State<_RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<_RoomCard> {
  late final Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    // Random style based on index (simulating variety)
    final bgColors = widget.index % 2 == 0
        ? [
            AppTheme.skyBlue.withValues(alpha: 0.2),
            AppTheme.mintGreen.withValues(alpha: 0.2),
          ]
        : [
            AppTheme.butteryYellow.withValues(alpha: 0.2),
            AppTheme.cottonPink.withValues(alpha: 0.2),
          ];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: bgColors.last.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                if (widget.participantCount == 0 && 
                    widget.lastActiveAt != null && 
                    DateTime.now().difference(widget.createdAt).inSeconds > 45)
                  StreamBuilder<int>(
                    stream: _timerStream,
                    builder: (context, _) {
                      final now = DateTime.now();
                      final diff = now.difference(widget.lastActiveAt!);
                      final remaining = 60 - diff.inSeconds;

                      if (remaining <= 0) return const SizedBox();

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Closing in ${remaining}s',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.error,
                          ),
                        ),
                      );
                    },
                  ),
                if (widget.hostRole == 'doctor')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user, color: Colors.white, size: 10),
                        SizedBox(width: 4.w),
                        Text(
                          'DOCTOR',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.hostRole == 'admin')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'OFFICIAL',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  EmojiUtils.getEmojiForName(widget.hostName),
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Hosted by ${widget.hostName}',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          EmojiUtils.getEmojiForName(widget.hostName),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      EmojiUtils.getNameWithoutTag(widget.hostName),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 16.sp, color: AppTheme.textGrey),
                      SizedBox(width: 4.w),
                      Text(
                        '${widget.listeners} listening',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
