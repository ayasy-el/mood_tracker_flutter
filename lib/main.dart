import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/screens/mood_check_in_screen.dart';
import 'package:mood_tracker_flutter/screens/history_screen.dart';
import 'package:mood_tracker_flutter/screens/journal_screen.dart';
import 'package:mood_tracker_flutter/screens/profile_screen.dart';
import 'package:mood_tracker_flutter/providers/firebase_provider.dart';
import 'package:mood_tracker_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MoodTrackerApp());
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirebaseProvider()..initialize(),
      child: CupertinoApp(
        title: 'Mood Tracker',
        theme: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MoodCheckInScreen(),
    const HistoryScreen(),
    const JournalScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CupertinoActivityIndicator();
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: CupertinoColors.destructiveRed),
                ),
                CupertinoButton(
                  child: const Text('Retry'),
                  onPressed: () {
                    provider.clearError();
                    provider.initialize();
                  },
                ),
              ],
            ),
          );
        }

        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.camera),
                label: 'Check-in',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_alt_fill),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book),
                label: 'Journal',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                label: 'Profile',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (context) => _screens[index],
            );
          },
        );
      },
    );
  }
}
