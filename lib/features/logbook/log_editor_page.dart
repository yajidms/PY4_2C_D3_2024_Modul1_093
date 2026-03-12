import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final Logbook? log;
  final int? index;
  final LogController controller;
  final Map<String, String> currentUser;
  final bool isReadOnly;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
    this.isReadOnly = false,
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
    final isReadOnly = widget.isReadOnly;

    return DefaultTabController(
      length: isReadOnly ? 1 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isReadOnly
                ? "Lihat Catatan"
                : (widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          ),
          bottom: TabBar(
            tabs: [
              if (!isReadOnly) const Tab(text: "Editor"),
              const Tab(text: "Pratinjau"),
            ],
          ),
          actions: [
            if (!isReadOnly)
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: "Simpan",
                onPressed: _save,
              ),
          ],
        ),
        body: TabBarView(
          children: [
            if (!isReadOnly)
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
            // Tab Pratinjau (read-only mode: tampilkan info catatan + markdown)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isReadOnly && widget.log != null) ...[
                    Text(
                      widget.log!.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          widget.log!.isPublic ? Icons.public : Icons.lock,
                          size: 14,
                          color: widget.log!.isPublic ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.log!.isPublic ? "Publik" : "Privat",
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.log!.isPublic ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.folder_outlined, size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(
                          widget.log!.category,
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                  ],
                  MarkdownBody(
                    data: _descController.text.isEmpty
                        ? '*Belum ada konten untuk ditampilkan...*'
                        : _descController.text,
                    selectable: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

