import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class InstructorStudentsScreen extends StatefulWidget {
  const InstructorStudentsScreen({super.key});

  @override
  State<InstructorStudentsScreen> createState() =>
      _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState
    extends State<InstructorStudentsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _isLoading = true;
  String _batchId = '';
  String _courseName = 'Course';

  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  // ============================================================
  // LOAD STUDENTS
  // ============================================================

  Future<void> _loadStudents() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception(
          'Instructor is not logged in.',
        );
      }

      // --------------------------------------------------------
      // INSTRUCTOR PROFILE
      // --------------------------------------------------------

      final instructorDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!instructorDoc.exists ||
          instructorDoc.data() == null) {
        throw Exception(
          'Instructor profile not found.',
        );
      }

      final instructorData =
      instructorDoc.data()!;

      final batchId =
      (instructorData['batchId'] ?? '')
          .toString();

      final courseId =
      (instructorData['courseId'] ?? '')
          .toString();

      if (batchId.isEmpty) {
        throw Exception(
          'No batch is assigned to this instructor.',
        );
      }

      // --------------------------------------------------------
      // COURSE
      // --------------------------------------------------------

      String courseName = 'Course';

      if (courseId.isNotEmpty) {
        final courseDoc = await _firestore
            .collection('courses')
            .doc(courseId)
            .get();

        if (courseDoc.exists &&
            courseDoc.data() != null) {
          final data = courseDoc.data()!;

          courseName =
              (data['title'] ??
                  data['name'] ??
                  courseId)
                  .toString();
        }
      }

      // --------------------------------------------------------
      // STUDENTS
      // --------------------------------------------------------
      //
      // Students are filtered by batchId.
      //
      // --------------------------------------------------------

      final snapshot = await _firestore
          .collection('users')
          .where(
        'role',
        isEqualTo: 'student',
      )
          .where(
        'batchId',
        isEqualTo: batchId,
      )
          .get();

      final students = snapshot.docs.map(
            (doc) {
          final data = doc.data();

          return {
            'id': doc.id,
            'name':
            (data['name'] ?? 'Student')
                .toString(),
            'email':
            (data['email'] ?? '')
                .toString(),
            'phone':
            (data['phone'] ?? '')
                .toString(),
            'city':
            (data['city'] ?? '')
                .toString(),
            'isActive':
            data['isActive'] == true,
          };
        },
      ).toList();

      students.sort(
            (a, b) => a['name']
            .toString()
            .toLowerCase()
            .compareTo(
          b['name']
              .toString()
              .toLowerCase(),
        ),
      );

      if (!mounted) return;

      setState(() {
        _batchId = batchId;
        _courseName = courseName;
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Instructor students error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Unable to load students.',
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // STUDENT DETAIL
  // ============================================================

  void _showStudentDetails(
      Map<String, dynamic> student,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      _initials(
                        student['name']
                            .toString(),
                      ),
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name']
                              .toString(),
                          style:
                          const TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        Text(
                          _courseName,
                          style:
                          const TextStyle(
                            color:
                            Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _detailRow(
                Icons.email_outlined,
                'Email',
                student['email']
                    .toString(),
              ),

              const SizedBox(height: 12),

              _detailRow(
                Icons.phone_outlined,
                'Phone',
                student['phone']
                    .toString(),
              ),

              const SizedBox(height: 12),

              _detailRow(
                Icons.location_on_outlined,
                'City',
                student['city']
                    .toString(),
              ),

              const SizedBox(height: 12),

              _detailRow(
                Icons.circle,
                'Status',
                student['isActive'] == true
                    ? 'Active'
                    : 'Inactive',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color:
          AppColors.primary,
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 65,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value.isEmpty ||
                value == 'null'
                ? 'Not available'
                : value,
            style: const TextStyle(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'));

    if (parts.isEmpty) {
      return 'S';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(
        0,
        parts.first.length >= 2
            ? 2
            : 1,
      )
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF6F8FC),

      appBar: AppBar(
        title: const Text(
          'My Students',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadStudents,
        child: _students.isEmpty
            ? _buildEmptyState()
            : ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(
            20,
          ),
          children: [
            _buildHeader(),

            const SizedBox(
              height: 16,
            ),

            ..._students.map(
              _buildStudentCard,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(18),
        color:
        const Color(0xFFE8F1FF),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_rounded,
            size: 32,
            color:
            Color(0xFF1565C0),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assigned Students',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$_courseName • $_batchId',
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                    Color(0xFF697386),
                  ),
                ),
              ],
            ),
          ),

          CircleAvatar(
            radius: 24,
            backgroundColor:
            AppColors.primary,
            child: Text(
              _students.length
                  .toString(),
              style:
              const TextStyle(
                color: Colors.white,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(
      Map<String, dynamic> student,
      ) {
    final name =
    student['name'].toString();

    final email =
    student['email'].toString();

    final isActive =
        student['isActive'] == true;

    return Card(
      elevation: 0,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        onTap: () =>
            _showStudentDetails(student),
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                const Color(
                  0xFFE8F1FF,
                ),
                child: Text(
                  _initials(name),
                  style:
                  const TextStyle(
                    color:
                    AppColors.primary,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 14),

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
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      email.isEmpty
                          ? 'Email not available'
                          : email,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 12,
                        color:
                        Color(0xFF697386),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration:
                          BoxDecoration(
                            shape:
                            BoxShape.circle,
                            color: isActive
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Text(
                          isActive
                              ? 'Active'
                              : 'Inactive',
                          style:
                          const TextStyle(
                            fontSize: 11,
                            color:
                            Color(0xFF697386),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color:
                Color(0xFF9AA3B2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(30),
      children: [
        const SizedBox(height: 100),

        Icon(
          Icons.people_outline_rounded,
          size: 72,
          color:
          Colors.grey.shade400,
        ),

        const SizedBox(height: 20),

        const Text(
          'No Students Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'There are currently no students assigned to your batch.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: OutlinedButton.icon(
            onPressed: _loadStudents,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
            const Text('Refresh'),
          ),
        ),
      ],
    );
  }
}