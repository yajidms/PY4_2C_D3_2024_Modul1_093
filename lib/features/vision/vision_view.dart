import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'vision_controller.dart';
import 'damage_painter.dart';
import 'filter_view.dart';

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

        // TOP BAR OVERLAY: Pengaturan Flash
        Positioned(
          top: 50,
          left: 16,
          child: IconButton(
            icon: Icon(
              _visionController.isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white70,
              size: 28,
            ),
            onPressed: _visionController.toggleFlash,
          ),
        ),

        // BOTTOM CONTROL AREA: Gradient & Shutter Row
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kiri: Ikon Galeri (Placeholder)
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 32),
                  onPressed: () {},
                ),

                // Tengah: Shutter Button Khas Samsung One UI
                GestureDetector(
                  onTap: () async {
                    final file = await _visionController.takePicture();
                    if (file != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterView(imagePath: file.path),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Kanan: Ikon Switch Camera (Placeholder)
                IconButton(
                  icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam pekat
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
    );
  }
}