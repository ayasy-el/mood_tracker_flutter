import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/constants/moods.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/utils/ollama_service.dart';
import 'package:mood_tracker_flutter/utils/string_extensions.dart';
import 'package:mood_tracker_flutter/providers/firebase_provider.dart';
import 'package:provider/provider.dart';

class JournalEntryScreen extends StatefulWidget {
  final MoodEntry? existingEntry;

  const JournalEntryScreen({super.key, this.existingEntry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late TextEditingController _contentController;
  late TextEditingController _feelingsController;
  late TextEditingController _tagsController;
  String _selectedMood = MoodConstants.availableMoods.first;
  List<String> _selectedFeelings = [];
  List<String> _selectedTags = [];
  int _intensity = 5;
  bool _isEditing = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingEntry != null;
    if (_isEditing) {
      _contentController =
          TextEditingController(text: widget.existingEntry!.content);
      _feelingsController = TextEditingController();
      _tagsController = TextEditingController();
      _selectedMood = widget.existingEntry!.mood;
      _selectedFeelings = List.from(widget.existingEntry!.feelings);
      _selectedTags = List.from(widget.existingEntry!.tags);
      _intensity = widget.existingEntry!.intensity;
    } else {
      _contentController = TextEditingController();
      _feelingsController = TextEditingController();
      _tagsController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _feelingsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    if (_contentController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            'Empty Entry',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Please write something about your day.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: GoogleFonts.poppins(),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final entry = MoodEntry(
        id: widget.existingEntry?.id,
        content: _contentController.text,
        timestamp: widget.existingEntry?.timestamp ?? DateTime.now(),
        mood: _selectedMood,
        feelings: _selectedFeelings,
        intensity: _intensity,
        tags: _selectedTags,
      );

      if (_isEditing) {
        await context
            .read<FirebaseProvider>()
            .updateMoodEntry(entry.id!, entry);
      } else {
        await context.read<FirebaseProvider>().createMoodEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Failed to save entry. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _deleteEntry() {
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
          'Are you sure you want to delete this entry?',
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
                    .deleteMoodEntry(widget.existingEntry!.id!);
                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: Text(
                        'Error',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Text(
                        'Failed to delete entry. Please try again.',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: Text(
                            'OK',
                            style: GoogleFonts.poppins(),
                          ),
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
    final tag = _tagsController.text.trim().toLowerCase();
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

  Widget _buildMoodSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
      padding: EdgeInsets.all(Layout.spacing.l),
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Layout.borderRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          Wrap(
            spacing: Layout.spacing.s,
            runSpacing: Layout.spacing.s,
            children: MoodConstants.availableMoods.map((mood) {
              final isSelected = _selectedMood == mood;
              final color = AppColors.getMoodColor(mood);
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() => _selectedMood = mood);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Layout.spacing.m,
                    vertical: Layout.spacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(Layout.borderRadius.small),
                  ),
                  child: Text(
                    mood,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isSelected ? CupertinoColors.white : color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingsInput() {
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
            'Add feelings (max 3)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                final color = AppColors.getMoodColor(_selectedMood);
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
            children:
                MoodConstants.getMoodFeelings(_selectedMood).map((feeling) {
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
      ),
    );
  }

  Widget _buildTagInput() {
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
            'Add tags (max 3)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                final color = AppColors.getMoodColor(_selectedMood);
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
                  if (!_selectedTags.contains(tag) &&
                      _selectedTags.length < 3) {
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
      ),
    );
  }

  Widget _buildIntensitySlider() {
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
            'Intensity',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                  activeColor: AppColors.getMoodColor(_selectedMood),
                  onChanged: (value) {
                    setState(() => _intensity = value.round());
                  },
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
                color: AppColors.getMoodColor(_selectedMood),
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
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          _isEditing ? 'Edit Entry' : 'New Entry',
          style: GoogleFonts.poppins(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
              color: AppColors.primary,
            ),
          ),
          onPressed: _saveEntry,
        ),
        leading: _isEditing
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.destructiveRed,
                ),
                onPressed: _deleteEntry,
              )
            : null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Layout.spacing.l),
              Container(
                margin: EdgeInsets.symmetric(horizontal: Layout.spacing.l),
                padding: EdgeInsets.all(Layout.spacing.l),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.large),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      controller: _contentController,
                      placeholder: 'Write about your day...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      placeholderStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 5,
                      decoration: null,
                    ),
                    SizedBox(height: Layout.spacing.m),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (_contentController.text.isEmpty) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Text(
                                      'Empty Entry',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    content: Text(
                                      'Please write something about your day first.',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text(
                                          'OK',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              setState(() => _isProcessing = true);
                              try {
                                final result =
                                    await OllamaService.analyzeMoodFromText(
                                  _contentController.text,
                                );

                                setState(() {
                                  _selectedMood = result['mood'] as String;
                                  _selectedFeelings = List<String>.from(
                                      result['feelings'] as List);
                                  _intensity = result['intensity'] as int;
                                  _selectedTags =
                                      List<String>.from(result['tags'] as List);
                                  _isProcessing = false;
                                });

                                if (mounted) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text(
                                        'Auto-Detection Result',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Column(
                                        children: [
                                          Text(
                                            result['explanation'] as String,
                                            style: GoogleFonts.poppins(),
                                          ),
                                          SizedBox(height: Layout.spacing.m),
                                          Text(
                                            'You can still adjust the detected values manually.',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text(
                                            'OK',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => _isProcessing = false);
                                if (mounted) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text(
                                        'Error',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        'Failed to analyze mood. Please try again or enter manually.',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text(
                                            'OK',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isProcessing)
                            CupertinoActivityIndicator(
                              color: AppColors.primary,
                            )
                          else
                            Icon(
                              CupertinoIcons.wand_stars,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          SizedBox(width: Layout.spacing.xs),
                          Text(
                            _isProcessing ? 'Analyzing...' : 'Auto-detect mood',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Layout.spacing.l),
              _buildMoodSelector(),
              SizedBox(height: Layout.spacing.l),
              _buildFeelingsInput(),
              SizedBox(height: Layout.spacing.l),
              _buildTagInput(),
              SizedBox(height: Layout.spacing.l),
              _buildIntensitySlider(),
              SizedBox(height: Layout.spacing.l),
            ],
          ),
        ),
      ),
    );
  }
}
