import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../onboarding/onboarding_view.dart';
import 'log_controller.dart';
import 'models/log_model.dart';
import 'widgets/log_item_widget.dart';
import '../../helpers/log_helper.dart';
import '../../services/access_control_service.dart';
import 'log_editor_page.dart';
import '../vision/vision_view.dart';

const Color _kBgColor = Color(0xFFF7F5DE);
const Color _kAccentBlue = Color(0xFF3D8BE8);
const Color _kAppBarText = Color(0xFF2D3E50);

class LogView extends StatefulWidget {
  final Map<String, String> currentUser;
  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late LogController _controller;

  bool _isLoading = false;
  bool _isOnline = true;

  // Shorthand getters untuk data user yang sering dipakai
  String get _uid => widget.currentUser['uid'] ?? '';
  String get _role => widget.currentUser['role'] ?? 'Anggota';

  @override
  void initState() {
    super.initState();
    _controller = LogController(currentUser: widget.currentUser);
    Future.microtask(() => _initDatabase());

    // Listen sync otomatis dari connectivity listener di controller
    _controller.syncStatusNotifier.addListener(_onSyncStatusChanged);
    _controller.isOnlineNotifier.addListener(_onConnectivityChanged);
  }

  void _onSyncStatusChanged() {
    final status = _controller.syncStatusNotifier.value;
    if (!mounted || status == null) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (status == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Koneksi pulih. Data berhasil diperbarui dari Cloud."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    setState(() {
      _isOnline = _controller.isOnlineNotifier.value;
    });
  }

  @override
  void dispose() {
    _controller.syncStatusNotifier.removeListener(_onSyncStatusChanged);
    _controller.isOnlineNotifier.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai sinkronisasi data dari Cloud...",
        source: "log_view.dart",
      );

      // fetchLogs() menangani koneksi + sinkronisasi secara internal
      final success = await _controller.fetchLogs();

      await LogHelper.writeLog(
        success
            ? "UI: Data berhasil disinkronkan dari Cloud."
            : "UI: Gagal sync Cloud, menampilkan data lokal.",
        source: "log_view.dart",
        level: success ? 2 : 1,
      );

      if (!success && mounted) {
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
    } catch (e) {
      await LogHelper.writeLog(
        "UI: Error tidak terduga - $e",
        source: "log_view.dart",
        level: 1,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    final success = await _controller.fetchLogs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil diperbarui dari Cloud."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Offline Mode: Koneksi terputus, menampilkan data lokal.",
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Navigasi ke halaman editor penuh (add / edit)
  void _goToEditor({Logbook? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  /// Navigasi ke halaman pratinjau (read-only)
  void _goToViewer(Logbook log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          controller: _controller,
          currentUser: widget.currentUser,
          isReadOnly: true,
        ),
      ),
    );
  }

  /// Warna latar Card berdasarkan kategori proyek
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mechanical':
        return Colors.green.shade100;
      case 'electronic':
        return Colors.blue.shade100;
      case 'software':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Tampilan informatif saat tidak ada catatan
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/empty_state.json',
            width: 180,
            height: 180,
            repeat: true,
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada aktivitas hari ini?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mulai catat kemajuan proyek Anda!",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (AccessControlService.canPerform(
            _role,
            AccessControlService.actionCreate,
          ))
            ElevatedButton.icon(
              onPressed: () => _goToEditor(),
              icon: const Icon(Icons.add),
              label: const Text("Buat Catatan Baru"),
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
        backgroundColor: Colors.black.withValues(alpha: 0.05),
        elevation: 0.5,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $_uid  ·  $_role",
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
            icon: const Icon(Icons.camera_alt, color: _kAccentBlue),
            tooltip: "Smart-Patrol Vision",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisionView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: _kAccentBlue),
            onPressed: () => _showLogoutConfirmDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => _controller.searchLog(val),
              decoration: InputDecoration(
                hintText: "Cari judul catatan...",
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
                  child: Builder(
                    builder: (context) {
                      final displayLogs = currentLogs.where((log) {
                        final String currentUid =
                            widget.currentUser['uid'] ?? '';
                        final String currentRole =
                            widget.currentUser['role'] ?? 'Anggota';

                        final bool isOwner = log.authorId == currentUid;
                        final bool isPublic = log.isPublic == true;
                        final bool isPrivileged =
                            currentRole == 'Asisten' || currentRole == 'Ketua';

                        return isOwner || isPublic || isPrivileged;
                      }).toList();

                      if (displayLogs.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: _buildEmptyState(),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: displayLogs.length,
                        itemBuilder: (context, index) {
                          final log = displayLogs[index];

                          // Cek apakah user yang login adalah pembuat catatan ini
                          final bool isOwner = log.authorId == _uid;

                          final bool canEdit = AccessControlService.canPerform(
                            _role,
                            AccessControlService.actionUpdate,
                            isOwner: isOwner,
                          );
                          final bool canDelete =
                              AccessControlService.canPerform(
                                _role,
                                AccessControlService.actionDelete,
                                isOwner: isOwner,
                              );

                          // Cari index asli di logsNotifier untuk removeLog/updateLog
                          final int realIndex = _controller.logs.indexWhere(
                            (l) => l.id == log.id,
                          );

                          return Dismissible(
                            key: Key(log.id ?? log.date.toIso8601String()),
                            direction: canDelete
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
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
                            onDismissed: canDelete
                                ? (direction) {
                                    final deletedTitle = log.title;
                                    if (realIndex != -1) {
                                      _controller.removeLog(
                                        realIndex,
                                        _role,
                                        _uid,
                                      );
                                    }
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                : null,
                            child: LogItemWidget(
                              log: log,
                              cardColor: _getCategoryColor(log.category),
                              canEdit: canEdit,
                              canDelete: canDelete,
                              isOnline: _isOnline,
                              onTap: () => canEdit && realIndex != -1
                                  ? _goToEditor(log: log, index: realIndex)
                                  : _goToViewer(log),
                              onEditPressed: canEdit && realIndex != -1
                                  ? () =>
                                        _goToEditor(log: log, index: realIndex)
                                  : () {},
                              onDeletePressed: canDelete && realIndex != -1
                                  ? () {
                                      final deletedTitle = log.title;
                                      _controller.removeLog(
                                        realIndex,
                                        _role,
                                        _uid,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).clearSnackBars();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  : () {},
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          AccessControlService.canPerform(
            _role,
            AccessControlService.actionCreate,
          )
          ? FloatingActionButton.extended(
              onPressed: () => _goToEditor(),
              backgroundColor: _kAccentBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Catatan Baru",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
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