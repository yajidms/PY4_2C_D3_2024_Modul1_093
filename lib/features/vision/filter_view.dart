import 'dart:io';
import 'dart:typed_data';
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

  final List<FilterType> _filters = FilterType.values;

  String _getFilterName(FilterType type) {
    String name = type.name;
    if (name == 'none') return 'ORIGINAL';
    return name.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().toUpperCase();
  }

  void _applyFilter(FilterType type) async {
    setState(() {
      _selectedFilter = type;
      _isProcessing = true;
    });

    final bytes = await _controller.applyFilter(widget.imagePath, type);

    if (mounted) {
      setState(() {
        _processedImage = bytes.isEmpty ? null : bytes;
        _isProcessing = false;
      });
      if (bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menerapkan filter.')));
      }
    }
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terapkan filter terlebih dahulu.')));
      return;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCV Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _processedImage != null
              ? Image.memory(_processedImage!, fit: BoxFit.contain)
              : Image.file(File(widget.imagePath), fit: BoxFit.contain),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 16, bottom: 16),
                child: ChoiceChip(
                  label: Text(_getFilterName(filter)),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    if (selected && !_isProcessing) {
                      _applyFilter(filter);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

