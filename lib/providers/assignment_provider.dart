import 'package:flutter/foundation.dart';
import '../models/assignment.dart';
import '../services/api_service.dart';

enum ViewStatus { idle, loading, success, error }

class AssignmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Assignment> _assignments = [];
  ViewStatus _status = ViewStatus.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterSubject = 'All';
  bool _showCompletedOnly = false;

  List<Assignment> get assignments => _filteredAssignments;
  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get filterSubject => _filterSubject;
  bool get showCompletedOnly => _showCompletedOnly;

  int get totalCount => _assignments.length;
  int get completedCount => _assignments.where((a) => a.isCompleted).length;
  int get pendingCount => _assignments.where((a) => !a.isCompleted).length;

  List<String> get allSubjects {
    final subjects = _assignments.map((a) => a.subject).toSet().toList();
    subjects.sort();
    return ['All', ...subjects];
  }

  List<Assignment> get _filteredAssignments {
    return _assignments.where((a) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.subject.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSubject =
          _filterSubject == 'All' || a.subject == _filterSubject;

      final matchesCompleted = !_showCompletedOnly || a.isCompleted;

      return matchesSearch && matchesSubject && matchesCompleted;
    }).toList();
  }

  void _setStatus(ViewStatus s) {
    _status = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _status = ViewStatus.error;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterSubject(String subject) {
    _filterSubject = subject;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompletedOnly = !_showCompletedOnly;
    notifyListeners();
  }


  // READ
  Future<void> fetchAssignments() async {
    _setStatus(ViewStatus.loading);
    try {
      _assignments = await _apiService.fetchAssignments();
      _setStatus(ViewStatus.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // CREATE
  Future<bool> createAssignment(Assignment assignment) async {
    _setStatus(ViewStatus.loading);
    try {
      final created = await _apiService.createAssignment(assignment);
      final newAssignment = assignment.copyWith(id: created.id + _assignments.length);
      _assignments.insert(0, newAssignment);
      _setStatus(ViewStatus.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // UPDATE
  Future<bool> updateAssignment(Assignment assignment) async {
    _setStatus(ViewStatus.loading);
    try {
      await _apiService.updateAssignment(assignment);
      final index = _assignments.indexWhere((a) => a.id == assignment.id);
      if (index != -1) {
        _assignments[index] = assignment;
      }
      _setStatus(ViewStatus.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void toggleComplete(int id) {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _assignments[index] = _assignments[index].copyWith(
        isCompleted: !_assignments[index].isCompleted,
      );
      notifyListeners();
    }
  }

  // DELETE
  Future<bool> deleteAssignment(int id) async {
    _setStatus(ViewStatus.loading);
    try {
      await _apiService.deleteAssignment(id);
      _assignments.removeWhere((a) => a.id == id);
      _setStatus(ViewStatus.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}