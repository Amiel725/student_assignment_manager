import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final Assignment assignment;
  const DetailScreen({super.key, required this.assignment});

  Color _subjectColor(String subject) {
    const colors = {
      'Math': Color(0xFF39B36E),
      'Science': Color(0xFF39B36E),
      'English': Color(0xFF39B36E),
      'Amharic': Color(0xFF39B36E),
      'Art': Color(0xFF39B36E),
      'Physics': Color(0xFF39B36E),
      'CTE': Color(0xFF39B36E),
      'General': Color(0xFF39B36E),
};
    return colors[subject] ?? const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    // Use updated version if it exists in provider
    final current = provider.assignments.firstWhere(
      (a) => a.id == assignment.id,
      orElse: () => assignment,
    );
    final color = _subjectColor(current.subject);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Assignment Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditScreen(assignment: current)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(current.subject, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: current.isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    current.isCompleted ? '✅ Completed' : '⏳ Pending',
                    style: TextStyle(
                      color: current.isCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              current.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Meta info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.person_outline, label: 'Student ID', value: 'User ${current.userId}'),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.calendar_today, label: 'Due Date', value: current.dueDate),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.tag, label: 'Assignment ID', value: '#${current.id}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.body,
                      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Toggle complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.toggleComplete(current.id);
                  Navigator.pop(context);
                },
                icon: Icon(current.isCompleted ? Icons.undo : Icons.check_circle_outline),
                label: Text(current.isCompleted ? 'Mark as Pending' : 'Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: current.isCompleted ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AssignmentProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteAssignment(assignment.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF39B36E)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}