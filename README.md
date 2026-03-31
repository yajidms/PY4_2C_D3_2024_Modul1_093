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

# Data Test Case (Sheet: TestCase)

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian (AAA) | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | Inisialisasi | Positif | initial value should be 0 | Program siap | setup: inisialisasi CounterController. exercise: get nilai counter aktual. verify: bandingkan aktual & ekspektasi | - | nilai counter sekarang nol. |
| TC02 | setStep(int val) | Positif | setStep should change step value | Program siap | setup: inisialisasi CounterController. exercise: panggil fungsi setStep sesuai data. verify: bandingkan aktual & ekspektasi | NewStep = 5 | nilai step sekarang 5. |
| TC03 | setStep(int val) | Negatif | setStep should change step value even if negative | Program siap | setup: inisialisasi CounterController. exercise: setStep(-1). verify: bandingkan aktual & ekspektasi | Step awal = 3, NewStep = -1 | (Catatan: Sesuai kode, tidak ada validasi negatif di setStep, jadi step akan berubah ke -1). |
| TC04 | increment() | Positif | increment should increase counter by step | Program siap | setup: inisialisasi controller dan setStep(2). exercise: panggil increment(). verify: periksa nilai counter aktual. | NewStep = 2 | nilai counter menjadi 2 (ditambah dari 0). |
| TC05 | decrement() | Positif | decrement should decrease counter by step if counter >= step | Program siap | setup: inisialisasi controller, setStep(2), dan increment 2 kali hingga nilai=4. exercise: panggil decrement(). verify: periksa nilai counter. | NewStep = 2, Counter = 4 | nilai counter berkurang 2 menjadi 2. |
| TC06 | decrement() | Negatif / Boundary | decrement should set counter to 0 if counter < step | Program siap | setup: inisialisasi controller, setStep(2), increment() sehingga nilai=2, lalu setStep(3). exercise: panggil decrement(). verify: periksa nilai counter. | NewStep = 3, Counter = 2 | decrement mentok ke 0. counter menjadi 0. |
| TC07 | reset() | Positif | reset should set counter to 0 and clear history | Program siap | setup: inisialisasi controller, panggil increment() agar tidak 0 dan ada history. exercise: panggil reset(). verify: periksa nilai counter & history. | - | nilai counter menjadi 0 dan array list history kosong. |
| TC08 | \_addHistory() | Positif | history should add new item on increment/decrement | Program siap | setup: inisialisasi controller. exercise: panggil increment(). verify: periksa panjang & isi history. | NewStep = 1 | panjang elements list di history=1, isinya log increment terbaru. |
| TC09 | \_addHistory() | Boundary | history should keep maximum 5 items | Program siap | setup: inisialisasi controller. exercise: panggil increment() 6 kali berturut-turut. verify: periksa panjang dan isi array list. | Loop increment = 6x | panjang array tetap maksimal 5 item. yang paling lama dihapus. |
| TC10 | \_addHistory() | Positif | history adds new items to the beginning of the list | Program siap | setup: inisialisasi controller, panggil increment() pertama. exercise: panggil increment() kedua. verify: pastikan log index 0 merupakan log terakhir. | Panggilan berurutan 2 kali | urutan riwayat (history) teratas menunjukkan aktivitas terakhir (LIFO). |

# Data Test Case Result (Sheet: TestCaseResult)

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian (AAA) | Data Test | Ekspektasi | Aktual | Hasil (Pass/Fail) |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | Inisialisasi | Positif | initial value should be 0 | Program siap | setup: inisialisasi CounterController. exercise: get nilai counter aktual. verify: bandingkan aktual & ekspektasi | - | nilai counter sekarang nol. | | - |
| TC02 | setStep(int val) | Positif | setStep should change step value | Program siap | setup: inisialisasi CounterController. exercise: panggil fungsi setStep. verify: bandingkan aktual | NewStep = 5 | nilai step sekarang 5. | | - |
| TC03 | setStep(int val) | Negatif | setStep should change step value even if negative | Program siap | setup: inisialisasi CounterController. exercise: setStep(-1). verify: bandingkan aktual | Step awal = 3, NewStep = -1 | nilai step berubah menjadi -1. | | - |
| TC04 | increment() | Positif | increment should increase counter by step | Program siap | setup: inisialisasi controller, setStep(2). exercise: increment(). verify: periksa counter. | NewStep = 2 | nilai counter menjadi 2. | | - |
| TC05 | decrement() | Positif | decrement should decrease counter by step if counter >= step | Program siap | setup: inisialisasi controller, setStep(2), double increment. exercise: decrement(). verify: periksa counter. | NewStep = 2, Counter = 4 | nilai counter berkurang 2 menjadi 2. | | - |
| TC06 | decrement() | Negatif / Boundary | decrement should set counter to 0 if counter < step | Program siap | setup: inisialisasi controller, nilai=2, lalu setStep(3). exercise: decrement(). verify: periksa counter. | NewStep = 3, Counter = 2 | decrement mentok ke 0. counter menjadi 0. | | - |
| TC07 | reset() | Positif | reset should set counter to 0 and clear history | Program siap | setup: inisialisasi controller, panggil increment(). exercise: reset(). verify: periksa nilai counter & history. | - | nilai counter 0 dan history kosong. | | - |
| TC08 | \_addHistory() | Positif | history should add new item on increment/decrement | Program siap | setup: inisialisasi controller. exercise: increment(). verify: periksa list history. | NewStep = 1 | panjang list=1, isinya log increment terbaru. | | - |
| TC09 | \_addHistory() | Boundary | history should keep maximum 5 items | Program siap | setup: inisialisasi controller. exercise: panggil increment() 6 kali. verify: periksa panjang max list. | Loop increment = 6x | panjang array max 5 item. | | - |
| TC10 | \_addHistory() | Positif | history adds new items to the beginning of the list | Program siap | setup: inisialisasi, panggil increment() pertama. exercise: increment() kedua. verify: index 0 di history. | Panggilan 2 kali | index teratas history adalah log terakhir (LIFO). | | - |
