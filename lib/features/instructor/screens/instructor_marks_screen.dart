import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/collection_names.dart';
import '../../../models/assignment_model.dart';
import '../../../models/submission_model.dart';
import '../../../services/assignment_service.dart';
import '../../../services/submission_service.dart';

class InstructorMarksScreen extends StatefulWidget {
  const InstructorMarksScreen({super.key});

  @override
  State<InstructorMarksScreen> createState() =>
      _InstructorMarksScreenState();
}

class _InstructorMarksScreenState
    extends State<InstructorMarksScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AssignmentService _assignmentService =
      AssignmentService.instance;

  final SubmissionService _submissionService =
      SubmissionService.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GREEN INSTRUCTOR THEME
  // ============================================================

  static const Color _primaryGreen =
  Color(0xFF78DA37);

  static const Color _lightGreen =
  Color(0xFF30D12A);

  static const Color _paleGreen =
  Color(0xA32ECD3B);

  static const Color _darkGreen =
  Color(0xA32EC53A);

  // ============================================================
  // STATE
  // ============================================================

  String? _batchId;
  String? _courseId;

  String _courseName = 'Course';

  bool _isLoading = true;

  String? _errorMessage;

  List<AssignmentModel> _assignments =
  <AssignmentModel>[];

  AssignmentModel? _selectedAssignment;

  List<SubmissionModel> _submissions =
  <SubmissionModel>[];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadInstructorData();
  }

  // ============================================================
  // LOAD INSTRUCTOR DATA
  // ============================================================

  Future<void> _loadInstructorData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final user = _submissionService.currentUser;

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore
          .collection(CollectionNames.users)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(
          'Instructor profile not found.',
        );
      }

      final Map<String, dynamic> data =
          userDoc.data() ?? <String, dynamic>{};

      final String batchId =
          data['batchId']?.toString().trim() ?? '';

      final String courseId =
          data['courseId']?.toString().trim() ?? '';

      if (batchId.isEmpty) {
        throw Exception(
          'Instructor batch is not assigned.',
        );
      }

      if (courseId.isEmpty) {
        throw Exception(
          'Instructor course is not assigned.',
        );
      }

      _batchId = batchId;
      _courseId = courseId;

      await _loadCourse(courseId);

      await _loadAssignments(batchId);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  // ============================================================
  // LOAD COURSE
  // ============================================================

  Future<void> _loadCourse(
      String courseId,
      ) async {
    final DocumentSnapshot<Map<String, dynamic>> courseDoc =
    await _firestore
        .collection(CollectionNames.courses)
        .doc(courseId)
        .get();

    if (!courseDoc.exists) {
      _courseName = 'Course';
      return;
    }

    final Map<String, dynamic> data =
        courseDoc.data() ?? <String, dynamic>{};

    _courseName =
        data['title']?.toString() ??
            data['name']?.toString() ??
            'Course';
  }

  // ============================================================
  // LOAD ASSIGNMENTS
  // ============================================================

  Future<void> _loadAssignments(
      String batchId,
      ) async {
    final List<AssignmentModel> assignments =
    await _assignmentService
        .getAssignmentsForBatch(batchId);

    _assignments = assignments;

    if (assignments.isEmpty) {
      _selectedAssignment = null;
      _submissions = <SubmissionModel>[];
      return;
    }

    _selectedAssignment = assignments.first;

    await _loadSubmissions(
      assignments.first.id,
    );
  }

  // ============================================================
  // LOAD SUBMISSIONS
  // ============================================================

  Future<void> _loadSubmissions(
      String assignmentId,
      ) async {
    final List<SubmissionModel> submissions =
    await _submissionService
        .getSubmissionsForAssignment(
      assignmentId,
    );

    if (!mounted) return;

    setState(() {
      _submissions = submissions;
    });
  }

  // ============================================================
  // SELECT ASSIGNMENT
  // ============================================================

  Future<void> _selectAssignment(
      AssignmentModel assignment,
      ) async {
    if (_selectedAssignment?.id == assignment.id) {
      return;
    }

    setState(() {
      _selectedAssignment = assignment;
      _submissions = <SubmissionModel>[];
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadSubmissions(
        assignment.id,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  // ============================================================
  // OPEN MARK / EDIT DIALOG
  // ============================================================

  Future<void> _openMarkDialog(
      SubmissionModel submission,
      ) async {
    final AssignmentModel? assignment =
        _selectedAssignment;

    if (assignment == null) {
      return;
    }

    final TextEditingController marksController =
    TextEditingController(
      text: submission.marks?.toString() ?? '',
    );

    final TextEditingController feedbackController =
    TextEditingController(
      text: submission.feedback ?? '',
    );

    final GlobalKey<FormState> formKey =
    GlobalKey<FormState>();

    final bool isEditing =
        submission.isMarked;

    final bool? saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: _paleGreen,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.grade_rounded,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Edit Marks'
                          : 'Add Marks',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // ASSIGNMENT
                      // ------------------------------------------------

                      Text(
                        assignment.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Total Marks: ${assignment.totalMarks}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------------
                      // MARKS
                      // ------------------------------------------------

                      TextFormField(
                        controller: marksController,
                        keyboardType:
                        TextInputType.number,
                        autofocus: !isEditing,
                        decoration:
                        InputDecoration(
                          labelText: 'Marks',
                          hintText:
                          'Enter marks',
                          prefixIcon:
                          const Icon(
                            Icons.grade_rounded,
                            color: _primaryGreen,
                          ),
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                            borderSide:
                            const BorderSide(
                              color: _primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final String text =
                              value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Enter marks';
                          }

                          final int? marks =
                          int.tryParse(text);

                          if (marks == null) {
                            return 'Enter valid marks';
                          }

                          if (marks < 0) {
                            return 'Marks cannot be negative';
                          }

                          if (marks >
                              assignment.totalMarks) {
                            return 'Maximum is '
                                '${assignment.totalMarks}';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // FEEDBACK
                      // ------------------------------------------------

                      TextFormField(
                        controller:
                        feedbackController,
                        maxLines: 4,
                        decoration:
                        InputDecoration(
                          labelText: 'Feedback',
                          hintText:
                          'Write feedback for student...',
                          prefixIcon:
                          const Icon(
                            Icons.feedback_rounded,
                            color: _primaryGreen,
                          ),
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                            borderSide:
                            const BorderSide(
                              color: _primaryGreen,
                              width: 2,
                            ),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    _primaryGreen,
                    foregroundColor:
                    Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    final int marks =
                    int.parse(
                      marksController.text
                          .trim(),
                    );

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      // ==========================================
                      // UPDATE EXISTING SUBMISSION
                      // ==========================================

                      await _submissionService
                          .markSubmission(
                        submissionId:
                        submission.id,
                        marks: marks,
                        feedback:
                        feedbackController
                            .text
                            .trim(),
                      );

                      if (!dialogContext
                          .mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        true,
                      );
                    } catch (e) {
                      if (!dialogContext
                          .mounted) {
                        return;
                      }

                      setDialogState(() {
                        isSaving = false;
                      });

                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        SnackBar(
                          backgroundColor:
                          Colors.red.shade700,
                          content: Text(
                            _cleanError(e),
                          ),
                        ),
                      );
                    }
                  },
                  icon: isSaving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    isEditing
                        ? Icons.save_rounded
                        : Icons.check_rounded,
                  ),
                  label: Text(
                    isEditing
                        ? 'Update Marks'
                        : 'Save Marks',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    marksController.dispose();
    feedbackController.dispose();

    // ============================================================
    // REFRESH AFTER SAVE
    // ============================================================

    if (saved == true) {
      await _loadSubmissions(
        assignment.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _primaryGreen,
          content: Text(
            isEditing
                ? 'Marks and feedback updated successfully.'
                : 'Marks and feedback saved successfully.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // STUDENT NAME
  // ============================================================

  Future<String> _getStudentName(
      String studentId,
      ) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore
          .collection(CollectionNames.users)
          .doc(studentId)
          .get();

      if (!doc.exists) {
        return 'Student';
      }

      final Map<String, dynamic> data =
          doc.data() ?? <String, dynamic>{};

      return data['name']?.toString() ??
          data['displayName']?.toString() ??
          data['email']?.toString() ??
          'Student';
    } catch (_) {
      return 'Student';
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    if (_batchId == null) {
      await _loadInstructorData();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedAssignment == null) {
        await _loadAssignments(
          _batchId!,
        );
      } else {
        await _loadSubmissions(
          _selectedAssignment!.id,
        );
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    final String text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.replaceFirst(
        'Exception: ',
        '',
      );
    }

    return text;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Marks & Feedback',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryGreen,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: _refresh,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildCourseHeader(),

          const SizedBox(height: 20),

          _buildAssignmentSection(),

          const SizedBox(height: 20),

          _buildSubmissionSection(),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE HEADER
  // ============================================================

  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            _darkGreen,
            _lightGreen,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.18),
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.grade_rounded,
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
                  'Marks & Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _courseName,
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.85),
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
  // ASSIGNMENT SECTION
  // ============================================================

  Widget _buildAssignmentSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Assignment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        if (_assignments.isEmpty)
          _buildNoAssignments()
        else
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _paleGreen,
                width: 1.5,
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child:
            DropdownButtonHideUnderline(
              child: DropdownButton<
                  AssignmentModel>(
                value: _selectedAssignment,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _primaryGreen,
                ),
                items: _assignments
                    .map(
                      (assignment) =>
                      DropdownMenuItem<
                          AssignmentModel>(
                        value: assignment,
                        child: Text(
                          assignment.title,
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                )
                    .toList(),
                onChanged: (assignment) {
                  if (assignment == null) {
                    return;
                  }

                  _selectAssignment(
                    assignment,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // SUBMISSION SECTION
  // ============================================================

  Widget _buildSubmissionSection() {
    if (_selectedAssignment == null) {
      return _buildSelectAssignmentMessage();
    }

    if (_submissions.isEmpty) {
      return _buildNoSubmissions();
    }

    final int markedCount =
        _submissions
            .where(
              (submission) =>
          submission.isMarked,
        )
            .length;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Student Submissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _paleGreen,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                '$markedCount/${_submissions.length} marked',
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ..._submissions.map(
              (submission) =>
              _buildSubmissionCard(
                submission,
              ),
        ),
      ],
    );
  }

  // ============================================================
  // SUBMISSION CARD
  // ============================================================

  Widget _buildSubmissionCard(
      SubmissionModel submission,
      ) {
    return FutureBuilder<String>(
      future: _getStudentName(
        submission.studentId,
      ),
      builder: (
          context,
          snapshot,
          ) {
        final String studentName =
            snapshot.data ?? 'Student';

        final bool marked =
            submission.isMarked;

        return Container(
          margin:
          const EdgeInsets.only(
            bottom: 12,
          ),
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: marked
                  ? _paleGreen
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.04),
                blurRadius: 10,
                offset:
                const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // STUDENT HEADER
              // --------------------------------------------------

              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                    _paleGreen,
                    foregroundColor:
                    _darkGreen,
                    child: Text(
                      studentName.isNotEmpty
                          ? studentName[0]
                          .toUpperCase()
                          : 'S',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
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
                          studentName,
                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDate(
                            submission
                                .submittedAt,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildStatusChip(
                    submission,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // ANSWER
              // --------------------------------------------------

              if (submission.answerText
                  .trim()
                  .isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Text(
                    submission.answerText,
                    maxLines: 4,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ),

              // --------------------------------------------------
              // FILE
              // --------------------------------------------------

              if (submission.fileName !=
                  null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _paleGreen,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_file_rounded,
                        size: 19,
                        color: _primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          submission.fileName!,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,
                            color: _darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // --------------------------------------------------
              // MARKS / EDIT
              // --------------------------------------------------

              Row(
                children: [
                  if (marked)
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${submission.marks ?? 0}/${_selectedAssignment?.totalMarks ?? 0}',
                            style:
                            const TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.w800,
                              color: _darkGreen,
                            ),
                          ),
                          if (submission
                              .feedback !=
                              null &&
                              submission.feedback!
                                  .trim()
                                  .isNotEmpty)
                            Text(
                              submission.feedback!,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors
                                    .grey.shade700,
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    const Expanded(
                      child: Text(
                        'Not marked yet',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(width: 10),

                  FilledButton.icon(
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      _primaryGreen,
                      foregroundColor:
                      Colors.white,
                    ),
                    onPressed: () =>
                        _openMarkDialog(
                          submission,
                        ),
                    icon: Icon(
                      marked
                          ? Icons.edit_rounded
                          : Icons.grade_rounded,
                      size: 18,
                    ),
                    label: Text(
                      marked
                          ? 'Edit'
                          : 'Mark',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(
      SubmissionModel submission,
      ) {
    String text;
    IconData icon;
    Color backgroundColor;
    Color foregroundColor;

    if (submission.isMarked) {
      text = 'Marked';
      icon = Icons.check_circle_rounded;
      backgroundColor = Colors.green.shade50;
      foregroundColor = Colors.green.shade700;
    } else if (submission.isLate) {
      text = 'Late';
      icon = Icons.schedule_rounded;
      backgroundColor = Colors.orange.shade50;
      foregroundColor = Colors.orange.shade700;
    } else {
      text = 'Submitted';
      icon = Icons.upload_file_rounded;
      backgroundColor = _paleGreen;
      foregroundColor = _darkGreen;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO ASSIGNMENTS
  // ============================================================

  Widget _buildNoAssignments() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _paleGreen,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 42,
            color: _primaryGreen,
          ),
          SizedBox(height: 10),
          Text(
            'No assignments found',
            style: TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create an assignment first.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO SUBMISSIONS
  // ============================================================

  Widget _buildNoSubmissions() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _paleGreen,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: _primaryGreen,
          ),
          SizedBox(height: 12),
          Text(
            'No submissions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Students have not submitted this assignment yet.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECT ASSIGNMENT MESSAGE
  // ============================================================

  Widget _buildSelectAssignmentMessage() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _paleGreen,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Text(
        'Select an assignment to view submissions.',
        textAlign: TextAlign.center,
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: Colors.red.shade600,
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load marks',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              style:
              FilledButton.styleFrom(
                backgroundColor:
                _primaryGreen,
              ),
              onPressed:
              _loadInstructorData,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
              const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
      DateTime? date,
      ) {
    if (date == null) {
      return 'Submission date unavailable';
    }

    final String day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    final String month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final String year =
    date.year.toString();

    final String hour =
    date.hour.toString().padLeft(
      2,
      '0',
    );

    final String minute =
    date.minute.toString().padLeft(
      2,
      '0',
    );

    return '$day/$month/$year • $hour:$minute';
  }
}