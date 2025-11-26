
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import file konfigurasi yang digenerate oleh FlutterFire CLI
import 'firebase_options.dart'; 

// =================================================================
// 1. FUNGSI UTAMA (main)
// =================================================================

void main() async {
  // Memastikan binding Flutter siap sebelum memanggil native code
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
      title: 'Live Notes Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

// =================================================================
// 2. HOMEPAGE (CREATE, READ, UPDATE, DELETE)
// =================================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variabel untuk menyimpan input form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Referensi Koleksi Firestore (di sini kita namakan 'notes')
  final CollectionReference _notes =
      FirebaseFirestore.instance.collection('notes');

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  // --- FUNGSI CREATE DAN UPDATE ---
  
  // Parameter documentKey bersifat opsional. Jika null: CREATE, jika ada: UPDATE.
  void _showForm(BuildContext context, [DocumentSnapshot? documentKey]) {
    // 1. Mode Edit (Isi Controller dengan Data Lama)
    if (documentKey != null) {
      _titleController.text = documentKey['title'];
      _contentController.text = documentKey['content'];
    } else {
      // 2. Mode Create (Pastikan Controller Bersih)
      _titleController.clear();
      _contentController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
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
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String title = _titleController.text;
                final String content = _contentController.text;

                if (content.isNotEmpty) {
                  // Data yang akan diproses
                  final Map<String, dynamic> data = {
                    "title": title,
                    "content": content,
                    // Menggunakan serverTimestamp untuk konsistensi waktu
                    "timestamp": FieldValue.serverTimestamp(), 
                  };

                  if (documentKey != null) {
                    // Perintah UPDATE
                    await _notes.doc(documentKey.id).update(data);
                  } else {
                    // Perintah CREATE
                    await _notes.add(data);
                  }

                  // Bersihkan Input & Tutup Modal setelah operasi selesai
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text(documentKey == null ? "Simpan Catatan Baru" : "Update Catatan"),
            )
          ],
        ),
      ),
    );
  }
  
  // --- WIDGET BUILD (READ & DELETE) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Notes Fire")),

      // STREAMBUILDER: Membaca data secara Real-time
      body: StreamBuilder<QuerySnapshot>(
        // Query: Ambil koleksi 'notes', diurutkan berdasarkan waktu terbaru
        stream: _notes.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Kondisi 1: Masih Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Kondisi 2: Data Kosong
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
                  // 💡 Panggil _showForm untuk mode EDIT saat ListTile ditekan
                  onTap: () => _showForm(context, document), 
                  title: Text(document['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(document['content']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Perintah DELETE
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
        // Panggil _showForm tanpa parameter untuk mode CREATE
        onPressed: () => _showForm(context), 
        child: const Icon(Icons.add),
      ),
    );
  }
}