import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../main.dart'; // import list cameras global
import 'models/detection_result.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;
  
  // State untuk Mock Detector
  DetectionResult? currentDetection;
  Timer? _mockTimer;
  final Random _random = Random();

  bool isFlashOn = false;
  bool isOverlayVisible = true;

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;

      // Mulai simulasi deteksi AI setelah kamera siap
      _startMockDetection();
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }
    notifyListeners();
  }

  void _startMockDetection() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isInitialized) return;

      double w = 0.2 + _random.nextDouble() * 0.3; // Lebar 20%-50%
      double h = 0.2 + _random.nextDouble() * 0.3; // Tinggi 20%-50%
      double x = _random.nextDouble() * (1.0 - w);
      double y = _random.nextDouble() * (1.0 - h);
      
      int confidence = 70 + _random.nextInt(25); // Score 70% - 94%

      // Randomize tipe kerusakan untuk Homework Warna Dinamis
      bool isPothole = _random.nextBool();
      String label = isPothole ? "[D40] POTHOLE" : "[D00] LONGITUDINAL CRACK";

      currentDetection = DetectionResult(
        box: Rect.fromLTWH(x, y, w, h),
        label: "$label - $confidence%",
        score: confidence / 100.0,
      );
      
      // Memicu UI untuk menggambar ulang di lokasi baru
      notifyListeners(); 
    });
  }

  Future<void> toggleFlash() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      isFlashOn = !isFlashOn;
      await controller!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal mengubah status flash: $e");
    }
  }

  void toggleOverlay() {
    isOverlayVisible = !isOverlayVisible;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // RESOURCE GUARD: Matikan timer dan buang kamera dari memori
      _mockTimer?.cancel();
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}