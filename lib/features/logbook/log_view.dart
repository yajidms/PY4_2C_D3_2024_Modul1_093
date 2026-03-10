import 'package:flutter/material.dart';
import '../onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'widgets/log_item_widget.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

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
  late LogController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      //koneksi ke MongoDB Atlas (Cloud)
      await LogHelper.writeLog(
        "UI: Menghubungi MongoService.connect()...",
        source: "log_view.dart",
      );

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
      );

      // Mengambil data log dari Cloud
      await LogHelper.writeLog(
        "UI: Memanggil controller.loadFromDisk()...",
        source: "log_view.dart",
      );

      await _controller.loadFromDisk();

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat ke Notifier.",
        source: "log_view.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "UI: Error - $e",
        source: "log_view.dart",
        level: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Offline Mode Warning: Gagal terhubung ke Cloud. Menampilkan data lokal.",
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // Apapun yang terjadi (Sukses/Gagal/Data Kosong), loading harus mati
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi untuk Pull-to-Refresh dengan Connection Guard
  Future<void> _refreshData() async {
    try {
      await _controller.fetchLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil diperbarui dari Cloud."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Offline Mode Warning: Koneksi terputus, menampilkan data lokal.",
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  //bagian untuk menampilkan dialog tambah/edit log
  void _showLogDialog(BuildContext context, {int? index, Logbook? log}) {
    _titleController.text = log?.title ?? '';
    _contentController.text = log?.description ?? '';

    final categoryNotifier = ValueNotifier<String>(log?.category ?? 'Pribadi');
    const categories = ['Pribadi', 'Pekerjaan', 'Kuliah', 'Urgent'];

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          log == null ? "Catatan Baru" : "Edit Catatan",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: inputDecoration.copyWith(
                hintText: "Judul (misal: Oguri Cap)",
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: inputDecoration.copyWith(
                hintText: "Detail deskripsi...",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: categoryNotifier,
              builder: (context, value, child) {
                return DropdownButtonFormField<String>(
                  initialValue: value,
                  decoration: inputDecoration,
                  isExpanded: true,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      categoryNotifier.value = val;
                    }
                  },
                );
              },
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                if (log == null) {
                  _controller.addLog(
                    _titleController.text,
                    _contentController.text,
                    categoryNotifier.value,
                  );
                } else {
                  _controller.updateLog(
                    index!,
                    _titleController.text,
                    _contentController.text,
                    categoryNotifier.value,
                  );
                }
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(log == null ? "Simpan" : "Update"),
          ),
        ],
      ),
    ).then((_) => categoryNotifier.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.05),
        elevation: 0.5,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${widget.username}",
              style: const TextStyle(
                color: _kAccentBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              "Logbook Harian",
              style: TextStyle(
                color: _kAppBarText,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Logbook>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, child) {
                if (_isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _kAccentBlue),
                        SizedBox(height: 16),
                        Text("Menghubungkan ke MongoDB Atlas..."),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: _kAccentBlue,
                  onRefresh: _refreshData,
                  child: currentLogs.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          children: [
                            SizedBox(
                              height: 420,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.cloud_off,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text("Belum ada catatan di Cloud."),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () => _showLogDialog(context),
                                      child: const Text("Buat Catatan Pertama"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: currentLogs.length,
                          itemBuilder: (context, index) {
                            final log = currentLogs[index];
                            return Dismissible(
                              key: Key(
                                log.id ?? log.date.toIso8601String(),
                              ),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (direction) {
                                final deletedTitle = log.title;
                                _controller.removeLog(index);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Catatan "$deletedTitle" telah dihapus',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
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
                              child: LogItemWidget(
                                log: log,
                                onEditPressed: () => _showLogDialog(
                                  context,
                                  index: index,
                                  log: log,
                                ),
                                onDeletePressed: () {
                                  final deletedTitle = log.title;
                                  _controller.removeLog(index);
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Catatan "$deletedTitle" telah dihapus',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
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
                              ),
                            );
                          },
                        ),
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
        label: const Text(
          "Catatan Baru",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  MaterialPageRoute(
                    builder: (context) => const OnboardingView(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}