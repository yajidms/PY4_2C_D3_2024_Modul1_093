import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'vision_controller.dart';
import 'damage_painter.dart';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _visionController;

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  Widget _buildVisionStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // LAYER 1: Hardware Preview (Kamera Background)
        Center(
          child: AspectRatio(
            aspectRatio: 1 / _visionController.controller!.value.aspectRatio,
            child: CameraPreview(_visionController.controller!),
          ),
        ),
        // LAYER 2: Digital Overlay (Hanya tampil jika diaktifkan)
        if (_visionController.isOverlayVisible)
          Positioned.fill(
            child: CustomPaint(
              painter: DamagePainter(_visionController.currentDetection),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Agar kamera penuh sampai atas
      appBar: AppBar(
        title: const Text("Smart-Patrol Vision", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black45,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          // ERROR STATE: No Camera Access
          if (_visionController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(_visionController.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => openAppSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text("Buka Pengaturan Izin"),
                  )
                ],
              ),
            );
          }
          // LOADING STATE: Informative Feedback
          if (!_visionController.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Menghubungkan ke Sensor Visual...",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)
                  ),
                ],
              ),
            );
          }
          // SUCCESS STATE: Camera Stack
          return _buildVisionStack();
        },
      ),
      // FLOATING ACTIONS: Hardware & Layer Controls
      floatingActionButton: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          if (!_visionController.isInitialized) return const SizedBox.shrink();
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "btn_flash",
                backgroundColor: _visionController.isFlashOn ? Colors.yellow : Colors.white,
                onPressed: _visionController.toggleFlash,
                child: Icon(
                  _visionController.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "btn_overlay",
                backgroundColor: _visionController.isOverlayVisible ? Colors.blueAccent : Colors.grey,
                onPressed: _visionController.toggleOverlay,
                child: Icon(
                  _visionController.isOverlayVisible ? Icons.layers : Icons.layers_clear,
                  color: Colors.white,
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}