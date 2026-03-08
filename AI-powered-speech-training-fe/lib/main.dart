import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/topic.dart';
import 'models/recording.dart';
import 'services/api_service.dart';
import 'screens/auth_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/topic_feed_screen.dart';
import 'screens/history_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/topic_management_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/recording_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Speaking Practice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _currentRole;
  Map<String, dynamic>? _currentUser;
  int _currentUserTab = 0;
  int _currentAdminTab = 0;

  void _handleAuthenticated(Map<String, dynamic> user) {
    setState(() {
      _currentUser = user;
      _currentRole = user['role'];
      _currentUserTab = 0;
      _currentAdminTab = 0;
    });
  }

  void _handleRoleSelected(String role) {
    setState(() {
      _currentRole = role;
      _currentUserTab = 0;
      _currentAdminTab = 0;
    });
  }

  void _handleLogout() {
    ApiService.setToken(null);
    setState(() {
      _currentRole = null;
      _currentUser = null;
      _currentUserTab = 0;
      _currentAdminTab = 0;
    });
  }

  void _handleSelectTopic(Topic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(topic: topic),
      ),
    );
  }

  void _handleViewRecording(Recording recording) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingDetailScreen(recording: recording),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auth screen (when no user logged in)
    if (_currentUser == null) {
      return AuthScreen(onAuthenticated: _handleAuthenticated);
    }

    // User interface
    if (_currentRole == 'user') {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Speaking Practice',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'User Mode',
                    style: TextStyle(fontSize: 11, color: AppColors.gray600),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                (_currentUser?['username'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Đăng xuất'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Tabs
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.gray200),
                ),
              ),
              child: Row(
                children: [
                  _TabButton(
                    icon: Icons.book_outlined,
                    label: 'Topics',
                    isSelected: _currentUserTab == 0,
                    onTap: () => setState(() => _currentUserTab = 0),
                  ),
                  _TabButton(
                    icon: Icons.history,
                    label: 'Lịch sử',
                    isSelected: _currentUserTab == 1,
                    onTap: () => setState(() => _currentUserTab = 1),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _currentUserTab == 0
                    ? TopicFeedScreen(onSelectTopic: _handleSelectTopic)
                    : HistoryScreen(onViewRecording: _handleViewRecording),
              ),
            ),
          ],
        ),
      );
    }

    // Admin interface
    if (_currentRole == 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, Colors.pink],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Speaking Practice',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(fontSize: 11, color: AppColors.gray600),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            CircleAvatar(
              backgroundColor: AppColors.secondary.withOpacity(0.1),
              child: Text(
                (_currentUser?['username'] ?? 'A')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Đăng xuất'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Tabs
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.gray200),
                ),
              ),
              child: Row(
                children: [
                  _TabButton(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isSelected: _currentAdminTab == 0,
                    onTap: () => setState(() => _currentAdminTab = 0),
                  ),
                  _TabButton(
                    icon: Icons.book_outlined,
                    label: 'Quản lý Topics',
                    isSelected: _currentAdminTab == 1,
                    onTap: () => setState(() => _currentAdminTab = 1),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _currentAdminTab == 0
                    ? const AdminDashboardScreen()
                    : const TopicManagementScreen(),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.gray600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}