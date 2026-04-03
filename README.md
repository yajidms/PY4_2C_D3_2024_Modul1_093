# logbook_app_093
---
## Modul 4_Part 2

<img src="./img.png" width="30%"> <img src="./img1.png" width="30%"> <img src="./img2.jpg" width="30%"> <img src="./img3.png" width="30%">

## Konfigurasi .env (Audit Logging)

Tambahkan key berikut di file `.env`:

```env
MONGODB_URI=<uri-atlas>
MONGODB_DB_NAME=logbook_db
MONGODB_COLLECTION_NAME=logs
LOG_LEVEL=3
LOG_MUTE=connection_test.dart,mongo_service.dart
```

Catatan:
- `LOG_LEVEL=3` -> log tampil juga di terminal (verbose mode).
- `LOG_LEVEL=1/2` -> log tetap masuk debug logger, tapi terminal di-mute.
- `LOG_MUTE` berisi daftar source (dipisah koma) untuk disembunyikan dari output log.

### Test Case Modul 4

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | dotenv.load | Positif | dotenv should load MONGODB_URI successfully | File .env tersedia dan valid | Setup: dotenv.load(). Act: cek dotenv.env['MONGODB_URI']. Verify: periksa apakah nilainya tidak null. | isi file .env | mengembalikan true (variabel tidak null) |
| TC-M4-02 | connect() | Positif | connect should successfully establish connection | File .env tersedia dan valid | Setup: load dotenv & init service. Act: mongoService.connect(). Verify: cek isConnected. | pemanggilan mongoService.connect() | status isConnected bernilai true |
| TC-M4-03 | close() | Positif | close should terminate connection | File .env tersedia dan valid | Setup: mongoService.connect(). Act: mongoService.close(). Verify: cek jika db menjadi null. | pemanggilan mongoService.close() | objek db bernilai null |

### Test Case Result Modul 4

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | dotenv.load | Positif | dotenv should load MONGODB_URI successfully | File .env tersedia dan valid | Setup: dotenv.load(). Act: cek dotenv.env['MONGODB_URI']. Verify: periksa apakah nilainya tidak null. | isi file .env | mengembalikan true (variabel tidak null) | mengembalikan true | Pass |
| TC-M4-02 | connect() | Positif | connect should successfully establish connection | File .env tersedia dan valid | Setup: load dotenv & init service. Act: mongoService.connect(). Verify: cek isConnected. | pemanggilan mongoService.connect() | status isConnected bernilai true | status isConnected bernilai true | Pass |
| TC-M4-03 | close() | Positif | close should terminate connection | File .env tersedia dan valid | Setup: mongoService.connect(). Act: mongoService.close(). Verify: cek jika db menjadi null. | pemanggilan mongoService.close() | objek db bernilai null | objek db bernilai null | Pass |

### Test Summary Modul 4

| Keterangan | Nilai |
|---|---|
| **Nama File** | `test/connection_test.dart` |
| **Total Test Case** | 3 |
| **Total Test Pass** | 3 |
| **Total Test Fail** | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|:---:|:---:|:---:|
| dotenv.load | 1 | 1 | 0 |
| connect() | 1 | 1 | 0 |
| close() | 1 | 1 | 0 |
