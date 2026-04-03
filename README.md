# logbook_app_093
---
## Modul 2_Part 2

<img src="./img.png" width="30%"> <img src="./img1.png" width="30%"> <img src="./img2.png" width="30%"> <img src="./img3.png" width="30%">

### Tabel Test Case Modul 2

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|--------------|-----------|-----------|----------------|------------|-------------------|-----------|------------|
| TC-M2-01 | login(String username, String password) | Positif | login should return true for valid credentials | Program siap dijalankan | setup controller, exercise login method, verify result | username="admin", password="123" | mengembalikan nilai true |
| TC-M2-02 | login(String username, String password) | Negatif | login should return false for invalid password | Program siap dijalankan | setup controller, exercise login method, verify result | username="admin", password="wrongpassword" | mengembalikan nilai false |
| TC-M2-03 | login(String username, String password) | Positif | login should return true for username with trailing/leading spaces (Bug) | Program siap dijalankan | setup controller, exercise login method, verify result | username=" admin ", password="123" | mengembalikan nilai true |

### Tabel Test Case Result Modul 2

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|--------------|-----------|-----------|----------------|------------|-------------------|-----------|------------|--------|-------|
| TC-M2-01 | login(String username, String password) | Positif | login should return true for valid credentials | Program siap dijalankan | setup controller, exercise login method, verify result | username="admin", password="123" | mengembalikan nilai true | mengembalikan nilai true | Pass |
| TC-M2-02 | login(String username, String password) | Negatif | login should return false for invalid password | Program siap dijalankan | setup controller, exercise login method, verify result | username="admin", password="wrongpassword" | mengembalikan nilai false | mengembalikan nilai false | Pass |
| TC-M2-03 | login(String username, String password) | Positif | login should return true for username with trailing/leading spaces (Bug) | Program siap dijalankan | setup controller, exercise login method, verify result | username=" admin ", password="123" | mengembalikan nilai true | mengembalikan nilai true | Pass (Fixed) |

### Daftar Bug (Bug Report)

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|----|-----------|--------------|---------------|--------------------|------------|---------|-----------------------|
| BUG-M2-01 | login() | TC-M2-03 | Tidak adanya validasi `trim()` penghapusan spasi (whitespace) di awal/akhir input. Akibatnya username valid ("admin") tertolak jika pengguna tak sengaja menekan spasi saat input (" admin "). | 1. Inisialisasi `LoginController`<br>2. Panggil `controller.login(" admin ", "123")`<br>3. Observasi return value dari sistem | Mengembalikan nilai `true` | Mengembalikan nilai `false` | `[Sisipkan Screenshot Log Error di sini]` |

### Tabel Summary Test

| Keterangan | Nilai |
|------------|-------|
| **Nama File** | `test/auth_controller_test.dart` |
| **Total Test Case** | 3 |
| **Total Test Pass** | 3 |
| **Total Test Fail** | 0 |

<br>

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|-----------|------------------|-----------|-----------|
| login(String username, String password) | 3 | 3 | 0 |
