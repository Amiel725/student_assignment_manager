import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../screens/detail_screen.dart';
import '../screens/add_edit_screen.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const AssignmentCard({super.key, required this.assignment});

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
    final provider = context.read<AssignmentProvider>();
    final color = _subjectColor(assignment.subject);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(assignment: assignment)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => provider.toggleComplete(assignment.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: assignment.isCompleted ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: assignment.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            assignment.subject,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          assignment.dueDate,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      assignment.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: assignment.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: assignment.isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditScreen(assignment: assignment),
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(context, provider);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [
                    Icon(Icons.edit, size: 18, color: Color(0xFF39B36E)), SizedBox(width: 8), Text('Edit'),
                  ])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [
                    Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete'),
                  ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AssignmentProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              provider.deleteAssignment(assignment.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}