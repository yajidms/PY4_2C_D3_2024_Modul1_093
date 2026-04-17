import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'filter_controller.dart';

class FilterView extends StatefulWidget {
  final String imagePath;
  const FilterView({super.key, required this.imagePath});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  final FilterController _controller = FilterController();
  FilterType _selectedFilter = FilterType.none;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  
  double _filterIntensity = 0.5;
  Timer? _debounceTimer;

  final List<FilterType> _filters = FilterType.values;

  String _getFilterName(FilterType type) {
    String name = type.name;
    if (name == 'none') return 'ORIGINAL';
    return name.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().toUpperCase();
  }

  void _applyFilter(FilterType type, {double intensity = 0.5}) async {
    setState(() {
      _selectedFilter = type;
      _isProcessing = true;
    });

    final bytes = await _controller.applyFilter(widget.imagePath, type, intensity);

    if (mounted) {
      setState(() {
        _processedImage = bytes.isEmpty ? null : bytes;
        _isProcessing = false;
      });
      if (bytes.isEmpty && type != FilterType.none) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menerapkan filter.')));
      }
    }
  }

  void _onIntensityChanged(double value) {
    setState(() {
      _filterIntensity = value;
    });
    
    if (_debounceTimer != null) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isProcessing) {
        _applyFilter(_selectedFilter, intensity: _filterIntensity);
      }
    });
  }

  bool _supportsSlider(FilterType type) {
    return [
      FilterType.contrastBrightness,
      FilterType.gaussianBlur,
      FilterType.unsharpMask,
      FilterType.binaryThreshold,
      FilterType.medianFilter,
      FilterType.gammaCorrection,
    ].contains(type);
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) {
      if (_selectedFilter == FilterType.none) {
        _processedImage = File(widget.imagePath).readAsBytesSync();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terapkan filter terlebih dahulu.')));
        return;
      }
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg').create();
      await file.writeAsBytes(_processedImage!);

      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gambar berhasil disimpan ke galeri.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                // TOP ACTION BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      GestureDetector(
                        onTap: () => _saveImage(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // IMAGE PREVIEW AREA
                Expanded(
                  child: Center(
                    child: _processedImage != null
                        ? Image.memory(_processedImage!, fit: BoxFit.contain)
                        : Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ),
                ),
                // BOTTOM EDITOR AREA
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_supportsSlider(_selectedFilter))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.yellow,
                              inactiveTrackColor: Colors.white54,
                              thumbColor: Colors.white,
                              trackHeight: 2.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            ),
                            child: Slider(
                              value: _filterIntensity,
                              min: 0.0,
                              max: 1.0,
                              onChanged: _onIntensityChanged,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 48),

                      // Carousel
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final bool isActive = _selectedFilter == filter;
                            return GestureDetector(
                              onTap: () {
                                if (!_isProcessing && _selectedFilter != filter) {
                                  _filterIntensity = 0.5;
                                  _applyFilter(filter, intensity: _filterIntensity);
                                }
                              },
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade900,
                                        border: isActive
                                            ? Border.all(color: Colors.yellow, width: 2)
                                            : null,
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        color: isActive ? Colors.yellow : Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _getFilterName(filter),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isActive ? Colors.yellow : Colors.white54,
                                        fontSize: 10,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
