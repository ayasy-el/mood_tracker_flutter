import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              // TODO: Open settings
            },
            child: Icon(
              CupertinoIcons.settings,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: EdgeInsets.all(Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://i.pravatar.cc/300',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          Text(
            'Alex Johnson',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Member since April 4, 2025',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('31', 'Check-ins'),
          _buildStatItem('7', 'Day Streak'),
          _buildStatItem('Calm', 'Top Mood'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(Layout.spacing.l),
            child: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildSettingItem(
            icon: CupertinoIcons.bell,
            label: 'Daily Reminder',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '20:00',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: Layout.spacing.s),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          _buildSettingItem(
            icon: CupertinoIcons.moon,
            label: 'Dark Mode',
            trailing: CupertinoSwitch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          _buildSettingItem(
            icon: CupertinoIcons.lock,
            label: 'Private Journal',
            trailing: CupertinoSwitch(
              value: true,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: Layout.spacing.m),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      margin: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
        border: Border.all(
          color: AppColors.error,
          width: 1,
        ),
      ),
      child: CupertinoButton(
        onPressed: () {
          // TODO: Implement sign out
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.arrow_right_square,
              color: AppColors.error,
            ),
            SizedBox(width: Layout.spacing.s),
            Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'Smart Mood Tracker v1.0.0',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.textSecondary,
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
              _buildProfileInfo(),
              _buildStats(),
              _buildSettingsSection(),
              _buildSignOutButton(),
              SizedBox(height: Layout.spacing.m),
              _buildAppVersion(),
              SizedBox(height: Layout.spacing.l),
            ],
          ),
        ),
      ),
    );
  }
}
