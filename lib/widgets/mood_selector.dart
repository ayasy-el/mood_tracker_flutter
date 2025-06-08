import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/constants/moods.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodSelector extends StatefulWidget {
  final Function(
          String mood, List<String> feelings, List<String> tags, int intensity)
      onMoodSelected;
  final String? initialMood;
  final List<String>? initialFeelings;
  final List<String>? initialTags;
  final int? initialIntensity;

  const MoodSelector({
    super.key,
    required this.onMoodSelected,
    this.initialMood,
    this.initialFeelings,
    this.initialTags,
    this.initialIntensity,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  String? _selectedMood;
  List<String> _selectedFeelings = [];
  List<String> _selectedTags = [];
  int _intensity = 5;
  final TextEditingController _feelingsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
    _selectedFeelings = widget.initialFeelings ?? [];
    _selectedTags = widget.initialTags ?? [];
    _intensity = widget.initialIntensity ?? 5;
  }

  @override
  void dispose() {
    _feelingsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleMoodSelection() {
    if (_selectedMood != null) {
      widget.onMoodSelected(
          _selectedMood!, _selectedFeelings, _selectedTags, _intensity);
    }
  }

  void _addFeeling() {
    final feeling = _feelingsController.text.trim();
    if (feeling.isNotEmpty) {
      setState(() {
        if (!_selectedFeelings.contains(feeling) &&
            _selectedFeelings.length < 3) {
          _selectedFeelings.add(feeling);
          _feelingsController.clear();
        }
      });
    }
  }

  void _removeFeeling(String feeling) {
    setState(() {
      _selectedFeelings.remove(feeling);
    });
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty) {
      setState(() {
        if (!_selectedTags.contains(tag) && _selectedTags.length < 3) {
          _selectedTags.add(tag);
          _tagsController.clear();
        }
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
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
      itemCount: MoodConstants.availableMoods.length,
      itemBuilder: (context, index) {
        final mood = MoodConstants.availableMoods[index];
        final isSelected = _selectedMood?.toLowerCase() == mood.toLowerCase();

        return GestureDetector(
          onTap: () =>
              {setState(() => _selectedMood = mood), _handleMoodSelection()},
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.getMoodColor(mood).withOpacity(0.1)
                  : CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              border: Border.all(
                color: isSelected
                    ? AppColors.getMoodColor(mood)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MoodConstants.getMoodIcon(mood),
                  size: 32,
                  color: AppColors.getMoodColor(mood),
                ),
                SizedBox(height: Layout.spacing.s),
                Text(
                  mood,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.getMoodColor(mood)
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

  Widget _buildFeelingsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add feelings (max 3)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Layout.spacing.m),
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _feelingsController,
                placeholder: 'Type a feeling...',
                onSubmitted: (_) => _addFeeling(),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.medium),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
              ),
            ),
            SizedBox(width: Layout.spacing.m),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addFeeling,
              child: Icon(
                CupertinoIcons.add_circled_solid,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (_selectedFeelings.isNotEmpty) ...[
          SizedBox(height: Layout.spacing.m),
          Wrap(
            spacing: Layout.spacing.s,
            runSpacing: Layout.spacing.s,
            children: _selectedFeelings.map((feeling) {
              final color = _selectedMood != null
                  ? AppColors.getMoodColor(_selectedMood!)
                  : AppColors.primary;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Layout.spacing.m,
                  vertical: Layout.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.small),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      feeling,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    SizedBox(width: Layout.spacing.xs),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _removeFeeling(feeling),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: color,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        SizedBox(height: Layout.spacing.s),
        Text(
          'Suggestions:',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: Layout.spacing.xs),
        Wrap(
          spacing: Layout.spacing.s,
          runSpacing: Layout.spacing.s,
          children: MoodConstants.availableFeelings.map((feeling) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!_selectedFeelings.contains(feeling) &&
                    _selectedFeelings.length < 3) {
                  setState(() {
                    _selectedFeelings.add(feeling);
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Layout.spacing.m,
                  vertical: Layout.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.small),
                ),
                child: Text(
                  feeling,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add tags (max 3)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Layout.spacing.m),
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _tagsController,
                placeholder: 'Type a tag...',
                onSubmitted: (_) => _addTag(),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.medium),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
              ),
            ),
            SizedBox(width: Layout.spacing.m),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addTag,
              child: Icon(
                CupertinoIcons.add_circled_solid,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (_selectedTags.isNotEmpty) ...[
          SizedBox(height: Layout.spacing.m),
          Wrap(
            spacing: Layout.spacing.s,
            runSpacing: Layout.spacing.s,
            children: _selectedTags.map((tag) {
              final color = _selectedMood != null
                  ? AppColors.getMoodColor(_selectedMood!)
                  : AppColors.primary;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Layout.spacing.m,
                  vertical: Layout.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.small),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$tag',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    SizedBox(width: Layout.spacing.xs),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _removeTag(tag),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: color,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        SizedBox(height: Layout.spacing.s),
        Text(
          'Suggestions:',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: Layout.spacing.xs),
        Wrap(
          spacing: Layout.spacing.s,
          runSpacing: Layout.spacing.s,
          children: MoodConstants.availableTags.map((tag) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!_selectedTags.contains(tag) && _selectedTags.length < 3) {
                  setState(() {
                    _selectedTags.add(tag);
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Layout.spacing.m,
                  vertical: Layout.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.small),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
            Text(
              '1',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: CupertinoSlider(
                value: _intensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: _selectedMood != null
                    ? AppColors.getMoodColor(_selectedMood!)
                    : AppColors.primary,
                onChanged: (value) =>
                    setState(() => _intensity = value.round()),
              ),
            ),
            Text(
              '10',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            _intensity.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _selectedMood != null
                  ? AppColors.getMoodColor(_selectedMood!)
                  : AppColors.primary,
            ),
          ),
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
          _buildFeelingsInput(),
          SizedBox(height: Layout.spacing.xl),
          _buildTagsInput(),
          SizedBox(height: Layout.spacing.xl),
          _buildIntensitySlider(),
          SizedBox(height: Layout.spacing.xl),
          // if (_selectedMood != null)
          //   CupertinoButton(
          //     color: AppColors.primary,
          //     borderRadius: BorderRadius.circular(Layout.borderRadius.large),
          //     onPressed: _handleMoodSelection,
          //     child: Text(
          //       'Confirm Mood',
          //       style: GoogleFonts.poppins(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w500,
          //         color: CupertinoColors.white,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
