import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/assignment_model.dart';
import '../../../services/assignment_service.dart';

class InstructorAssignmentsScreen extends StatefulWidget {
  const InstructorAssignmentsScreen({super.key});

  @override
  State<InstructorAssignmentsScreen> createState() =>
      _InstructorAssignmentsScreenState();
}

class _InstructorAssignmentsScreenState
    extends State<InstructorAssignmentsScreen> {
  final AssignmentService _assignmentService =
      AssignmentService.instance;

  bool _isLoading = true;
  String? _errorMessage;

  String _batchId = '';
  String _courseId = '';
  String _courseName = '';

  List<AssignmentModel> _assignments = [];

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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'Instructor login required.',
        );
      }

      final DocumentSnapshot<Map<String, dynamic>>
      userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception(
          'Instructor profile not found.',
        );
      }

      final Map<String, dynamic> data =
          userDoc.data() ?? {};

      _batchId =
          data['batchId']?.toString() ?? '';

      _courseId =
          data['courseId']?.toString() ?? '';

      if (_batchId.isEmpty) {
        throw Exception(
          'Batch ID is missing from instructor profile.',
        );
      }

      if (_courseId.isEmpty) {
        throw Exception(
          'Course ID is missing from instructor profile.',
        );
      }

      await _loadCourse();

      await _loadAssignments();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // LOAD COURSE
  // ============================================================

  Future<void> _loadCourse() async {
    final DocumentSnapshot<Map<String, dynamic>>
    courseDoc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(_courseId)
        .get();

    if (courseDoc.exists) {
      final Map<String, dynamic> data =
          courseDoc.data() ?? {};

      _courseName =
          data['title']?.toString() ??
              data['name']?.toString() ??
              'My Course';
    } else {
      _courseName = 'My Course';
    }
  }

  // ============================================================
  // LOAD ASSIGNMENTS
  // ============================================================

  Future<void> _loadAssignments() async {
    final List<AssignmentModel> assignments =
    await _assignmentService
        .getAssignmentsForBatch(_batchId);

    if (!mounted) return;

    setState(() {
      _assignments = assignments;
    });
  }

  // ============================================================
  // CREATE ASSIGNMENT
  // ============================================================

  Future<void> _showCreateAssignmentDialog() async {
    final GlobalKey<FormState> formKey =
    GlobalKey<FormState>();

    final TextEditingController titleController =
    TextEditingController();

    final TextEditingController descriptionController =
    TextEditingController();

    final TextEditingController instructionsController =
    TextEditingController();

    final TextEditingController marksController =
    TextEditingController(text: '100');

    DateTime selectedDate =
    DateTime.now().add(
      const Duration(days: 7),
    );

    TimeOfDay selectedTime =
    const TimeOfDay(hour: 23, minute: 59);

    bool isQuiz = false;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Create Assignment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration:
                          const InputDecoration(
                            labelText: 'Title',
                            hintText:
                            'e.g. Flutter UI Assignment',
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller:
                          descriptionController,
                          maxLines: 3,
                          decoration:
                          const InputDecoration(
                            labelText: 'Description',
                            hintText:
                            'Assignment description',
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller:
                          instructionsController,
                          maxLines: 4,
                          decoration:
                          const InputDecoration(
                            labelText: 'Instructions',
                            hintText:
                            'What should students do?',
                            border:
                            OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: marksController,
                          keyboardType:
                          TextInputType.number,
                          decoration:
                          const InputDecoration(
                            labelText: 'Total Marks',
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final int? marks =
                            int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (marks == null ||
                                marks <= 0) {
                              return 'Enter valid marks';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ------------------------------------------------
                        // DUE DATE
                        // ------------------------------------------------

                        ListTile(
                          contentPadding:
                          EdgeInsets.zero,
                          leading: const Icon(
                            Icons.calendar_month,
                          ),
                          title: const Text(
                            'Due Date',
                          ),
                          subtitle: Text(
                            _formatDate(
                              selectedDate,
                            ),
                          ),
                          trailing:
                          const Icon(
                            Icons.chevron_right,
                          ),
                          onTap: () async {
                            final DateTime?
                            picked =
                            await showDatePicker(
                              context: context,
                              initialDate:
                              selectedDate,
                              firstDate:
                              DateTime.now(),
                              lastDate:
                              DateTime.now().add(
                                const Duration(
                                  days: 365,
                                ),
                              ),
                            );

                            if (picked != null) {
                              setDialogState(() {
                                selectedDate =
                                    picked;
                              });
                            }
                          },
                        ),

                        // ------------------------------------------------
                        // DUE TIME
                        // ------------------------------------------------

                        ListTile(
                          contentPadding:
                          EdgeInsets.zero,
                          leading: const Icon(
                            Icons.access_time,
                          ),
                          title: const Text(
                            'Due Time',
                          ),
                          subtitle: Text(
                            selectedTime.format(
                              context,
                            ),
                          ),
                          trailing:
                          const Icon(
                            Icons.chevron_right,
                          ),
                          onTap: () async {
                            final TimeOfDay?
                            picked =
                            await showTimePicker(
                              context: context,
                              initialTime:
                              selectedTime,
                            );

                            if (picked != null) {
                              setDialogState(() {
                                selectedTime =
                                    picked;
                              });
                            }
                          },
                        ),

                        SwitchListTile(
                          contentPadding:
                          EdgeInsets.zero,
                          title: const Text(
                            'Quiz',
                          ),
                          subtitle: const Text(
                            'Mark this assignment as a quiz',
                          ),
                          value: isQuiz,
                          onChanged: (value) {
                            setDialogState(() {
                              isQuiz = value;
                            });
                          },
                        ),
                      ],
                    ),
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
                    );
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final int marks =
                      int.parse(
                        marksController
                            .text
                            .trim(),
                      );

                      final DateTime dueDate =
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      await _assignmentService
                          .createAssignment(
                        batchId: _batchId,
                        courseId: _courseId,
                        title:
                        titleController.text,
                        description:
                        descriptionController
                            .text,
                        instructions:
                        instructionsController
                            .text,
                        dueDate: dueDate,
                        totalMarks: marks,
                        isQuiz: isQuiz,
                      );

                      if (!mounted) return;

                      Navigator.pop(
                        dialogContext,
                      );

                      await _loadAssignments();

                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Assignment created successfully.',
                          ),
                        ),
                      );
                    } catch (e) {
                      setDialogState(() {
                        isSaving = false;
                      });

                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Create',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    instructionsController.dispose();
    marksController.dispose();
  }

  // ============================================================
  // DELETE ASSIGNMENT
  // ============================================================

  Future<void> _deleteAssignment(
      AssignmentModel assignment,
      ) async {
    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Assignment?',
          ),
          content: Text(
            'Are you sure you want to delete "${assignment.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _assignmentService.deleteAssignment(
        assignment.id,
      );

      await _loadAssignments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Assignment deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignments',
        ),
        actions: [
          IconButton(
            onPressed: _loadInstructorData,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : _showCreateAssignmentDialog,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Create Assignment',
        ),
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
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInstructorData,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInstructorData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        children: [
          // ======================================================
          // COURSE HEADER
          // ======================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment,
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
                          'My Course',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _courseName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // ASSIGNMENT COUNT
          // ======================================================

          Text(
            '${_assignments.length} Assignment${_assignments.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // EMPTY STATE
          // ======================================================

          if (_assignments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No assignments yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first assignment for your students.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                      _showCreateAssignmentDialog,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Create Assignment',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ======================================================
          // ASSIGNMENT LIST
          // ======================================================

          ..._assignments.map(
                (assignment) =>
                _buildAssignmentCard(
                  assignment,
                ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT CARD
  // ============================================================

  Widget _buildAssignmentCard(
      AssignmentModel assignment,
      ) {
    final bool pastDue =
        assignment.isPastDue;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteAssignment(
                        assignment,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                          ),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (assignment.description
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                assignment.description,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  Icons.grade_outlined,
                  '${assignment.totalMarks} Marks',
                ),
                _infoChip(
                  Icons.calendar_today_outlined,
                  assignment.dueDate == null
                      ? 'No due date'
                      : _formatDate(
                    assignment.dueDate!,
                  ),
                ),
                if (assignment.isQuiz)
                  _infoChip(
                    Icons.quiz_outlined,
                    'Quiz',
                  ),
                if (pastDue)
                  _infoChip(
                    Icons.warning_amber_outlined,
                    'Past Due',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO CHIP
  // ============================================================

  Widget _infoChip(
      IconData icon,
      String text,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}