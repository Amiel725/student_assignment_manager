import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assignment_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/loading_widget.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AssignmentProvider>().fetchAssignments(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _StatsBar(),
          _SearchAndFilter(),
          const SizedBox(height: 4),
          const Expanded(child: _AssignmentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    return Container(
      color: const Color(0xFF39B36E),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.totalCount == 0
                  ? 0
                  : provider.completedCount / provider.totalCount,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.completedCount} of ${provider.totalCount} assignments completed',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search assignments...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF39B36E)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...provider.allSubjects.map((subject) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(subject, style: const TextStyle(fontSize: 12)),
                    selected: provider.filterSubject == subject,
                    onSelected: (_) => provider.setFilterSubject(subject),
                    selectedColor: const Color(0xFF39B36E).withValues(alpha:0.15),
                    checkmarkColor: const Color(0xFF39B36E),
                    labelStyle: TextStyle(
                      color: provider.filterSubject == subject
                          ? const Color(0xFF39B36E)
                          : Colors.black54,
                      fontWeight: provider.filterSubject == subject
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentList extends StatelessWidget {
  const _AssignmentList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();

    if (provider.status == ViewStatus.loading && provider.assignments.isEmpty) {
      return const LoadingWidget(message: 'Fetching assignments...');
    }

    if (provider.status == ViewStatus.error) {
      return ErrorWidget2(
        message: provider.errorMessage,
        onRetry: () => provider.fetchAssignments(),
      );
    }

    if (provider.assignments.isEmpty) {
      return const EmptyWidget(message: 'No assignments found. Tap + to add one!');
    }

    return RefreshIndicator(
      color: const Color(0xFF39B36E),
      onRefresh: () => provider.fetchAssignments(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: provider.assignments.length,
        itemBuilder: (_, i) => AssignmentCard(assignment: provider.assignments[i]),
      ),
    );
  }
}