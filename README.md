# logbook_app_093

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Modul 1_Part 2
<img src="./img.png" width="30%"> <img src="./img1.png" width="30%"> <img src="./img2.png" width="30%">

# Self-Reflection
Prinsip Single Responsibility (SRP) sangat membantu saat mengimplementasikan fitur History Logger. Dengan memisahkan logika di `CounterController`, saya bisa menambahkan pengelolaan daftar riwayat tanpa menyentuh atau merusak kode UI. Pemisahan ini membuat perubahan lebih aman, terarah, dan menjaga tampilan tetap stabil.
## Praktikum 1: Unit Testing

### Test Case (TC01 - TC10)

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | loadCounter(String) | Positif | initial value should be 0 | instance controller dibuat, data di storage kosong | panggil loadCounter(username), lalu cek value | username="admin" | nilai counter nol (0) |
| TC02 | setStep(int) | Positif | setStep should change step value | instance controller berjalan | panggil setStep(5), lalu cek step | step=5 | nilai step menjadi 5 |
| TC03 | setStep(int) | Negatif | setStep should ignore negative value | step bernilai 3 | panggil setStep(-1), lalu cek step | step=-1 | nilai step tidak berubah (tetap 3) |
| TC04 | increment(String) | Positif | increment should increase counter based on step | step bernilai 2, counter bernilai 0 | panggil increment(username), lalu cek value | username="admin", step=2 | nilai counter menjadi 2 |
| TC05 | decrement(String) | Positif | decrement should decrease counter based on step | step bernilai 2, counter bernilai 2 | panggil decrement(username), lalu cek value | username="admin", step=2 | nilai counter menjadi 0 |
| TC06 | decrement(String) | Negatif | decrement should not go below zero | step bernilai 5, counter bernilai 0 | panggil decrement(username), lalu cek value | username="admin", step=5 | nilai counter tidak di bawah nol (tetap 0) |
| TC07 | reset(String) | Positif | reset should set counter to zero | counter bernilai > 0 | panggil reset(username), lalu cek value | username="admin" | nilai counter menjadi 0 |
| TC08 | history | Positif | history should record actions | step bernilai 1, history kosong | panggil increment(username), lalu cek history | username="admin" | history merekam teks aksi |
| TC09 | history | Negatif | history should not exceed 5 items | step bernilai 1 | panggil increment 6 kali, lalu cek jumlah item history | 6 kali increment | jumlah item di history berjumlah maksimum 5 |
| TC10 | loadCounter(String) | Positif | counter should persist using SharedPreferences | step=3, counter sudah dimuat dan di-increment (bernilai 3) | buat instance baru, panggil loadCounter(username), cek value | username="admin" | nilai counter setelah diload adalah 3 |

### Test Case Result (TC01 - TC10)

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | loadCounter(String) | Positif | initial value should be 0 | instance controller dibuat, storage kosong | panggil loadCounter, cek value | username="admin" | counter nol (0) | counter nol (0) | Pass |
| TC02 | setStep(int) | Positif | setStep should change step value | instance berjalan | panggil setStep(5), cek step | step=5 | step menjadi 5 | step menjadi 5 | Pass |
| TC03 | setStep(int) | Negatif | setStep should ignore negative value | step bernilai 3 | panggil setStep(-1), cek step | step=-1 | step tetap 3 | step tetap 3 | Pass |
| TC04 | increment(String) | Positif | increment should increase counter based on step | step=2, counter=0 | panggil increment, cek value | username="admin", step=2 | counter menjadi 2 | counter menjadi 2 | Pass |
| TC05 | decrement(String) | Positif | decrement should decrease counter based on step | step=2, counter=2 | panggil decrement, cek value | username="admin", step=2 | counter menjadi 0 | counter menjadi 0 | Pass |
| TC06 | decrement(String) | Negatif | decrement should not go below zero | step=5, counter=0 | panggil decrement, cek value | username="admin", step=5 | counter tidak di bawah 0 (tetap 0) | counter tidak di bawah 0 (tetap 0) | Pass |
| TC07 | reset(String) | Positif | reset should set counter to zero | counter > 0 | panggil reset, cek value | username="admin" | counter menjadi 0 | counter tidak 0 (bug implementasi) | Fail |
| TC08 | history | Positif | history should record actions | step=1, history kosong | panggil increment, cek history | username="admin" | history merekam aksi | history merekam aksi | Pass |
| TC09 | history | Negatif | history should not exceed 5 items | step=1 | increment 6 kali, cek qty history | 6 kali increment | qty history max 5 | qty history max 5 | Pass |
| TC10 | loadCounter(String) | Positif | counter should persist using SharedPreferences | step=3, increment dilakukan (counter=3) | buat instance baru, loadCounter, cek value | username="admin" | counter dipulihkan jadi 3 | counter dipulihkan jadi 3 | Pass |

