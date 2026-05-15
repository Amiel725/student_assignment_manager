import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';

class AddEditScreen extends StatefulWidget {
  final Assignment? assignment;
  const AddEditScreen({super.key, this.assignment});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late String _selectedSubject;
  late String _selectedDueDate;
  bool _isSaving = false;

  final List<String> _subjects = ['Math', 'Science', 'English', 'Amharic', 'Art', 'Physics', 'CTE'];
  final List<String> _dueDates = ['2026-05-20', '2026-05-21', '2026-05-22', '2026-05-25', '2026-05-26'];

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment?.title ?? '');
    _bodyController = TextEditingController(text: widget.assignment?.body ?? '');
    _selectedSubject = widget.assignment?.subject ?? 'Math';
    _selectedDueDate = widget.assignment?.dueDate ?? '2026-05-20';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<AssignmentProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.assignment!.copyWith(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        subject: _selectedSubject,
        dueDate: _selectedDueDate,
      );
      success = await provider.updateAssignment(updated);
    } else {
      final newAssignment = Assignment(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 1,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        subject: _selectedSubject,
        dueDate: _selectedDueDate,
      );
      success = await provider.createAssignment(newAssignment);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Assignment updated!' : 'Assignment created!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Assignment' : 'New Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'Assignment Title *'),
              TextFormField(
                controller: _titleController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Chapter 5 Homework',
                  prefixIcon: Icon(Icons.title, color: Color(0xFF39B36E)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),

              const SizedBox(height: 20),
              const _FieldLabel(text: 'Subject *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined, color: Color(0xFF39B36E)),
                ),
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedSubject = v!),
              ),

              const SizedBox(height: 20),
              const _FieldLabel(text: 'Due Date *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedDueDate,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF39B36E)),
                ),
                items: _dueDates.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _selectedDueDate = v!),
              ),

              const SizedBox(height: 20),
              const _FieldLabel(text: 'Description *'),
              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Add details about this assignment...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.notes, color: Color(0xFF39B36E)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39B36E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEditing ? 'Update Assignment' : 'Create Assignment',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }
}