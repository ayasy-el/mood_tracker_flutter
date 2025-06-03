import 'package:flutter/material.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodSelector extends StatefulWidget {
  final Function(MoodType mood, int intensity) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  MoodType? _selectedMood;
  int _intensity = 5;

  final List<Map<String, dynamic>> _moods = [
    {
      'type': MoodType.happy,
      'icon': Icons.sentiment_very_satisfied,
      'label': 'Happy'
    },
    {
      'type': MoodType.sad,
      'icon': Icons.sentiment_very_dissatisfied,
      'label': 'Sad'
    },
    {'type': MoodType.angry, 'icon': Icons.mood_bad, 'label': 'Angry'},
    {
      'type': MoodType.neutral,
      'icon': Icons.sentiment_neutral,
      'label': 'Neutral'
    },
    {'type': MoodType.excited, 'icon': Icons.celebration, 'label': 'Excited'},
  ];

  void _handleMoodSelection() {
    if (_selectedMood != null) {
      widget.onMoodSelected(_selectedMood!, _intensity);
    }
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        final mood = _moods[index];
        final isSelected = _selectedMood == mood['type'];

        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['type']),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.getMoodColor(
                          mood['type'].toString().split('.').last)
                      .withOpacity(0.1)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              border: Border.all(
                color: isSelected
                    ? AppColors.getMoodColor(
                        mood['type'].toString().split('.').last)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mood['icon'],
                  size: 32,
                  color: AppColors.getMoodColor(
                      mood['type'].toString().split('.').last),
                ),
                SizedBox(height: Layout.spacing.s),
                Text(
                  mood['label'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.getMoodColor(
                            mood['type'].toString().split('.').last)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How intense is this feeling?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Layout.spacing.m),
        Row(
          children: [
            const Text('1'),
            Expanded(
              child: Slider(
                value: _intensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _intensity.toString(),
                onChanged: (value) =>
                    setState(() => _intensity = value.round()),
              ),
            ),
            const Text('10'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Layout.spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select your mood',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Layout.spacing.l),
          _buildMoodGrid(),
          SizedBox(height: Layout.spacing.xl),
          if (_selectedMood != null) ...[
            _buildIntensitySlider(),
            SizedBox(height: Layout.spacing.xl),
            ElevatedButton(
              onPressed: _handleMoodSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: Layout.spacing.m),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.medium),
                ),
              ),
              child: Text(
                'Confirm Mood',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
