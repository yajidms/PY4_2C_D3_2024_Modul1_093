import 'package:flutter/material.dart';
import '../onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'widgets/log_item_widget.dart';

const Color _kBgColor = Color(0xFFF7F5DE);
const Color _kAccentBlue = Color(0xFF3D8BE8);
const Color _kAppBarText = Color(0xFF2D3E50);

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  //bagian untuk menampilkan dialog tambah/edit log
  void _showLogDialog(BuildContext context, {int? index, LogModel? log}) {
    _titleController.text = log?.title ?? '';
    _contentController.text = log?.description ?? '';

    final categoryNotifier = ValueNotifier<String>(log?.category ?? 'Pribadi');
    final categories = ['Pribadi', 'Pekerjaan', 'Kuliah', 'Urgent'];

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(log == null ? "Catatan Baru" : "Edit Catatan", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: inputDecoration.copyWith(hintText: "Judul (misal: Oguri Cap)"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: inputDecoration.copyWith(hintText: "Detail deskripsi..."),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Dropdown Reaktif
            ValueListenableBuilder<String>(
              valueListenable: categoryNotifier,
              builder: (context, value, child) {
                return DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => categoryNotifier.value = val!,
                );
              },
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if(_titleController.text.isNotEmpty) {
                if (log == null) {
                  _controller.addLog(_titleController.text, _contentController.text, categoryNotifier.value);
                } else {
                  _controller.updateLog(index!, _titleController.text, _contentController.text, categoryNotifier.value);
                }
                _titleController.clear(); _contentController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(log == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.05),
        elevation: 0.5,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${widget.username}",
              style: const TextStyle(color: _kAccentBlue, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Text(
              "Logbook Harian",
              style: TextStyle(color: _kAppBarText, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: _kAccentBlue),
            onPressed: () => _showLogoutConfirmDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          //search bar dengan padding
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => _controller.searchLog(val),
              decoration: InputDecoration(
                hintText: "Cari catatan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, child) {
          if (currentLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Belum ada catatan.", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          //ListView dengan padding vertikal
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12), // Padding atas bawah list
            itemCount: currentLogs.length,
            itemBuilder: (context, index) {
              final log = currentLogs[index];
              return LogItemWidget(
                log: log,
                onEditPressed: () => _showLogDialog(context, index: index, log: log),
                onDeletePressed: () {
                  final deletedTitle = log.title;
                  _controller.removeLog(index);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Catatan "$deletedTitle" telah dihapus',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogDialog(context),
        backgroundColor: _kAccentBlue, // Tombol tambah warna biru
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Catatan Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingView()),
                      (route) => false,
                );
              },
              child: const Text("Ya, Keluar", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}