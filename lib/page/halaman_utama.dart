import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart'; // Pastikan path sesuai
import 'todo_form.dart';
import 'todo_card.dart';

class HalamanUtama extends StatefulWidget {
  final String namaLengkap;
  final String mottoHidup;

  const HalamanUtama({
    Key? key,
    required this.namaLengkap,
    required this.mottoHidup,
  }) : super(key: key);

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF24243e),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(color: Colors.cyanAccent),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Batal', style: TextStyle(color: Colors.cyanAccent)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.pinkAccent)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _showTodoForm({String? docId, DateTime? initialDate, String? initialNama, String? initialDeskripsi}) {
    showDialog(
      context: context,
      builder: (context) => TodoForm(
        initialDate: initialDate,
        initialNama: initialNama,
        initialDeskripsi: initialDeskripsi,
        onSubmit: (tanggal, nama, deskripsi) async {
          final tanggalStr = "${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}";
          if (docId == null) {
            // Create
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('todos')
                .add({
              'tanggal': tanggalStr,
              'namaKegiatan': nama,
              'deskripsi': deskripsi,
              'isDone': false,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            // Update
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('todos')
                .doc(docId)
                .update({
              'tanggal': tanggalStr,
              'namaKegiatan': nama,
              'deskripsi': deskripsi,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        },
      ),
    );
  }

  Future<void> _toggleDone(String docId, bool isDone) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(docId)
        .update({'isDone': !isDone, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> _deleteKegiatan(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0f0c29),
                Color(0xFF302b63),
                Color(0xFF24243e),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.cyanAccent,
                      child: Icon(Icons.person, size: 40, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.namaLengkap,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.mottoHidup,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.cyanAccent,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.cyanAccent),
                title: const Text(
                  'Halaman Utama',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Menutup drawer
                  // Jika sudah di halaman utama, cukup tutup drawer saja
                  // Jika ingin navigasi dari halaman lain, bisa gunakan pushReplacement ke HalamanUtama
                  // Contoh:
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => HalamanUtama(
                  //       namaLengkap: widget.namaLengkap,
                  //       mottoHidup: widget.mottoHidup,
                  //     ),
                  //   ),
                  // );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.cyanAccent),
                title: const Text(
                  'Edit Profil',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        namaAwal: widget.namaLengkap,
                        mottoAwal: widget.mottoHidup,
                      ),
                    ),
                  );
                  if (result != null && result is Map) {
                    // Buat ulang halaman utama dengan data baru
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanUtama(
                          namaLengkap: result['namaLengkap'],
                          mottoHidup: result['mottoHidup'],
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.pinkAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF302b63),
        title: Text(
          'Halo, ${widget.namaLengkap}',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.pinkAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showTodoForm(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('todos')
              .orderBy('tanggal')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }
            final docs = snapshot.data!.docs;
            // Group by tanggal
            final Map<String, List<QueryDocumentSnapshot>> grouped = {};
            for (var doc in docs) {
              final tanggal = doc['tanggal'] ?? '';
              grouped.putIfAbsent(tanggal, () => []).add(doc);
            }
            if (grouped.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada kegiatan.\nTekan tombol + untuk menambah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                final tanggal = entry.key;
                final kegiatanList = entry.value;
                return Card(
                  color: Colors.black.withOpacity(0.7),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal: $tanggal',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...kegiatanList.map((doc) {
                          final nama = doc['namaKegiatan'] ?? '';
                          final deskripsi = doc['deskripsi'] ?? '';
                          final isDone = doc['isDone'] ?? false;
                          return TodoCard(
                            nama: nama,
                            deskripsi: deskripsi,
                            isDone: isDone,
                            onToggleDone: () => _toggleDone(doc.id, isDone),
                            onEdit: () => _showTodoForm(
                              docId: doc.id,
                              initialDate: DateTime.parse(doc['tanggal']),
                              initialNama: nama,
                              initialDeskripsi: deskripsi,
                            ),
                            onDelete: () => _deleteKegiatan(doc.id),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}