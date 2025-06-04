class Todo {
  final String id;
  final String namaKegiatan;
  final String deskripsi;
  final String tanggal;
  final bool isDone;

  Todo({
    required this.id,
    required this.namaKegiatan,
    required this.deskripsi,
    required this.tanggal,
    required this.isDone,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      namaKegiatan: map['namaKegiatan'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      tanggal: map['tanggal'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaKegiatan': namaKegiatan,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
      'isDone': isDone,
    };
  }
}