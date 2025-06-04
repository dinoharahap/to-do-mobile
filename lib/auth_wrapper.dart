import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register/login.dart';
import 'page/halaman_utama.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika sedang loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Jika user sudah login
        if (snapshot.hasData && snapshot.data != null) {
          // Ambil data user dari Firestore (nama & motto)
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, AsyncSnapshot docSnap) {
              if (!docSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final data = docSnap.data?.data();
              final namaLengkap = data?['namaLengkap'] ?? '';
              final mottoHidup = data?['mottoHidup'] ?? '';
              return HalamanUtama(
                namaLengkap: namaLengkap,
                mottoHidup: mottoHidup,
              );
            },
          );
        }
        // Jika belum login
        return const LoginPage();
      },
    );
  }
}