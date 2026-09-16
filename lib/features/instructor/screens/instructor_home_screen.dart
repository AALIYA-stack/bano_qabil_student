import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() =>
      _InstructorHomeScreenState();
}

class _InstructorHomeScreenState
    extends State<InstructorHomeScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _isLoading = true;

  String _instructorName = 'Instructor';
  String _courseName = 'Course';
  String _batchName = 'Batch';

  int _studentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInstructorData();
  }

  // ============================================================
  // LOAD INSTRUCTOR DATA
  // ============================================================

  Future<void> _loadInstructorData() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('Instructor is not logged in.');
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception(
          'Instructor profile was not found.',
        );
      }

      final userData = userDoc.data()!;

      final name =
      (userData['name'] ?? 'Instructor').toString();

      final courseId =
      (userData['courseId'] ?? '').toString();

      final batchId =
      (userData['batchId'] ?? '').toString();

      String courseName = 'Course';
      String batchName = 'Batch';
      int studentCount = 0;

      // ----------------------------------------------------------
      // COURSE
      // ----------------------------------------------------------

      if (courseId.isNotEmpty) {
        final courseDoc = await _firestore
            .collection('courses')
            .doc(courseId)
            .get();

        if (courseDoc.exists &&
            courseDoc.data() != null) {
          final courseData = courseDoc.data()!;

          courseName =
              (courseData['title'] ??
                  courseData['name'] ??
                  courseId)
                  .toString();
        }
      }

      // ----------------------------------------------------------
      // BATCH
      // ----------------------------------------------------------

      if (batchId.isNotEmpty) {
        final batchDoc = await _firestore
            .collection('batches')
            .doc(batchId)
            .get();

        if (batchDoc.exists &&
            batchDoc.data() != null) {
          final batchData = batchDoc.data()!;

          batchName =
              (batchData['name'] ??
                  batchData['title'] ??
                  batchId)
                  .toString();

          studentCount =
              _getStudentCount(batchData);
        }
      }

      if (!mounted) return;

      setState(() {
        _instructorName = name;
        _courseName = courseName;
        _batchName = batchName;
        _studentCount = studentCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Instructor dashboard error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Unable to load instructor data.',
      );
    }
  }

  // ============================================================
  // STUDENT COUNT
  // ============================================================

  int _getStudentCount(
      Map<String, dynamic> batchData,
      ) {
    final enrolled =
    batchData['enrolledStudents'];

    if (enrolled is int) {
      return enrolled;
    }

    if (enrolled is num) {
      return enrolled.toInt();
    }

    return 0;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // OPEN ATTENDANCE
  // ============================================================

  void _openAttendance() {
    Navigator.pushNamed(
      context,
      AppRoutes.instructorAttendance,
    );
  }

  // ============================================================
  // OPEN STUDENTS
  // ============================================================

  void _openStudents() {
    Navigator.pushNamed(
      context,
      AppRoutes.instructorStudents,
    );
  }

  // ============================================================
  // OPEN ASSIGNMENTS
  // ============================================================

  void _openAssignments() {
    Navigator.pushNamed(
      context,
      AppRoutes.instructorAssignments,
    );
  }

  // ============================================================
  // OPEN MARKS
  // ============================================================

  void _openMarks() {
    Navigator.pushNamed(
      context,
      AppRoutes.instructorMarks,
    );
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
          'Instructor Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadInstructorData,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(20),
          children: [
            _buildWelcomeCard(),

            const SizedBox(height: 20),

            _buildSectionTitle(
              'Your Teaching Overview',
            ),

            const SizedBox(height: 12),

            _buildStatsGrid(),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Quick Actions',
            ),

            const SizedBox(height: 12),

            _buildQuickActions(),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Assigned Batch',
            ),

            const SizedBox(height: 12),

            _buildBatchCard(),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Upcoming Class',
            ),

            const SizedBox(height: 12),

            _buildUpcomingClass(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF54C015),
            Color(0xFF84F542),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _instructorName,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _courseName,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF172033),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildStatCard(
          icon: Icons.people_alt_rounded,
          title: 'Students',
          value: _studentCount.toString(),
        ),

        _buildStatCard(
          icon: Icons.menu_book_rounded,
          title: 'Course',
          value: '1',
        ),

        _buildStatCard(
          icon: Icons.groups_rounded,
          title: 'Batch',
          value: _batchName
              .replaceAll('batch', '')
              .trim(),
        ),

        _buildStatCard(
          icon: Icons.calendar_month_rounded,
          title: 'Classes',
          value: '3 / week',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
              const Color(0xFF1565C0),
              size: 25,
            ),

            const Spacer(),

            Text(
              value,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: const TextStyle(
                color:
                Color(0xFF697386),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon:
                Icons.fact_check_rounded,
                title: 'Attendance',
                subtitle:
                'Mark attendance',
                onTap: _openAttendance,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                icon:
                Icons.people_alt_rounded,
                title: 'Students',
                subtitle:
                'View students',
                onTap: _openStudents,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon:
                Icons.assignment_rounded,
                title: 'Assignments',
                subtitle:
                'Manage work',
                onTap: _openAssignments,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                icon:
                Icons.grade_rounded,
                title: 'Marks',
                subtitle:
                'Marks & feedback',
                onTap: _openMarks,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE8F1FF,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  const Color(0xFF6DC015),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color:
                  Color(0xFF697386),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BATCH CARD
  // ============================================================

  Widget _buildBatchCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color:
                const Color(0xFFE8F1FF),
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color:
                Color(0xFF1BC015),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    _batchName,
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _courseName,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF697386),
                    ),
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
    );
  }

  // ============================================================
  // UPCOMING CLASS
  // ============================================================

  Widget _buildUpcomingClass() {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                    const Color(
                      0xFFE8F1FF,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color:
                    AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Class',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                          Color(0xFF697386),
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Monday • 5:00 PM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.room_rounded,
                  size: 20,
                  color:
                  Color(0xFF697386),
                ),

                const SizedBox(width: 8),

                const Text(
                  'Lab 1',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  _batchName,
                  style: const TextStyle(
                    color:
                    Color(0xFF697386),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}