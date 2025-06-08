import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:mood_tracker_flutter/utils/ollama_service.dart';
import 'package:mood_tracker_flutter/widgets/mood_detector.dart';
import 'package:mood_tracker_flutter/widgets/mood_selector.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  bool _showCamera = false;
  bool _showManualInput = false;
  String? _selectedMood;
  List<String> _selectedFeelings = [];
  List<String> _selectedTags = [];
  int _selectedIntensity = 5;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImage(bytes);
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
              'Failed to pick image from gallery. Please try again.',
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

  Future<void> _processImage(Uint8List imageBytes) async {
    setState(() => _isProcessing = true);
    try {
      final result = await OllamaService.analyzeMoodFromImage(imageBytes);

      setState(() {
        _selectedMood = result['mood'] as String;
        _selectedFeelings = List<String>.from(result['feelings'] as List);
        _selectedTags = List<String>.from(result['tags'] as List? ?? []);
        _selectedIntensity = result['intensity'] as int;
        _showCamera = false;
        _showManualInput = true;
        _isProcessing = false;
      });

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(
              'Mood Detection Result',
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
                onPressed: () => Navigator.pop(context),
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleMoodDetected(String mood, int intensity, Uint8List imageBytes) {
    _processImage(imageBytes);
  }

  void _handleMoodSelected(
      String mood, List<String> feelings, List<String> tags, int intensity) {
    setState(() {
      _selectedMood = mood;
      _selectedFeelings = feelings;
      _selectedTags = tags;
      _selectedIntensity = intensity;
    });
  }

  void _saveMoodEntry() {
    if (_selectedMood == null) return;

    final entry = MoodEntry(
      content: _noteController.text,
      timestamp: DateTime.now(),
      mood: _selectedMood!,
      feelings: _selectedFeelings,
      tags: _selectedTags,
      intensity: _selectedIntensity,
    );

    Navigator.pop(context, entry);
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
          Text(
            'Mood Check-in',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'How are you feeling today?',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInOptions() {
    return Padding(
      padding: EdgeInsets.all(Layout.spacing.l),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: Layout.spacing.l,
                    vertical: Layout.spacing.m,
                  ),
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.large),
                  onPressed: () {
                    setState(() {
                      _showCamera = true;
                      _showManualInput = false;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.camera,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: Layout.spacing.s),
                      Text(
                        'Camera',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Layout.spacing.m),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: Layout.spacing.l,
                    vertical: Layout.spacing.m,
                  ),
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.large),
                  onPressed: _handleImageFromGallery,
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: Layout.spacing.s),
                      Text(
                        'Gallery',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Layout.spacing.m),
          Container(
            width: double.infinity,
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(
                horizontal: Layout.spacing.l,
                vertical: Layout.spacing.m,
              ),
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              onPressed: () {
                setState(() {
                  _showManualInput = true;
                  _showCamera = false;
                });
              },
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.smiley,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: Layout.spacing.s),
                  Text(
                    'Manual Input',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.primary,
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

  Widget _buildManualInput() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Layout.spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoodSelector(
            onMoodSelected: _handleMoodSelected,
            initialMood: _selectedMood,
            initialFeelings: _selectedFeelings,
            initialTags: _selectedTags,
            initialIntensity: _selectedIntensity,
          ),
          SizedBox(height: Layout.spacing.xl),
          Text(
            'Add a note',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Layout.spacing.m),
          CupertinoTextField(
            controller: _noteController,
            placeholder: 'How are you feeling? What\'s on your mind?',
            padding: EdgeInsets.all(Layout.spacing.m),
            maxLines: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(Layout.borderRadius.medium),
              border: Border.all(color: CupertinoColors.systemGrey4),
            ),
          ),
          SizedBox(height: Layout.spacing.xl),
          CupertinoButton(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Layout.borderRadius.large),
            onPressed: _selectedMood != null ? _saveMoodEntry : null,
            child: Text(
              'Save Entry',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.white,
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
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
        middle: Text(
          'New Check-in',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: _showCamera || _showManualInput
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showCamera = false;
                    _showManualInput = false;
                    _selectedMood = null;
                  });
                },
              )
            : null,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_showCamera && !_showManualInput) ...[
                  _buildHeader(),
                  _buildCheckInOptions(),
                ] else if (_showCamera) ...[
                  Expanded(
                    child: MoodDetector(onMoodDetected: _handleMoodDetected),
                  ),
                ] else if (_showManualInput) ...[
                  Expanded(child: _buildManualInput()),
                ],
              ],
            ),
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: CupertinoColors.black.withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      ),
                      SizedBox(height: Layout.spacing.m),
                      Text(
                        'Analyzing mood...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
