import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/widgets/mood_selector.dart';
import 'package:mood_tracker_flutter/providers/firebase_provider.dart';
import 'package:provider/provider.dart';

class ManualMoodInputScreen extends StatefulWidget {
  final String? initialMood;
  final int initialIntensity;

  const ManualMoodInputScreen({
    super.key,
    this.initialMood,
    required this.initialIntensity,
  });

  @override
  State<ManualMoodInputScreen> createState() => _ManualMoodInputScreenState();
}

class _ManualMoodInputScreenState extends State<ManualMoodInputScreen> {
  String? _selectedMood;
  List<String> _selectedFeelings = [];
  List<String> _selectedTags = [];
  int _selectedIntensity = 5;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
    _selectedIntensity = widget.initialIntensity;
  }

  void _saveMoodEntry() async {
    if (_selectedMood == null) return;

    final entry = MoodEntry(
      content: _noteController.text,
      timestamp: DateTime.now(),
      mood: _selectedMood!,
      feelings: _selectedFeelings,
      tags: _selectedTags,
      intensity: _selectedIntensity,
    );

    try {
      await context.read<FirebaseProvider>().createMoodEntry(entry);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Failed to save mood entry. Please try again.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Manual Input',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Layout.spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MoodSelector(
                onMoodSelected: (mood, feelings, tags, intensity) {
                  setState(() {
                    _selectedMood = mood;
                    _selectedFeelings = feelings;
                    _selectedTags = tags;
                    _selectedIntensity = intensity;
                  });
                },
                initialMood: widget.initialMood,
                initialFeelings: _selectedFeelings,
                initialTags: _selectedTags,
                initialIntensity: _selectedIntensity,
              ),
              SizedBox(height: Layout.spacing.xl),
              Text('Add a note',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: Layout.spacing.m),
              CupertinoTextField(
                controller: _noteController,
                placeholder: 'How are you feeling? What\'s on your mind?',
                padding: EdgeInsets.all(Layout.spacing.m),
                maxLines: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.medium),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
              ),
              SizedBox(height: Layout.spacing.xl),
              CupertinoButton(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(Layout.borderRadius.large),
                onPressed: _selectedMood != null ? _saveMoodEntry : null,
                child: Text('Save Entry',
                    style: GoogleFonts.poppins(color: CupertinoColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
