import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/utils/string_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/screens/journal_entry_screen.dart';
import 'package:mood_tracker_flutter/providers/firebase_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeTab = 'analytics';
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<MoodEntry>> _entriesByDate = {};

  List<MoodEntry> _filterEntries(List<MoodEntry> entries) {
    if (_activeTab == 'calendar') {
      return entries.where((entry) {
        return entry.timestamp.year == _selectedDate.year &&
            entry.timestamp.month == _selectedDate.month &&
            entry.timestamp.day == _selectedDate.day;
      }).toList();
    } else {
      return List.from(entries);
    }
  }

  Map<DateTime, List<MoodEntry>> _organizeEntriesByDate(
      List<MoodEntry> entries) {
    final map = <DateTime, List<MoodEntry>>{};
    for (var entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(entry);
    }
    return map;
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.l,
        vertical: Layout.spacing.m,
      ),
      child: Text(
        'Mood History',
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: Layout.spacing.l, vertical: Layout.spacing.s),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: CupertinoSlidingSegmentedControl<String>(
        groupValue: _activeTab,
        onValueChanged: (value) {
          if (value != null) {
            setState(() => _activeTab = value);
          }
        },
        backgroundColor: CupertinoColors.systemBackground,
        children: {
          'analytics': Container(
            padding: EdgeInsets.symmetric(vertical: Layout.spacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 18,
                  color: _activeTab == 'analytics'
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                SizedBox(width: Layout.spacing.s),
                Text(
                  'Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _activeTab == 'analytics'
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          'calendar': Container(
            padding: EdgeInsets.symmetric(vertical: Layout.spacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 18,
                  color: _activeTab == 'calendar'
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                SizedBox(width: Layout.spacing.s),
                Text(
                  'Calendar',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _activeTab == 'calendar'
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }

  Widget _buildMoodTrend() {
    final moodData = _entriesByDate.values.expand((e) => e).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (moodData.isEmpty) {
      return Center(
        child: Text(
          'No mood data available',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Get last 7 days of data
    final last7Days = moodData.where((entry) {
      final now = DateTime.now();
      final difference = now.difference(entry.timestamp).inDays;
      return difference <= 7;
    }).toList();

    // Calculate mood score based on mood type and intensity
    double getMoodScore(MoodEntry entry) {
      final baseScore = entry.intensity.toDouble();
      switch (entry.mood.toLowerCase()) {
        case 'happy':
          return baseScore * 1.5;
        case 'excited':
          return baseScore * 1.3;
        case 'calm':
          return baseScore * 1.2;
        case 'neutral':
          return baseScore;
        case 'tired':
          return baseScore * 0.8;
        case 'anxious':
          return baseScore * 0.6;
        case 'sad':
          return baseScore * 0.5;
        case 'angry':
          return baseScore * 0.4;
        default:
          return baseScore;
      }
    }

    final spots = last7Days.asMap().entries.map((entry) {
      final score = getMoodScore(entry.value);
      return FlSpot(entry.key.toDouble(), score);
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-Day Mood Trend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.primary.withOpacity(0.05),
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final entry = last7Days[spot.x.toInt()];
                        return LineTooltipItem(
                          '${entry.mood}\nIntensity: ${entry.intensity}',
                          GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 15, // Maximum possible score (10 * 1.5)
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStats() {
    final moodData = _entriesByDate.values.expand((e) => e).toList();

    if (moodData.isEmpty) return const SizedBox.shrink();

    final avgIntensity =
        moodData.map((e) => e.intensity).reduce((a, b) => a + b) /
            moodData.length;

    final moodFrequency = <String, int>{};
    for (final mood in moodData) {
      moodFrequency[mood.mood] = (moodFrequency[mood.mood] ?? 0) + 1;
    }

    final mostFrequentMood =
        moodFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

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
          _buildStatItem('Total\nCheck-ins', moodData.length.toString()),
          _buildStatItem('Day\nStreak', '7'),
          _buildStatItem(
            'Avg\nIntensity',
            avgIntensity.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMostFrequentMood() {
    final moodData = _entriesByDate.values.expand((e) => e).toList();

    if (moodData.isEmpty) return const SizedBox.shrink();

    final moodFrequency = <String, int>{};
    for (final mood in moodData) {
      moodFrequency[mood.mood] = (moodFrequency[mood.mood] ?? 0) + 1;
    }

    final mostFrequentMood =
        moodFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Frequent Mood',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          Row(
            children: [
              Icon(
                getMoodIcon(mostFrequentMood),
                color: AppColors.getMoodColor(mostFrequentMood),
                size: 24,
              ),
              SizedBox(width: Layout.spacing.m),
              Text(
                mostFrequentMood.capitalize(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry) {
    final moodColor = AppColors.getMoodColor(entry.mood);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => JournalEntryScreen(existingEntry: entry),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Layout.spacing.m),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(Layout.borderRadius.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Layout.spacing.l),
              child: Row(
                children: [
                  Icon(
                    getMoodIcon(entry.mood),
                    color: moodColor,
                    size: 24,
                  ),
                  SizedBox(width: Layout.spacing.m),
                  Text(
                    entry.mood.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('EEEE, MMM d').format(entry.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(Layout.borderRadius.small),
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
            Padding(
              padding: EdgeInsets.all(Layout.spacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intensity: ${entry.intensity}/10',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (entry.content.isNotEmpty) ...[
                    SizedBox(height: Layout.spacing.m),
                    Text(
                      entry.content,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                  if (entry.tags.isNotEmpty) ...[
                    SizedBox(height: Layout.spacing.m),
                    Wrap(
                      spacing: Layout.spacing.s,
                      children: entry.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Layout.spacing.m,
                            vertical: Layout.spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                Layout.borderRadius.small),
                          ),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Layout.spacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                Layout.spacing.l, Layout.spacing.l, Layout.spacing.l, 0),
            child: Material(
              color: Colors.transparent,
              child: TableCalendar<MoodEntry>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _selectedDate,
                currentDay: DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                eventLoader: (day) =>
                    _entriesByDate[DateTime(
                      day.year,
                      day.month,
                      day.day,
                    )] ??
                    [],
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  canMarkersOverflow: false,
                  markerSize: 6,
                  markerMargin: const EdgeInsets.only(top: 4),
                  cellMargin: const EdgeInsets.all(4),
                  cellPadding: const EdgeInsets.all(0),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(
                    CupertinoIcons.chevron_left,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  rightChevronIcon: Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  titleCentered: true,
                  headerPadding: const EdgeInsets.symmetric(vertical: 8),
                  headerMargin: const EdgeInsets.all(0),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                Layout.spacing.l, Layout.spacing.l, Layout.spacing.l, 0),
            child: Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_filterEntries(_entriesByDate.values.expand((e) => e).toList())
              .isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(Layout.spacing.l, Layout.spacing.m,
                  Layout.spacing.l, Layout.spacing.l),
              child: Column(
                children: _filterEntries(
                        _entriesByDate.values.expand((e) => e).toList())
                    .map((entry) => _buildMoodEntryCard(entry))
                    .toList(),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(Layout.spacing.l, Layout.spacing.xl,
                  Layout.spacing.l, Layout.spacing.l),
              child: Center(
                child: Text(
                  'No entries for this date',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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

            final entries = provider.moodEntries;
            final filteredEntries = _filterEntries(entries);
            _entriesByDate = _organizeEntriesByDate(entries);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildTabs(),
                Expanded(
                  child: _activeTab == 'analytics'
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Layout.spacing.l),
                              _buildMoodTrend(),
                              SizedBox(height: Layout.spacing.l),
                              _buildMoodStats(),
                              SizedBox(height: Layout.spacing.l),
                              _buildMostFrequentMood(),
                              Padding(
                                padding: EdgeInsets.all(Layout.spacing.l),
                                child: Text(
                                  'Recent Mood Entries',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Layout.spacing.l,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: entries.length,
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    return _buildMoodEntryCard(entry);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildCalendarView(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
