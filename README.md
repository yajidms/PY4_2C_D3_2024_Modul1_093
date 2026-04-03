# logbook_app_093
---
## Modul 2_Part 2

<img src="./img.png" width="30%"> <img src="./img1.png" width="30%"> <img src="./img2.png" width="30%"> <img src="./img3.png" width="30%">

### Dokumentasi Pengujian Modul 2 (Authentication)

#### Test Case Modul 2
| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | `login(String username, String password)` | Positif | login should return true for valid credentials | Program siap dijalankan | 1. **Setup**: Inisialisasi `LoginController`<br>2. **Exercise**: Panggil `login("admin", "123")`<br>3. **Verify**: Pastikan mengembalikan nilai `true` | `username="admin"`, `password="123"` | mengembalikan nilai `true` |
| TC02 | `login(String username, String password)` | Negatif | login should return false for invalid password | Program siap dijalankan | 1. **Setup**: Inisialisasi `LoginController`<br>2. **Exercise**: Panggil `login("admin", "wrongpassword")`<br>3. **Verify**: Pastikan mengembalikan nilai `false` | `username="admin"`, `password="wrongpassword"` | mengembalikan nilai `false` |
| TC03 | `login(String username, String password)` | Negatif | login should return false for unregistered user | Program siap dijalankan | 1. **Setup**: Inisialisasi `LoginController`<br>2. **Exercise**: Panggil `login("unknown_user", "123")`<br>3. **Verify**: Pastikan mengembalikan nilai `false` | `username="unknown_user"`, `password="123"` | mengembalikan nilai `false` |

#### Test Case Result Modul 2
| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | `login(String username, String password)` | Positif | login should return true for valid credentials | Program siap dijalankan | 1. **Setup**: Inisialisasi `LoginController`<br>2. **Exercise**: Panggil `login("admin", "123")`<br>3. **Verify**: Pastikan mengembalikan nilai `true` | `username="admin"`, `password="123"` | mengembalikan nilai `true` | mengembalikan nilai `true` | Pass |
| TC02 | `login(String username, String password)` | Negatif | login should return false for invalid password | Program siap dijalankan | 1. **Setup**: Inisialisasi `LoginController`<br>2. **Exercise**: Panggil `login("admin", "wrongpassword")`<br>3. **Verify**: Pastikan mengembalikan nilai `false` | `username="admin"`, `password="wrongpassword"` | mengembalikan nilai `false` | mengembalikan nilai `false` | Pass |
| TC03 | `login(String username, String password)` | Negatif | login should return false for unregistered user | Program siap dijalankan | 1. **Setup**: Inisialisasi `LoginController`<br>2. **Exercise**: Panggil `login("unknown_user", "123")`<br>3. **Verify**: Pastikan mengembalikan nilai `false` | `username="unknown_user"`, `password="123"` | mengembalikan nilai `false` | mengembalikan nilai `false` | Pass |

#### Test Summary Modul 2

| Keterangan | Detail |
|---|---|
| **Nama File** | `test/auth_controller_test.dart` |
| **Total Test Case** | 3 |
| **Total Test Pass** | 3 |
| **Total Test Fail** | 0 |

<br>

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|:---:|:---:|:---:|
| `login(String username, String password)` | 3 | 3 | 0 |
