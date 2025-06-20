import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/screens/journal_entry_screen.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker_flutter/providers/firebase_provider.dart';
import 'package:provider/provider.dart';

// !Todo: Get realtime data from firebase

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;

  List<MoodEntry> _filterEntries(List<MoodEntry> entries) {
    if (_showCalendar) {
      return entries.where((entry) {
        return entry.timestamp.year == _selectedDate.year &&
            entry.timestamp.month == _selectedDate.month &&
            entry.timestamp.day == _selectedDate.day;
      }).toList();
    } else {
      return List.from(entries);
    }
  }

  Future<void> _addEntry() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const JournalEntryScreen(),
      ),
    );
  }

  Future<void> _editEntry(MoodEntry entry) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => JournalEntryScreen(existingEntry: entry),
      ),
    );
  }

  void _deleteEntry(MoodEntry entry) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Delete Entry',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this journal entry?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context
                    .read<FirebaseProvider>()
                    .deleteMoodEntry(entry.id!);
              } catch (e) {
                if (mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: Text('Error'),
                      content:
                          Text('Failed to delete entry. Please try again.'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journal',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _showCalendar = !_showCalendar;
                      });
                    },
                    child: Icon(
                      _showCalendar
                          ? CupertinoIcons.calendar_badge_minus
                          : CupertinoIcons.calendar_badge_plus,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _addEntry,
                    child: Icon(
                      CupertinoIcons.add_circled_solid,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'Record your thoughts, feelings, and experiences.\nWriting in a journal can help you process emotions and gain insights.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
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
              onPressed: _addEntry,
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

  Widget _buildJournalList(List<MoodEntry> entries) {
    return ListView.builder(
      padding: EdgeInsets.all(Layout.spacing.l),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final moodColor = AppColors.getMoodColor(entry.mood);

        return Container(
          margin: EdgeInsets.only(bottom: Layout.spacing.m),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(Layout.borderRadius.large),
          ),
          child: CupertinoContextMenu(
            actions: [
              CupertinoContextMenuAction(
                child: Row(
                  children: [
                    Icon(CupertinoIcons.pencil),
                    SizedBox(width: Layout.spacing.s),
                    Text('Edit'),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _editEntry(entry);
                },
              ),
              CupertinoContextMenuAction(
                isDestructiveAction: true,
                child: Row(
                  children: [
                    Icon(CupertinoIcons.delete),
                    SizedBox(width: Layout.spacing.s),
                    Text('Delete'),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteEntry(entry);
                },
              ),
            ],
            child: CupertinoButton(
              padding: EdgeInsets.all(Layout.spacing.l),
              onPressed: () => _editEntry(entry),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Layout.spacing.s),
                  Row(
                    children: [
                      Icon(
                        getMoodIcon(entry.mood),
                        size: 18,
                        color: moodColor,
                      ),
                      SizedBox(width: Layout.spacing.s),
                      Expanded(
                        child: Text(
                          entry.mood.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Layout.spacing.s),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(Layout.borderRadius.small),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: entry.intensity / 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: moodColor,
                          borderRadius:
                              BorderRadius.circular(Layout.borderRadius.small),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Layout.spacing.m),
                  Text(
                    entry.content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.feelings.isNotEmpty) ...[
                    SizedBox(height: Layout.spacing.m),
                    Wrap(
                      spacing: Layout.spacing.s,
                      children: entry.feelings.map((feeling) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Layout.spacing.m,
                            vertical: Layout.spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                Layout.borderRadius.small),
                          ),
                          child: Text(
                            feeling,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: moodColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return CupertinoIcons.smiley;
      case 'sad':
        return CupertinoIcons.smiley_fill;
      case 'angry':
        return CupertinoIcons.exclamationmark_circle_fill;
      case 'anxious':
        return CupertinoIcons.exclamationmark_circle;
      case 'calm':
        return CupertinoIcons.smiley;
      case 'excited':
        return CupertinoIcons.star;
      case 'tired':
        return CupertinoIcons.moon_fill;
      case 'neutral':
        return CupertinoIcons.smiley;
      default:
        return CupertinoIcons.smiley;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Consumer<FirebaseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final filteredEntries = _filterEntries(provider.moodEntries);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: filteredEntries.isEmpty
                      ? _buildEmptyState()
                      : _buildJournalList(filteredEntries),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
