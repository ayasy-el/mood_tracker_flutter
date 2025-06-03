import 'package:flutter/material.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/widgets/mood_detector.dart';
import 'package:mood_tracker_flutter/widgets/mood_selector.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  bool _showResults = false;
  String _activeTab = 'camera';
  MoodEntry? _currentMood;
  bool _isProcessing = false;

  // Mock user data
  final String _userName = "User";

  void _handleMoodDetected(MoodType mood, int intensity) {
    setState(() {
      _currentMood = MoodEntry(
        mood: mood,
        intensity: intensity,
        timestamp: DateTime.now(),
        source: _activeTab,
      );
      _showResults = true;
    });
  }

  void _saveCurrentMood() {
    if (_currentMood != null) {
      // TODO: Implement mood saving logic
      setState(() {
        _showResults = false;
        _currentMood = null;
      });
    }
  }

  void _resetDetection() {
    setState(() {
      _showResults = false;
      _currentMood = null;
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24),
          Text(
            'Mood Check-in',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $_userName!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How are you feeling today?',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      child: Row(
        children: [
          _buildTab('camera', Icons.camera_alt),
          SizedBox(width: Layout.spacing.m),
          _buildTab('manual', Icons.emoji_emotions),
        ],
      ),
    );
  }

  Widget _buildTab(String tab, IconData icon) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Layout.spacing.l,
          vertical: Layout.spacing.m,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(Layout.borderRadius.medium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: Layout.spacing.s),
            Text(
              tab.substring(0, 1).toUpperCase() + tab.substring(1),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_showResults && _currentMood != null) {
      return _buildMoodResults();
    }

    if (_activeTab == 'camera') {
      return MoodDetector(onMoodDetected: _handleMoodDetected);
    } else {
      return MoodSelector(onMoodSelected: _handleMoodDetected);
    }
  }

  Widget _buildMoodResults() {
    return Padding(
      padding: EdgeInsets.all(Layout.spacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Current Mood',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Layout.spacing.l),
          Container(
            padding: EdgeInsets.all(Layout.spacing.l),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_emotions,
                  size: 64,
                  color: AppColors.getMoodColor(
                      _currentMood!.mood.toString().split('.').last),
                ),
                SizedBox(height: Layout.spacing.m),
                Text(
                  _currentMood!.mood.toString().split('.').last.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getMoodColor(
                        _currentMood!.mood.toString().split('.').last),
                  ),
                ),
                SizedBox(height: Layout.spacing.s),
                Text(
                  'Intensity: ${_currentMood!.intensity}/10',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: Layout.spacing.l),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveCurrentMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: Layout.spacing.xl,
                          vertical: Layout.spacing.m,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Layout.borderRadius.medium),
                        ),
                      ),
                      child: Text(
                        'Save Mood',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resetDetection,
                      child: Text(
                        'Try Again',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildGreeting(),
            if (!_showResults) ...[
              _buildTabs(),
              SizedBox(height: Layout.spacing.l),
            ],
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
