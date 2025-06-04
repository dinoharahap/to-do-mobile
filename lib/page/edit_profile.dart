import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'halaman_utama.dart'; // Pastikan path sesuai

class EditProfilePage extends StatefulWidget {
  final String namaAwal;
  final String mottoAwal;

  const EditProfilePage({
    Key? key,
    required this.namaAwal,
    required this.mottoAwal,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _mottoController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaAwal);
    _mottoController = TextEditingController(text: widget.mottoAwal);
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      // Update nama & motto di Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'namaLengkap': _namaController.text.trim(),
            'mottoHidup': _mottoController.text.trim(),
          });

      // Jika password diisi, update password di Auth
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception("Password dan konfirmasi password tidak sama");
        }
        await user.updatePassword(_passwordController.text);
      }

      // Setelah update sukses, ambil data terbaru
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      final namaBaru = data?['namaLengkap'] ?? '';
      final mottoBaru = data?['mottoHidup'] ?? '';

      setState(() {
        _successMessage = "Profil berhasil diperbarui!";
      });

      // Kembali ke halaman utama dengan data baru
      Navigator.of(
        context,
      ).pop({'namaLengkap': namaBaru, 'mottoHidup': mottoBaru});
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.cyanAccent),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.pinkAccent),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Tutup dialog dan drawer, lalu kembali ke root (AuthWrapper akan handle session)
                  Navigator.of(ctx).pop(); // Tutup dialog
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
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
                            _namaController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _mottoController.text,
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (ctx) => HalamanUtama(
                            namaLengkap: _namaController.text,
                            mottoHidup: _mottoController.text,
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.cyanAccent),
                title: const Text(
                  'Edit Profil',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Sudah di halaman ini
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.pinkAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xFF302b63),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: Colors.cyanAccent.withOpacity(0.7),
                  width: 2,
                ),
              ),
              color: Colors.black.withOpacity(0.7),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Edit Profil",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _namaController,
                        style: const TextStyle(color: Colors.cyanAccent),
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          labelStyle: const TextStyle(color: Colors.cyanAccent),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.pinkAccent,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyanAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.pinkAccent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Masukkan nama lengkap"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mottoController,
                        style: const TextStyle(color: Colors.pinkAccent),
                        decoration: InputDecoration(
                          labelText: "Motto Hidup",
                          labelStyle: const TextStyle(color: Colors.pinkAccent),
                          prefixIcon: const Icon(
                            Icons.format_quote,
                            color: Colors.cyanAccent,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.pinkAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyanAccent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Masukkan motto hidup"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.cyanAccent),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.pinkAccent),
                        decoration: InputDecoration(
                          labelText: "Password Baru (opsional)",
                          labelStyle: const TextStyle(color: Colors.pinkAccent),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.cyanAccent,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.pinkAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyanAccent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.cyanAccent),
                        decoration: InputDecoration(
                          labelText: "Konfirmasi Password Baru",
                          labelStyle: const TextStyle(color: Colors.cyanAccent),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.pinkAccent,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyanAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.pinkAccent,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      if (_successMessage != null)
                        Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.cyanAccent),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00fff0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.pinkAccent,
                            elevation: 10,
                          ),
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      _updateProfile();
                                    }
                                  },
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Simpan Perubahan",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8,
                                          color: Colors.pinkAccent,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
