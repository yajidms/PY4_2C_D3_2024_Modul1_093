# logbook_app_093
---
## Modul 3_Part 2

<img src="./img.png" width="30%"> <img src="./img1.png" width="30%"> <img src="./img2.png" width="30%"> <img src="./img3.png" width="30%">

### Test Case Modul 3

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|------|---|---|---|---|---|---|---|
| TC01 | addLog | Positif | addLog should add a new log | Program siap dijalankan & Mock storage disiapkan | Setup: siapkan storage & add log, Act: periksa jumlah log, Verify: cocokkan hasil | title="Test Title", desc="Test Desc" | list logs bertambah menjadi 1 |
| TC02 | updateLog | Positif | updateLog should modify existing log | Program siap dijalankan & Mock storage disiapkan | Setup: buat log awal, Act: ubah data log, Verify: cocokkan perubahan judul | index=0, title="New Title" | judul log berubah menjadi "New Title" |
| TC03 | removeLog | Positif | removeLog should delete log at index | Program siap dijalankan & Mock storage disiapkan | Setup: buat beberapa log, Act: hapus log index 0, Verify: jumlah log tersisa 1 | index=0 | panjang list logs berkurang menjadi 1 |
| TC04 | searchLog | Positif | searchLog should filter logs | Program siap dijalankan & Mock storage disiapkan | Setup: buat beberapa log, Act: cari dengan keyword, Verify: log sesuai yang dicari | query="app" | filteredLogs hanya berisi log "Apple" |
| TC05 | loadFromDisk | Positif | logs persist using SharedPreferences | Program siap dijalankan & Mock storage disiapkan | Setup: buat log, Act: buat instance baru dan muat data, Verify: data tetap ada | instance baru LogController | log "Persisted Log" berhasil dimuat ulang |

### Test Case Result Modul 3

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | addLog | Positif | addLog should add a new log | Program siap dijalankan & Mock storage disiapkan | Setup: siapkan storage & add log, Act: periksa jumlah log, Verify: cocokkan hasil | title="Test Title", desc="Test Desc" | list logs bertambah menjadi 1 | list logs bertambah menjadi 1 | Pass |
| TC02 | updateLog | Positif | updateLog should modify existing log | Program siap dijalankan & Mock storage disiapkan | Setup: buat log awal, Act: ubah data log, Verify: cocokkan perubahan judul | index=0, title="New Title" | judul log berubah menjadi "New Title" | judul log berubah menjadi "New Title" | Pass |
| TC03 | removeLog | Positif | removeLog should delete log at index | Program siap dijalankan & Mock storage disiapkan | Setup: buat beberapa log, Act: hapus log index 0, Verify: jumlah log tersisa 1 | index=0 | panjang list logs berkurang menjadi 1 | panjang list logs berkurang menjadi 1 | Pass |
| TC04 | searchLog | Positif | searchLog should filter logs | Program siap dijalankan & Mock storage disiapkan | Setup: buat beberapa log, Act: cari dengan keyword, Verify: log sesuai yang dicari | query="app" | filteredLogs hanya berisi log "Apple" | filteredLogs hanya berisi log "Apple" | Pass |
| TC05 | loadFromDisk | Positif | logs persist using SharedPreferences | Program siap dijalankan & Mock storage disiapkan | Setup: buat log, Act: buat instance baru dan muat data, Verify: data tetap ada | instance baru LogController | log "Persisted Log" berhasil dimuat ulang | log "Persisted Log" berhasil dimuat ulang | Pass |

### Summary Test Result

| Keterangan | Nilai                      |
|---|----------------------------|
| **Nama File** | `log_controller_test.dart` |
| **Total Test Case** | 5                          |
| **Total Test Pass** | 5                          |
| **Total Test Fail** | 0                          |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|-----------|-----------|
| addLog | 1 | 1         | 0         |
| updateLog | 1 | 1         | 0         |
| removeLog | 1 | 1         | 0         |
| searchLog | 1 | 1         | 0         |
| loadFromDisk | 1 | 1         | 0         |
