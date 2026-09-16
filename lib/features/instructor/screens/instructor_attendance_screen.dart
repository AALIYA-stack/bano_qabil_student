import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/attendance_service.dart';

class InstructorAttendanceScreen extends StatefulWidget {
  const InstructorAttendanceScreen({super.key});

  @override
  State<InstructorAttendanceScreen> createState() =>
      _InstructorAttendanceScreenState();
}

class _InstructorAttendanceScreenState
    extends State<InstructorAttendanceScreen> {
  final AttendanceService _attendanceService =
      AttendanceService.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now();

  String? _batchId;
  String? _courseId;
  String _courseName = '';

  List<Map<String, dynamic>> _students = [];

  final Map<String, String> _attendanceStatus = {};

  bool _isLoading = true;
  bool _isSaving = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _primaryGreen = Color(0xFF006B3C);
  static const Color _darkGreen = Color(0xFF004D2C);
  static const Color _lightGreen = Color(0xFF8BC53F);
  static const Color _paleGreen = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  // ============================================================
  // LOAD INSTRUCTOR DATA
  // ============================================================

  Future<void> _loadAttendanceData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final User? user = _auth.currentUser;

      if (user == null) {
        throw Exception('Instructor is not logged in.');
      }

      debugPrint(
        'ATTENDANCE: Logged in instructor UID = ${user.uid}',
      );

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Instructor profile not found.');
      }

      final Map<String, dynamic>? userData =
      userDoc.data();

      if (userData == null) {
        throw Exception('Instructor data is empty.');
      }

      final String batchId =
          userData['batchId']?.toString().trim() ?? '';

      final String courseId =
          userData['courseId']?.toString().trim() ?? '';

      debugPrint(
        'ATTENDANCE: Instructor batchId = $batchId',
      );

      debugPrint(
        'ATTENDANCE: Instructor courseId = $courseId',
      );

      if (batchId.isEmpty) {
        throw Exception(
          'No batch is assigned to this instructor.',
        );
      }

      if (courseId.isEmpty) {
        throw Exception(
          'No course is assigned to this instructor.',
        );
      }

      _batchId = batchId;
      _courseId = courseId;

      // ----------------------------------------------------------
      // LOAD COURSE
      // ----------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>> courseDoc =
      await _firestore
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseDoc.exists) {
        final Map<String, dynamic>? courseData =
        courseDoc.data();

        _courseName =
            courseData?['title']?.toString() ??
                courseData?['name']?.toString() ??
                'Course';
      } else {
        _courseName = 'Course';
      }

      debugPrint(
        'ATTENDANCE: Course name = $_courseName',
      );

      // ----------------------------------------------------------
      // LOAD STUDENTS
      // ----------------------------------------------------------

      final List<Map<String, dynamic>> students =
      await _attendanceService.getBatchStudents(
        batchId: batchId,
      );

      _students = students;

      debugPrint(
        'ATTENDANCE: Students found = ${_students.length}',
      );

      // ----------------------------------------------------------
      // LOAD EXISTING ATTENDANCE
      // ----------------------------------------------------------

      await _loadExistingAttendance();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint(
        '❌ INSTRUCTOR ATTENDANCE LOAD ERROR: $e',
      );

      debugPrint(
        '❌ STACK TRACE: $stackTrace',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showError(
          'Unable to load attendance: ${e.toString()}',
        );
      }
    }
  }

  // ============================================================
  // LOAD EXISTING ATTENDANCE
  // ============================================================

  Future<void> _loadExistingAttendance() async {
    if (_batchId == null || _batchId!.trim().isEmpty) {
      return;
    }

    final DateTime startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final DateTime startOfNextDay =
    startOfDay.add(
      const Duration(days: 1),
    );

    debugPrint(
      'ATTENDANCE: Loading existing attendance',
    );

    debugPrint(
      'ATTENDANCE: Batch = $_batchId',
    );

    debugPrint(
      'ATTENDANCE: Date = $startOfDay',
    );

    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await _firestore
        .collection('attendance')
        .where(
      'batchId',
      isEqualTo: _batchId,
    )
        .where(
      'date',
      isGreaterThanOrEqualTo:
      Timestamp.fromDate(startOfDay),
    )
        .where(
      'date',
      isLessThan:
      Timestamp.fromDate(startOfNextDay),
    )
        .get();

    _attendanceStatus.clear();

    for (final doc in snapshot.docs) {
      final Map<String, dynamic> data =
      doc.data();

      final String studentId =
          data['studentId']?.toString() ?? '';

      final String status =
          data['status']
              ?.toString()
              .toLowerCase() ??
              '';

      if (studentId.isNotEmpty &&
          status.isNotEmpty) {
        _attendanceStatus[studentId] = status;
      }
    }

    debugPrint(
      'ATTENDANCE: Existing records = ${snapshot.docs.length}',
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });

    try {
      await _loadExistingAttendance();

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint(
        '❌ LOAD DATE ATTENDANCE ERROR: $e',
      );

      debugPrint(
        '❌ STACK TRACE: $stackTrace',
      );

      if (mounted) {
        _showError(
          'Unable to load attendance for this date: $e',
        );
      }
    }
  }

  // ============================================================
  // SET STATUS
  // ============================================================

  void _setStatus(
      String studentId,
      String status,
      ) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  // ============================================================
  // SAVE ALL ATTENDANCE
  // ============================================================

  Future<void> _saveAllAttendance() async {
    if (_batchId == null ||
        _batchId!.trim().isEmpty) {
      _showError(
        'Batch information is missing.',
      );
      return;
    }

    if (_courseId == null ||
        _courseId!.trim().isEmpty) {
      _showError(
        'Course information is missing.',
      );
      return;
    }

    if (_students.isEmpty) {
      _showError(
        'No students found in this batch.',
      );
      return;
    }

    // ----------------------------------------------------------
    // CHECK ALL STUDENTS
    // ----------------------------------------------------------

    final List<Map<String, dynamic>> missingStudents =
    _students.where(
          (student) {
        final String id =
            student['id']?.toString() ?? '';

        return id.isEmpty ||
            !_attendanceStatus.containsKey(id);
      },
    ).toList();

    if (missingStudents.isNotEmpty) {
      _showError(
        'Please mark attendance for all students.',
      );
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isSaving = true;
        });
      }

      debugPrint(
        '==================================================',
      );

      debugPrint(
        'ATTENDANCE SAVE STARTED',
      );

      debugPrint(
        'Instructor UID: ${_auth.currentUser?.uid}',
      );

      debugPrint(
        'Batch ID: $_batchId',
      );

      debugPrint(
        'Course ID: $_courseId',
      );

      debugPrint(
        'Course Name: $_courseName',
      );

      debugPrint(
        'Date: $_selectedDate',
      );

      debugPrint(
        'Students: ${_students.length}',
      );

      debugPrint(
        '==================================================',
      );

      // --------------------------------------------------------
      // SAVE EACH STUDENT
      // --------------------------------------------------------

      for (final student in _students) {
        final String studentId =
            student['id']?.toString().trim() ?? '';

        final String status =
            _attendanceStatus[studentId]
                ?.trim()
                .toLowerCase() ??
                'absent';

        debugPrint(
          'Saving attendance → '
              'student=$studentId, '
              'status=$status, '
              'batch=$_batchId',
        );

        await _attendanceService.saveAttendance(
          studentId: studentId,
          batchId: _batchId!,
          courseId: _courseId!,
          courseName: _courseName,
          date: _selectedDate,
          status: status,
        );

        debugPrint(
          '✅ Saved successfully → $studentId',
        );
      }

      debugPrint(
        '==================================================',
      );

      debugPrint(
        '✅ ALL ATTENDANCE SAVED SUCCESSFULLY',
      );

      debugPrint(
        '==================================================',
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Attendance saved successfully!',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _primaryGreen,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        '==================================================',
      );

      debugPrint(
        '❌ SAVE ATTENDANCE ERROR',
      );

      debugPrint(
        'ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      debugPrint(
        '==================================================',
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        _showError(
          'Save failed: ${e.toString()}',
        );
      }
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;

      case 'absent':
        return Colors.red;

      case 'late':
        return Colors.orange;

      case 'leave':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  String _statusLabel(String status) {
    switch (status) {
      case 'present':
        return 'Present';

      case 'absent':
        return 'Absent';

      case 'late':
        return 'Late';

      case 'leave':
        return 'Leave';

      default:
        return 'Not Marked';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F7),

      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _darkGreen,
        elevation: 0,
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: _primaryGreen,
        ),
      )
          : RefreshIndicator(
        color: _primaryGreen,
        onRefresh: _loadAttendanceData,
        child: _buildBody(),
      ),

      bottomNavigationBar:
      _students.isEmpty || _isLoading
          ? null
          : SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isSaving
                  ? null
                  : _saveAllAttendance,
              icon: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
              ),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : 'Save Attendance',
                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                _primaryGreen,
                disabledBackgroundColor:
                Colors.grey.shade400,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_students.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),

          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            'No Students Found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'No students are currently assigned '
                'to this batch.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      children: [
        _buildCourseCard(),

        const SizedBox(height: 16),

        _buildDateCard(),

        const SizedBox(height: 16),

        _buildSummaryCard(),

        const SizedBox(height: 20),

        const Text(
          'Students',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ..._students.map(
              (student) =>
              _buildStudentCard(student),
        ),
      ],
    );
  }

  // ============================================================
  // COURSE CARD
  // ============================================================

  Widget _buildCourseCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _darkGreen,
            _primaryGreen,
          ],
        ),
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.18),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assigned Course',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _courseName.isEmpty
                      ? 'Course'
                      : _courseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${_students.length} students',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE CARD
  // ============================================================

  Widget _buildDateCard() {
    return InkWell(
      onTap: _selectDate,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: _paleGreen,
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: _primaryGreen,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Date',
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDate(
                      _selectedDate,
                    ),
                    style:
                    const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.edit_calendar_outlined,
              color: _primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCard() {
    int present = 0;
    int absent = 0;
    int late = 0;
    int leave = 0;

    for (final status
    in _attendanceStatus.values) {
      switch (status) {
        case 'present':
          present++;
          break;

        case 'absent':
          absent++;
          break;

        case 'late':
          late++;
          break;

        case 'leave':
          leave++;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
            'Present',
            present,
            Colors.green,
          ),
          _summaryItem(
            'Absent',
            absent,
            Colors.red,
          ),
          _summaryItem(
            'Late',
            late,
            Colors.orange,
          ),
          _summaryItem(
            'Leave',
            leave,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      String title,
      int count,
      Color color,
      ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(
      Map<String, dynamic> student,
      ) {
    final String studentId =
        student['id']?.toString() ?? '';

    final String name =
        student['name']?.toString() ??
            'Student';

    final String email =
        student['email']?.toString() ?? '';

    final String currentStatus =
        _attendanceStatus[studentId] ?? '';

    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                _paleGreen,
                child: Text(
                  name.isNotEmpty
                      ? name[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                    color: _primaryGreen,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                          Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (currentStatus.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(
                      currentStatus,
                    ).withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(
                      currentStatus,
                    ),
                    style: TextStyle(
                      color: _statusColor(
                        currentStatus,
                      ),
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _statusButton(
                studentId,
                'present',
                'P',
                Colors.green,
              ),

              const SizedBox(width: 7),

              _statusButton(
                studentId,
                'absent',
                'A',
                Colors.red,
              ),

              const SizedBox(width: 7),

              _statusButton(
                studentId,
                'late',
                'L',
                Colors.orange,
              ),

              const SizedBox(width: 7),

              _statusButton(
                studentId,
                'leave',
                'LV',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BUTTON
  // ============================================================

  Widget _statusButton(
      String studentId,
      String status,
      String label,
      Color color,
      ) {
    final bool selected =
        _attendanceStatus[studentId] ==
            status;

    return Expanded(
      child: InkWell(
        onTap: () {
          _setStatus(
            studentId,
            status,
          );
        },
        borderRadius:
        BorderRadius.circular(10),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 180),
          height: 40,
          decoration: BoxDecoration(
            color: selected
                ? color
                : color.withOpacity(0.08),
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? color
                  : color.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : color,
                fontWeight:
                FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}