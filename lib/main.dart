// File: lib/main.dart (contoh nama file)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Pastikan file ini ada dan sudah digenerate

// =================================================================
// BAGIAN UTAMA (MAIN)
// =================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi koneksi ke Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

// =================================================================
// BAGIAN HOMEPAGE (Read, Create, Delete)
// =================================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Deklarasi TextEditingController dan CollectionReference
  // Variabel untuk menyimpan input form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Referensi Koleksi Firestore
  final CollectionReference _notes =
      FirebaseFirestore.instance.collection('notes');

  // Pastikan untuk membersihkan controller saat State dihapus
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  // 2. Method _showForm (untuk Menambah Data - CREATE)
  void _showForm(BuildContext context) {
    // Reset controller jika form dipanggil untuk CREATE (tanpa parameter 'document')
    _titleController.clear();
    _contentController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          // Ini memastikan keyboard tidak menutupi input
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Isi Catatan'),
              keyboardType: TextInputType.multiline,
              maxLines: null, // Memungkinkan input multi-baris
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String title = _titleController.text;
                final String content = _contentController.text;

                if (content.isNotEmpty) {
                  // PERINTAH SIMPAN KE FIREBASE
                  await _notes.add({
                    "title": title,
                    "content": content,
                    // Menggunakan serverTimestamp untuk waktu yang konsisten
                    "timestamp": FieldValue.serverTimestamp(), 
                  });

                  // Bersihkan Input & Tutup Modal
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Simpan Catatan"),
            )
          ],
        ),
      ),
    );
  }

  // 3. Widget build (untuk Menampilkan Data - READ with StreamBuilder)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Notes Fire")),

      // STREAMBUILDER: Bagian terpenting untuk Real-time
      body: StreamBuilder<QuerySnapshot>(
        // Mendengarkan perubahan pada koleksi 'notes', diurutkan berdasarkan waktu terbaru
        stream: _notes.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Kondisi 1: Masih Loading (Koneksi aktif, tapi data belum diterima)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Kondisi 2: Data Kosong (Query selesai, tapi tidak ada dokumen)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada catatan."));
          }

          // Kondisi 3: Ada Data -> Tampilkan ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(document['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(document['content']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Fungsi Hapus (DELETE)
                      // Menghapus dokumen berdasarkan ID uniknya
                      _notes.doc(document.id).delete(); 
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context), // Panggil fungsi CREATE
        child: const Icon(Icons.add),
      ),
    );
  }
}