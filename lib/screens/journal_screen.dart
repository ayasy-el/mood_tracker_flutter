import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/utils/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Text(
        'Journal',
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      child: Text(
        'Record your thoughts, feelings, and experiences. Writing in a journal can help you process emotions and gain insights.',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Layout.spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.book,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
            SizedBox(height: Layout.spacing.l),
            Text(
              'No Journal Entries Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: Layout.spacing.m),
            Text(
              'Start journaling to track your thoughts and feelings alongside your mood.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: Layout.spacing.xl),
            CupertinoButton(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              padding: EdgeInsets.symmetric(
                horizontal: Layout.spacing.xl,
                vertical: Layout.spacing.m,
              ),
              onPressed: () {
                // TODO: Implement new entry creation
              },
              child: Text(
                'Create First Entry',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalList() {
    final entries = generateMockJournalEntries();
    return ListView.builder(
      padding: EdgeInsets.all(Layout.spacing.l),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          margin: EdgeInsets.only(bottom: Layout.spacing.m),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(Layout.borderRadius.large),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: EdgeInsets.all(Layout.spacing.l),
            onPressed: () {
              // TODO: Implement entry details view
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (entry.associatedMood != null) ...[
                      Container(
                        padding: EdgeInsets.all(Layout.spacing.s),
                        decoration: BoxDecoration(
                          color: AppColors.getMoodColor(
                            entry.associatedMood!.mood
                                .toString()
                                .split('.')
                                .last,
                          ).withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(Layout.borderRadius.small),
                        ),
                        child: Icon(
                          CupertinoIcons.smiley,
                          size: 16,
                          color: AppColors.getMoodColor(
                            entry.associatedMood!.mood
                                .toString()
                                .split('.')
                                .last,
                          ),
                        ),
                      ),
                      SizedBox(width: Layout.spacing.s),
                    ],
                    Text(
                      DateFormat('MMM d, h:mm a').format(entry.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: Layout.spacing.m),
                Text(
                  entry.content,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = generateMockJournalEntries();

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: entries.isEmpty
          ? null
          : CupertinoNavigationBar(
              backgroundColor:
                  CupertinoColors.systemBackground.withOpacity(0.8),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // TODO: Implement new entry creation
                },
                child: const Icon(
                  CupertinoIcons.add,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDescription(),
            SizedBox(height: Layout.spacing.l),
            Expanded(
              child: entries.isEmpty ? _buildEmptyState() : _buildJournalList(),
            ),
          ],
        ),
      ),
    );
  }
}
