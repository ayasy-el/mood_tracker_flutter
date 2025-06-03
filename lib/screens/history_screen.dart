import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/utils/mock_data.dart';
import 'package:mood_tracker_flutter/utils/string_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mood_tracker_flutter/models/mood.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeTab = 'analytics';
  final _moodHistory = generateMockMoodHistory();
  final _moodStats = getMockMoodStats();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

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
      margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
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
        backgroundColor: CupertinoColors.white,
        thumbColor: CupertinoColors.white,
        children: {
          'analytics':
              _buildTabItem('Analytics', CupertinoIcons.chart_bar_alt_fill),
          'calendar': _buildTabItem('Calendar', CupertinoIcons.calendar),
        },
      ),
    );
  }

  Widget _buildTabItem(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Layout.spacing.m,
        vertical: Layout.spacing.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: _activeTab == label.toLowerCase()
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          SizedBox(width: Layout.spacing.s),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _activeTab == label.toLowerCase()
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendChart() {
    return Container(
      height: 200,
      margin: EdgeInsets.all(Layout.spacing.l),
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
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _moodHistory.length) {
                          return Text(
                            DateFormat('E')
                                .format(_moodHistory[index].timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _moodHistory.length - 1.0,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(_moodHistory.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        _moodHistory[index].intensity.toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: CupertinoColors.white,
                        );
                      },
                    ),
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

  Widget _buildStatCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildStatCard('Total\nCheck-ins',
                      _moodStats['totalEntries'].toString())),
              SizedBox(width: Layout.spacing.m),
              Expanded(
                  child: _buildStatCard(
                      'Day\nStreak', _moodStats['streakDays'].toString())),
              SizedBox(width: Layout.spacing.m),
              Expanded(
                  child: _buildStatCard('Avg\nIntensity',
                      _moodStats['averageIntensity'].toString())),
            ],
          ),
          SizedBox(height: Layout.spacing.m),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Layout.spacing.l),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(Layout.borderRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Frequent Mood',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: Layout.spacing.s),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.smiley,
                      color: AppColors.getMoodColor(
                          _moodStats['mostFrequentMood']),
                      size: 24,
                    ),
                    SizedBox(width: Layout.spacing.s),
                    Text(
                      _moodStats['mostFrequentMood'].toString().capitalize(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getMoodColor(
                            _moodStats['mostFrequentMood']),
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

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(Layout.spacing.m),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.medium),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
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
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _moodHistory.length,
          padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
          itemBuilder: (context, index) {
            final entry = _moodHistory[index];
            final moodColor = AppColors.getMoodColor(
              entry.mood.toString().split('.').last,
            );

            return Container(
              margin: EdgeInsets.only(bottom: Layout.spacing.m),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(Layout.borderRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(Layout.spacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.smiley,
                          color: moodColor,
                          size: 20,
                        ),
                        SizedBox(width: Layout.spacing.s),
                        Text(
                          entry.mood.toString().split('.').last.capitalize(),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: moodColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('EEEE, MMM d').format(entry.timestamp) +
                              '\n' +
                              DateFormat('h:mm a').format(entry.timestamp),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Layout.spacing.m),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: entry.intensity / 10,
                        backgroundColor: moodColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(moodColor),
                        minHeight: 3,
                      ),
                    ),
                    SizedBox(height: Layout.spacing.s),
                    Text(
                      'Intensity: ${entry.intensity}/10',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (entry.note != null) ...[
                      SizedBox(height: Layout.spacing.m),
                      Text(
                        entry.note!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    if (entry.note != null) ...[
                      SizedBox(height: Layout.spacing.m),
                      Wrap(
                        spacing: Layout.spacing.s,
                        children: [
                          'family',
                          'relaxation',
                          'work',
                          'stress',
                        ]
                            .where((tag) =>
                                entry.note!.toLowerCase().contains(tag))
                            .map((tag) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Layout.spacing.m,
                                    vertical: Layout.spacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(
                                        Layout.borderRadius.small),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalytics() {
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            // TODO: Implement refresh
            await Future.delayed(const Duration(seconds: 1));
          },
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodTrendChart(),
              _buildStatCards(),
              _buildMoodEntries(),
              SizedBox(height: Layout.spacing.l),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month - 3, today.day);
    final lastDay = DateTime(today.year, today.month + 3, today.day);

    // Filter entries for selected day
    final selectedDayEntries = _moodHistory
        .where((entry) =>
            entry.timestamp.year == _selectedDay.year &&
            entry.timestamp.month == _selectedDay.month &&
            entry.timestamp.day == _selectedDay.day)
        .toList();

    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
            child: TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle:
                    GoogleFonts.poppins(color: AppColors.textSecondary),
                defaultTextStyle: GoogleFonts.poppins(),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
              eventLoader: (day) {
                return _moodHistory
                    .where((entry) =>
                        entry.timestamp.year == day.year &&
                        entry.timestamp.month == day.month &&
                        entry.timestamp.day == day.day)
                    .toList();
              },
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM d, y').format(_selectedDay),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedDayEntries.length} entries',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          Expanded(
            child: selectedDayEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: Layout.spacing.m),
                        Text(
                          'No entries for this day',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(Layout.spacing.l),
                    itemCount: selectedDayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = selectedDayEntries[index];
                      final moodColor = AppColors.getMoodColor(
                        entry.mood.toString().split('.').last,
                      );

                      return Container(
                        margin: EdgeInsets.only(bottom: Layout.spacing.m),
                        padding: EdgeInsets.all(Layout.spacing.m),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius:
                              BorderRadius.circular(Layout.borderRadius.medium),
                          border: Border.all(
                            color: CupertinoColors.systemGrey5,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(Layout.spacing.s),
                              decoration: BoxDecoration(
                                color: moodColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    Layout.borderRadius.small),
                              ),
                              child: Icon(
                                CupertinoIcons.smiley,
                                color: moodColor,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: Layout.spacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.mood
                                        .toString()
                                        .split('.')
                                        .last
                                        .capitalize(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (entry.note != null)
                                    Text(
                                      entry.note!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: Layout.spacing.m),
                            Text(
                              DateFormat('h:mm a').format(entry.timestamp),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(),
            SizedBox(height: Layout.spacing.l),
            Expanded(
              child: _activeTab == 'analytics'
                  ? _buildAnalytics()
                  : _buildCalendar(),
            ),
          ],
        ),
      ),
    );
  }
}
