import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/utils/emotion_classifier.dart';

MoodType mapClassNameToMood(String className) {
  switch (className.toLowerCase()) {
    case 'angry':
      return MoodType.angry;
    case 'disgust':
      return MoodType.angry; // Disgust digabung dengan angry
    case 'fear':
      return MoodType.anxious; // Fear digabung dengan anxious
    case 'happy':
      return MoodType.happy;
    case 'sad':
      return MoodType.sad;
    case 'surprise':
      return MoodType.excited; // Surprise digabung dengan excited
    case 'neutral':
      return MoodType.neutral;
    default:
      return MoodType.neutral; // Fallback jika tidak cocok
  }
}

class MoodDetector extends StatefulWidget {
  final Function(MoodType mood, int intensity) onMoodDetected;

  const MoodDetector({
    super.key,
    required this.onMoodDetected,
  });

  @override
  State<MoodDetector> createState() => _MoodDetectorState();
}

class _MoodDetectorState extends State<MoodDetector> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use the front camera
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _detectMood() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final file = File(image.path);

      EmotionClassifier emotionClassifier = EmotionClassifier();
      final (className, confidence) = await emotionClassifier.classify(file);

      final mood = mapClassNameToMood(className);
      final intensity = (confidence * 10).round().clamp(1, 10);

      widget.onMoodDetected(mood, intensity);
    } catch (e) {
      debugPrint('Error detecting mood: $e');
      // You might want to show an error message to the user here
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(Layout.spacing.l),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Layout.borderRadius.large),
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(Layout.spacing.l),
          child: Column(
            children: [
              Text(
                'Position your face in the frame',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: Layout.spacing.l),
              ElevatedButton(
                onPressed: _isProcessing ? null : _detectMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Layout.spacing.xl,
                    vertical: Layout.spacing.m,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Layout.borderRadius.medium),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Detect Mood',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
