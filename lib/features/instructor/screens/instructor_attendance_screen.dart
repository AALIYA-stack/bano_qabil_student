// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import '../../../models/attendance_model.dart';
import '../../../models/batch_model.dart';
import '../../../services/attendance_service.dart';
import '../../../models/user_model.dart';
import '../../../services/batch_service.dart';
// import '../../../core/constants/collection_names.dart';

class InstructorAttendanceScreen extends StatefulWidget {
  const InstructorAttendanceScreen({super.key});

  @override
  State<InstructorAttendanceScreen> createState() =>
      _InstructorAttendanceScreenState();
}

class _InstructorAttendanceScreenState
    extends State<InstructorAttendanceScreen> {
  // final FirebaseFirestore _firestore =
  //     FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<BatchModel> _batches = [];
  List<UserModel> _students = [];

  final Map<String, String> _attendanceStatus = {};

  BatchModel? _selectedBatch;

  bool _isLoadingBatches = true;
  bool _isLoadingStudents = false;
  bool _isSaving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  // ============================================================
  // LOAD INSTRUCTOR BATCHES
  // ============================================================

  Future<void> _loadBatches() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _isLoadingBatches = false;
        _errorMessage = 'Instructor is not logged in.';
      });
      return;
    }

    try {
      final batches = await BatchService.instance.getBatchesForInstructor(
        user.uid,
      );

      if (!mounted) return;

      setState(() {
        _batches = batches;
        _isLoadingBatches = false;
      });

      if (batches.isNotEmpty) {
        await _selectBatch(batches.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingBatches = false;
        _errorMessage = 'Unable to load your batches.';
      });
    }
  }

  // ============================================================
  // SELECT BATCH
  // ============================================================

  Future<void> _selectBatch(BatchModel batch) async {
    setState(() {
      _selectedBatch = batch;
      _students = [];
      _attendanceStatus.clear();
      _isLoadingStudents = true;
      _errorMessage = null;
    });

    await _loadStudents(batch.id);
    await _loadTodayAttendance(batch.id);
  }

  // ============================================================
  // LOAD STUDENTS
  // ============================================================

  Future<void> _loadStudents(String batchId) async {
    try {
      final students = await AttendanceService.instance.getStudentsForBatch(
        batchId,
      );

      if (!mounted) return;

      setState(() {
        _students = students;
        _isLoadingStudents = false;

        for (final student in students) {
          _attendanceStatus.putIfAbsent(student.uid, () => 'present');
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStudents = false;
        _errorMessage = 'Unable to load students.';
      });
    }
  }

  // ============================================================
  // LOAD TODAY'S ATTENDANCE
  // ============================================================

  Future<void> _loadTodayAttendance(String batchId) async {
    try {
      final records = await AttendanceService.instance.getAttendanceForDate(
        batchId: batchId,
        date: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        for (final record in records) {
          _attendanceStatus[record.studentId] = record.status;
        }
      });
    } catch (e) {
      // Students can still be marked even if
      // today's existing records could not be loaded.
    }
  }

  // ============================================================
  // CHANGE STATUS
  // ============================================================

  void _setStatus(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<void> _saveAttendance() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      _showMessage('Instructor is not logged in.');
      return;
    }

    final BatchModel? batch = _selectedBatch;

    if (batch == null) {
      _showMessage('Please select a batch first.');
      return;
    }

    if (_students.isEmpty) {
      _showMessage('No students found in this batch.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();

      for (final student in _students) {
        final status = _attendanceStatus[student.uid] ?? 'present';

        await AttendanceService.instance.markAttendance(
          batchId: batch.id,
          studentId: student.uid,
          status: status,
          date: now,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Attendance saved successfully.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Unable to save attendance.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // STATUS BUTTON
  // ============================================================

  Widget _statusButton({
    required String studentId,
    required String status,
    required String label,
  }) {
    final bool selected = _attendanceStatus[studentId] == status;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          _setStatus(studentId, status);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? Colors.green.shade50 : null,
          side: BorderSide(
            color: selected ? Colors.green : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.green.shade700 : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentCard(UserModel student) {
    final status = _attendanceStatus[student.uid] ?? 'present';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundImage:
                      student.photoUrl != null && student.photoUrl!.isNotEmpty
                      ? NetworkImage(student.photoUrl!)
                      : null,
                  child: student.photoUrl == null || student.photoUrl!.isEmpty
                      ? Text(
                          student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name.isEmpty ? 'Unnamed Student' : student.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        student.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _statusButton(
                  studentId: student.uid,
                  status: 'present',
                  label: 'Present',
                ),
                const SizedBox(width: 8),
                _statusButton(
                  studentId: student.uid,
                  status: 'absent',
                  label: 'Absent',
                ),
                const SizedBox(width: 8),
                _statusButton(
                  studentId: student.uid,
                  status: 'late',
                  label: 'Late',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green.shade700;
      case 'absent':
        return Colors.red.shade700;
      case 'late':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: _buildBody(),
      bottomNavigationBar: _students.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAttendance,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save Attendance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoadingBatches) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _batches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_batches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No batches assigned to you.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBatches,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select Batch',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<BatchModel>(
            initialValue: _selectedBatch,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            items: _batches.map((batch) {
              return DropdownMenuItem<BatchModel>(
                value: batch,
                child: Text('${batch.id} • ${batch.classTime}'),
              );
            }).toList(),
            onChanged: (batch) {
              if (batch != null) {
                _selectBatch(batch);
              }
            },
          ),
          const SizedBox(height: 20),
          if (_selectedBatch != null) _batchHeader(_selectedBatch!),
          const SizedBox(height: 20),
          if (_isLoadingStudents)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No active students found in this batch.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            Text(
              '${_students.length} Students',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._students.map((student) => _studentCard(student)),
          ],
        ],
      ),
    );
  }

  Widget _batchHeader(BatchModel batch) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            batch.id,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('Class time: ${batch.classTime}'),
          const SizedBox(height: 4),
          Text('Room: ${batch.room}'),
          const SizedBox(height: 4),
          Text('Students: ${_students.length}'),
        ],
      ),
    );
  }
}
