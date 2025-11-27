# Laporan
LiveNotes - Flutter My Firebase App
NAMA: Ahmad Bachtiar Raflyansyah 
NIM: 362458302078
Kelas: 弐

### Deskripsi Proyek
LiveNotes adalah aplikasi Flutter yang mengintegrasikan Firebase Firestore untuk membuat catatan real-time. Aplikasi ini mendukung operasi CRUD (Create, Read, Update, Delete) dengan sinkronisasi otomatis antar perangkat.

## Fitur Utama
 Membuat Catatan Baru - Tambah judul dan konten catatan
 Membaca Catatan - Menampilkan daftar semua catatan
 Mengedit Catatan - Update data dengan form yang sudah terisi
 Menghapus Catatan - Hapus catatan dari Firestore

### Kode 
1. Menampilkan Form Edit saat ListTile Ditekan
   <img width="339" height="155" alt="image" src="https://github.com/user-attachments/assets/0a1511b5-f8ff-4ed0-8c43-2863bd89875c" />

Penjelasan: Properti onTap berfungsi sebagai pemicu sentuhan. Ketika widget disentuh, ia memanggil fungsi _showForm() sambil membawa data lama dari dokumen. Ini menampilkan formulir pengeditan yang sudah terisi dengan data yang ada, sehingga pengguna dapat memperbaruinya.

3. Update Data ke Firebase
   <img width="581" height="286" alt="image" src="https://github.com/user-attachments/assets/a47b4804-f8ac-4461-959f-f1958959f309" />

Penjelasan: Kode ini memperbarui dokumen spesifik di Firebase Firestore menggunakan method .update(). Fungsi ini:

Mengambil catatan berdasarkan ID (docId)
Mengganti nilai title dan content dengan data baru
Mencatat waktu pembaruan yang akurat menggunakan FieldValue.serverTimestamp() dari sisi server Firebase
3. Membaca Data Real-time
<img width="596" height="472" alt="image" src="https://github.com/user-attachments/assets/8e263683-de4f-42af-872a-d23263e36edf" />



### Hasil Implementasi

tampilan Awalnya 
![WhatsApp Image 2025-11-27 at 09 59 29](https://github.com/user-attachments/assets/8fe95647-aefd-4add-83b8-054a9a4243be)

tampilan saat mau menmbhkan catatan 
![WhatsApp Image 2025-11-27 at 09 59 29 (1)](https://github.com/user-attachments/assets/306b8709-ee87-446f-90aa-77891eae2074)

Display ketika catatn sudah dibuat
![WhatsApp Image 2025-11-27 at 09 59 30](https://github.com/user-attachments/assets/0a62cb53-c0d4-43d7-95a8-48797aa57ba5)

update
![WhatsApp Image 2025-11-27 at 09 59 30 (1)](https://github.com/user-attachments/assets/aa524c32-fbd8-4f8b-a874-8f8ea7f82b7b)

hasil setelah diUpdate
![WhatsApp Image 2025-11-27 at 09 59 30 (2)](https://github.com/user-attachments/assets/d9e02c3a-d1a9-427a-b394-d98677a756d3)

di FireStore Database
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/b5fbd6ad-005c-48d2-9fad-27ba5b2a7cf8" />

delte
![WhatsApp Image 2025-11-27 at 10 19 35](https://github.com/user-attachments/assets/88d6ecb6-3b35-453b-9a02-eeda62920045)

## 今まで色々ありがとうございました
