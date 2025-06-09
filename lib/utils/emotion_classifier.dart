import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class EmotionClassifier {
  Interpreter? interpreter;
  bool isInitialized = false;

  EmotionClassifier() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions();

      // Try to use GPU delegate if available
      try {
        options.addDelegate(GpuDelegate());
        print('GPU delegate enabled');
      } catch (e) {
        print('GPU delegate not available: $e');
      }

      interpreter = await Interpreter.fromAsset(
        'assets/models/custom_cnn_model.tflite',
        options: options,
      );
      isInitialized = true;
    } catch (e) {
      print('Error loading model: $e');
      // If GPU delegation fails, try without it
      try {
        interpreter = await Interpreter.fromAsset(
            'assets/models/custom_cnn_model.tflite');
        isInitialized = true;
      } catch (e) {
        print('Error loading model without GPU: $e');
        rethrow;
      }
    }
  }

  Future<(String, double)> classify(File imageFile) async {
    // Wait for model to be loaded
    if (!isInitialized) {
      await _loadModel();
    }

    if (interpreter == null) {
      throw Exception('TFLite interpreter not initialized');
    }

    // 1. Load image
    final rawBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(rawBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // 2. Convert to grayscale, resize to 48x48
    image = img.grayscale(image);
    image = img.copyResize(image, width: 48, height: 48);

    // 3. Normalize to float32 and reshape to (1, 48, 48, 1)
    var input = Float32List(48 * 48);
    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        final pixel = image.getPixel(x, y);
        input[y * 48 + x] = img.getLuminance(pixel).toDouble() / 255.0;
      }
    }

    var inputBuffer = input.buffer.asFloat32List();
    var inputArray = [
      inputBuffer.reshape([1, 48, 48, 1])
    ];

    // 4. Prepare output buffer
    var output = List.filled(7, 0.0).reshape([1, 7]);

    // 5. Run inference
    interpreter!.run(inputArray[0], output);

    // 6. Get result
    List<double> outputList = List<double>.from(output[0]);
    double maxValue = outputList.reduce(max);
    int predictedIndex = outputList.indexOf(maxValue);
    double confidence = maxValue;

    List<String> classNames = [
      "Angry",
      "Disgust",
      "Fear",
      "Happy",
      "Sad",
      "Surprise",
      "Neutral"
    ];

    if (predictedIndex < 0 || predictedIndex >= classNames.length) {
      throw Exception("Invalid predicted index: $predictedIndex");
    }
    return (classNames[predictedIndex], confidence);
  }

  String mapClassNameToMood(String className) {
    switch (className) {
      case "Happy":
        return "Happy";
      case "Sad":
        return "Sad";
      case "Angry":
        return "Angry";
      case "Neutral":
        return "Neutral";
      case "Disgust":
        return "Angry";
      case "Fear":
        return "Anxious";
      case "Surprise":
        return "Excited";
      default:
        return "Neutral";
    }
  }
}
