import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/utils/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profile = mockUserProfile;
  final _stats = getMockMoodStats();
  bool _darkMode = false;
  bool _privateJournal = true;

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: Implement settings
            },
            child: const Icon(
              CupertinoIcons.settings,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(_profile.avatar!),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 3,
              ),
            ),
          ),
          SizedBox(width: Layout.spacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Member since ${DateFormat('MMMM d, yyyy').format(_profile.joinDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.all(Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Check-ins', _stats['totalEntries'].toString()),
          Container(
            width: 1,
            height: 40,
            color: CupertinoColors.systemGrey4,
            margin: EdgeInsets.symmetric(horizontal: Layout.spacing.m),
          ),
          _buildStatItem('Day Streak', _profile.streakDays.toString()),
          Container(
            width: 1,
            height: 40,
            color: CupertinoColors.systemGrey4,
            margin: EdgeInsets.symmetric(horizontal: Layout.spacing.m),
          ),
          _buildStatItem(
              'Top Mood', _stats['mostFrequentMood'].toString().toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
          child: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: Layout.spacing.l,
            vertical: Layout.spacing.m,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(Layout.borderRadius.large),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: CupertinoIcons.bell,
                label: 'Daily Reminder',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _profile.preferences.reminderTime ?? 'Not set',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: Implement reminder settings
                },
              ),
              _buildSettingItem(
                icon: CupertinoIcons.moon,
                label: 'Dark Mode',
                trailing: CupertinoSwitch(
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                  activeTrackColor: AppColors.primary,
                ),
              ),
              _buildSettingItem(
                icon: CupertinoIcons.lock,
                label: 'Private Journal',
                trailing: CupertinoSwitch(
                  value: _privateJournal,
                  onChanged: (value) => setState(() => _privateJournal = value),
                  activeTrackColor: AppColors.primary,
                ),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Layout.spacing.l,
          vertical: Layout.spacing.m,
        ),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Layout.spacing.s),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Layout.borderRadius.small),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: Layout.spacing.m),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: EdgeInsets.all(Layout.spacing.l),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(vertical: Layout.spacing.m),
        color: CupertinoColors.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
        onPressed: () {
          // TODO: Implement sign out
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.square_arrow_right,
              color: CupertinoColors.systemRed,
              size: 20,
            ),
            SizedBox(width: Layout.spacing.m),
            Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Layout.spacing.l),
        child: Text(
          'Smart Mood Tracker v1.0.0',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildProfileSection(),
              _buildStatsSection(),
              SizedBox(height: Layout.spacing.m),
              _buildSettingsSection(),
              _buildSignOutButton(),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
