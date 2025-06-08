import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mood_tracker_flutter/constants/colors.dart';
import 'package:mood_tracker_flutter/constants/layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_flutter/utils/ollama_service.dart';

class MoodDetector extends StatefulWidget {
  final Function(String mood, int intensity, Uint8List imageBytes)
      onMoodDetected;

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
      final bytes = await image.readAsBytes();

      final result = await OllamaService.analyzeMoodFromImage(bytes);

      widget.onMoodDetected(
        result['mood'] as String,
        result['intensity'] as int,
        bytes,
      );

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
                // Text(
                //   result['explanation'] as String,
                //   style: GoogleFonts.poppins(),
                // ),
                SizedBox(height: Layout.spacing.m),
                Text(
                  'Detected feelings: ${(result['feelings'] as List).join(", ")}',
                  style: GoogleFonts.poppins(),
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
      debugPrint('Error detecting mood: $e');
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
              'Failed to detect mood. Please try again or enter manually.',
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
      return const Center(child: CupertinoActivityIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.all(Layout.spacing.l),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.large),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(Layout.borderRadius.large),
                  child: CameraPreview(_controller!),
                ),
              ),
              if (_isProcessing)
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.all(Layout.spacing.l),
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withOpacity(0.5),
                      borderRadius:
                          BorderRadius.circular(Layout.borderRadius.large),
                    ),
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
              CupertinoButton(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(Layout.borderRadius.large),
                onPressed: _isProcessing ? null : _detectMood,
                child: _isProcessing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          ),
                          SizedBox(width: Layout.spacing.s),
                          Text(
                            'Processing...',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Detect Mood',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.white,
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
