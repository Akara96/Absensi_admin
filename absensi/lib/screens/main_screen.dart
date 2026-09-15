import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'attendance_screen.dart';
import 'history_screen.dart';
import 'leave_request_screen.dart';
import 'overtime_request_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _updateTimer;
  final List<Widget> _screens = [
    const AttendanceScreen(),
    const HistoryScreen(),
    const LeaveRequestScreen(),
    const OvertimeRequestScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cek pertama kali saat buka app
    _checkConfigUpdate();
    // Cek berkala setiap 5 menit
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkConfigUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConfigUpdate();
    }
  }

  Future<void> _checkConfigUpdate() async {
    try {
      final settings = await ApiService.getPengaturanSistem();
      final updatedAt = settings['updated_at'] as String?;
      final lastMsg = settings['last_message'] as String? ?? 'Iha mudansa foun iha sistema.';

      if (updatedAt == null) return;

      final prefs = await SharedPreferences.getInstance();
      final lastSeen = prefs.getString('last_config_update');

      if (lastSeen != updatedAt) {
        if (!mounted) return;
        
        // Tampilkan Banner
        ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            padding: const EdgeInsets.all(16),
            content: Text(
              lastMsg,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.notifications_active, color: Colors.orange),
            ),
            backgroundColor: Colors.teal.shade700,
            actions: [
              TextButton(
                onPressed: () async {
                  await prefs.setString('last_config_update', updatedAt);
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  }
                },
                child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking config update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.co_present_outlined),
            selectedIcon: Icon(Icons.co_present),
            label: 'Presensa',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Istória',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_copy_outlined),
            selectedIcon: Icon(Icons.file_copy),
            label: 'Lisensa',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_history_outlined),
            selectedIcon: Icon(Icons.work_history),
            label: 'Lembur',
          ),
        ],
      ),
    );
  }
}
