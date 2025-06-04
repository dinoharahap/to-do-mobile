import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final bool isDone;
  final VoidCallback onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.nama,
    required this.deskripsi,
    required this.isDone,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDone ? Colors.green.withOpacity(0.3) : Colors.pinkAccent.withOpacity(0.1),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          activeColor: Colors.cyanAccent,
          onChanged: (_) => onToggleDone(),
        ),
        title: Text(
          nama,
          style: TextStyle(
            color: isDone ? Colors.greenAccent : Colors.white,
            decoration: isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          deskripsi,
          style: TextStyle(
            color: isDone ? Colors.greenAccent : Colors.white70,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.cyanAccent),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.pinkAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}