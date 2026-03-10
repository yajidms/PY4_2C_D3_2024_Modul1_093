import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final Logbook? log;
  final int? index;
  final LogController controller;
  final Map<String, String> currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  bool _isPublic = false; // Privacy toggle state

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _categoryController = TextEditingController(text: widget.log?.category ?? 'Software');
    _isPublic = widget.log?.isPublic ?? false; // Nilai awal dari log yang ada

    // Listener agar Tab Pratinjau Markdown terupdate otomatis saat kita mengetik
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.log == null) {
      // Tambah Baru: Kirim authorId dan teamId dari currentUser yang sedang login
      widget.controller.addLog(
        title,
        _descController.text,
        _categoryController.text,
        widget.currentUser['uid']!,    // authorId
        widget.currentUser['teamId']!, // teamId
        _isPublic,
      );
    } else {
      // Update data log yang ada
      widget.controller.updateLog(
        widget.index!,
        title,
        _descController.text,
        _categoryController.text,
        _isPublic,
      );
    }
    Navigator.pop(context); // Kembali ke list setelah simpan
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Simpan",
              onPressed: _save,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Mode Editor Teks
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul Catatan"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: "Kategori"),
                  ),
                  const SizedBox(height: 10),
                  // PRIVACY TOGGLE
                  SwitchListTile(
                    title: const Text("Buat Publik"),
                    subtitle: Text(
                      _isPublic
                          ? "Dapat dilihat oleh rekan satu tim."
                          : "Hanya Anda yang dapat melihat catatan ini.",
                    ),
                    value: _isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText:
                            "Tulis laporan dengan Markdown di sini...\nContoh:\n# Judul Besar\n**Teks Tebal**\n- Item List",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab 2: Live Preview Markdown
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Markdown(
                data: _descController.text.isEmpty
                    ? '*Belum ada konten untuk ditampilkan...*'
                    : _descController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

