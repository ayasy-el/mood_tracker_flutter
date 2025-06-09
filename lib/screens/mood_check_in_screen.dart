import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/screens/manual_input_screen.dart';
import 'package:mood_tracker_flutter/utils/emotion_classifier.dart';
import 'package:mood_tracker_flutter/widgets/mood_detector.dart';
import 'package:path_provider/path_provider.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _showCamera = false;
  bool _isProcessing = false;

  Future<void> _handleImageFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isProcessing = true);

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        final bytes = await image.readAsBytes();
        await tempFile.writeAsBytes(bytes);

        final emotionClassifier = EmotionClassifier();
        final (className, confidence) =
            await emotionClassifier.classify(tempFile);

        final mood = emotionClassifier.mapClassNameToMood(className);
        final intensity = (confidence * 10).round().clamp(1, 10);
        await tempFile.delete();

        _navigateToManualInput(mood, intensity);
      }
    } catch (_) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: Text(
                'Failed to pick image from gallery. Please try again.',
                style: GoogleFonts.poppins()),
            actions: [
              CupertinoDialogAction(
                child: Text('OK', style: GoogleFonts.poppins()),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _navigateToManualInput(String? mood, int? intensity) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ManualMoodInputScreen(
          initialMood: mood,
          initialIntensity: intensity ?? 5,
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Layout.spacing.l, vertical: Layout.spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Check-in',
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Text('How are you feeling today?',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _buildOptions() => Padding(
        padding: EdgeInsets.all(Layout.spacing.l),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.all(Layout.spacing.m),
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(Layout.borderRadius.large),
                    onPressed: () => setState(() => _showCamera = true),
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.camera,
                            size: 32, color: AppColors.primary),
                        SizedBox(height: Layout.spacing.s),
                        Text('Camera',
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: Layout.spacing.m),
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.all(Layout.spacing.m),
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(Layout.borderRadius.large),
                    onPressed: _handleImageFromGallery,
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.photo,
                            size: 32, color: AppColors.primary),
                        SizedBox(height: Layout.spacing.s),
                        Text('Gallery',
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Layout.spacing.m),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: EdgeInsets.all(Layout.spacing.m),
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Layout.borderRadius.large),
                onPressed: () => _navigateToManualInput(null, null),
                child: Column(
                  children: [
                    Icon(CupertinoIcons.smiley,
                        size: 32, color: AppColors.primary),
                    SizedBox(height: Layout.spacing.s),
                    Text('Manual Input',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text('New Check-in',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        previousPageTitle: _showCamera ? 'Back' : null,
        leading: _showCamera
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Back',
                    style: GoogleFonts.poppins(color: AppColors.primary)),
                onPressed: () => setState(() => _showCamera = false),
              )
            : null,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            if (_showCamera)
              MoodDetector(
                  onMoodDetected: (mood, intensity, _) =>
                      _navigateToManualInput(mood, intensity))
            else
              Column(children: [_buildHeader(), _buildOptions()]),
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: CupertinoColors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CupertinoActivityIndicator(
                            color: CupertinoColors.white),
                        SizedBox(height: Layout.spacing.m),
                        Text('Analyzing mood...',
                            style: GoogleFonts.poppins(
                                color: CupertinoColors.white)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
