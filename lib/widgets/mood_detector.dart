import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:mood_tracker_flutter/models/mood.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

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
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
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

  MoodType _analyzeMood(Face face) {
    // Get various face features
    final double smileProb = face.smilingProbability ?? 0.0;
    final double leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    final double rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;
    final double rotY = face.headEulerAngleY ?? 0.0; // Head rotation left-right
    final double rotX = face.headEulerAngleX ?? 0.0; // Head tilt up-down

    // Check if eyes are closed (might indicate sadness or tiredness)
    bool eyesClosed = leftEyeOpen < 0.3 && rightEyeOpen < 0.3;

    // Check head position (down might indicate sadness)
    bool headDown = rotX < -10;

    // Analyze the combination of features
    if (smileProb > 0.8 && !eyesClosed) {
      return MoodType.happy;
    } else if (smileProb < 0.2 && (eyesClosed || headDown)) {
      return MoodType.sad;
    } else {
      return MoodType.neutral;
    }
  }

  int _getMoodIntensity(Face face) {
    final double smileProb = face.smilingProbability ?? 0.0;
    final double leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    final double rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

    // Calculate average of facial features for intensity
    double intensity = (smileProb + leftEyeOpen + rightEyeOpen) / 3;
    return (intensity * 10).round();
  }

  Future<void> _detectMood() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Capture the image
      final image = await _controller!.takePicture();

      // Convert the image to InputImage for ML Kit
      final inputImage = InputImage.fromFilePath(image.path);

      // Process the image with ML Kit
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected. Please try again.')),
        );
        return;
      }

      // Get the first detected face
      final face = faces.first;

      // Analyze mood based on multiple facial features
      final mood = _analyzeMood(face);
      final intensity = _getMoodIntensity(face);

      // Call the callback with detected mood
      widget.onMoodDetected(mood, intensity);

      // Debug information
      debugPrint('Face Analysis:');
      debugPrint('Smile Probability: ${face.smilingProbability}');
      debugPrint('Left Eye Open: ${face.leftEyeOpenProbability}');
      debugPrint('Right Eye Open: ${face.rightEyeOpenProbability}');
      debugPrint('Head Rotation Y: ${face.headEulerAngleY}');
      debugPrint('Head Rotation X: ${face.headEulerAngleX}');
      debugPrint('Head Rotation Z: ${face.headEulerAngleZ}');
    } catch (e) {
      debugPrint('Error detecting mood: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error detecting mood. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
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
