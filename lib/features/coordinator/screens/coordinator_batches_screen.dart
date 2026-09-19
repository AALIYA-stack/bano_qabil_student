import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../models/batch_model.dart';
import '../../../models/campus_model.dart';
import '../../../models/course_model.dart';
import '../../../services/campus_service.dart';
import '../../../services/course_service.dart';
import '../services/coordinator_batch_service.dart';
import '../services/coordinator_instructor_service.dart';

class CoordinatorBatchesScreen extends StatefulWidget {
  const CoordinatorBatchesScreen({super.key});

  @override
  State<CoordinatorBatchesScreen> createState() =>
      _CoordinatorBatchesScreenState();
}

class _CoordinatorBatchesScreenState
    extends State<CoordinatorBatchesScreen> {
  final CoordinatorBatchService _batchService =
      CoordinatorBatchService.instance;

  final CoordinatorInstructorService _instructorService =
      CoordinatorInstructorService.instance;

  final CourseService _courseService =
      CourseService.instance;

  final CampusService _campusService =
      CampusService.instance;

  final TextEditingController _searchController =
  TextEditingController();

  List<BatchModel> _batches = [];
  List<Map<String, dynamic>> _instructors = [];
  List<CourseModel> _courses = [];
  List<CampusModel> _campuses = [];

  bool _isLoading = true;
  String _searchQuery = '';

  static const List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // ----------------------------------------------------------
    // BATCHES
    // ----------------------------------------------------------

    try {
      final batches = await _batchService.getBatches();

      if (mounted) {
        setState(() {
          _batches = batches;
        });
      }

      debugPrint(
        'COORDINATOR BATCH DEBUG: ${batches.length} batches loaded',
      );
    } catch (e) {
      debugPrint(
        'COORDINATOR BATCH ERROR: $e',
      );
    }

    // ----------------------------------------------------------
    // INSTRUCTORS
    // ----------------------------------------------------------

    try {
      final instructors =
      await _instructorService.getInstructors();

      if (mounted) {
        setState(() {
          _instructors = instructors;
        });
      }

      debugPrint(
        'COORDINATOR INSTRUCTOR DEBUG: '
            '${instructors.length} instructors loaded',
      );
    } catch (e) {
      debugPrint(
        'COORDINATOR INSTRUCTOR ERROR: $e',
      );
    }

    // ----------------------------------------------------------
    // COURSES
    // ----------------------------------------------------------

    try {
      final courses =
      await _courseService.getActiveCourses();

      if (mounted) {
        setState(() {
          _courses = courses;
        });
      }

      debugPrint(
        'COORDINATOR COURSE DEBUG: '
            '${courses.length} courses loaded',
      );
    } catch (e) {
      debugPrint(
        'COORDINATOR COURSE ERROR: $e',
      );
    }

    // ----------------------------------------------------------
    // CAMPUSES
    // ----------------------------------------------------------

    try {
      final campuses =
      await _campusService.getActiveCampuses();

      if (mounted) {
        setState(() {
          _campuses = campuses;
        });
      }

      debugPrint(
        'COORDINATOR CAMPUS DEBUG: '
            '${campuses.length} campuses loaded',
      );
    } catch (e) {
      debugPrint(
        'COORDINATOR CAMPUS ERROR: $e',
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _courseId(CourseModel course) {
    return course.id;
  }

  String _courseName(CourseModel course) {
    return course.name;
  }

  String _campusId(CampusModel campus) {
    return campus.id;
  }

  String _campusName(CampusModel campus) {
    return campus.name;
  }

  CourseModel? _findCourse(String courseId) {
    final id = courseId.trim();

    if (id.isEmpty) {
      return null;
    }

    for (final course in _courses) {
      if (_courseId(course).trim() == id) {
        return course;
      }
    }

    return null;
  }

  CampusModel? _findCampus(String campusId) {
    final id = campusId.trim();

    if (id.isEmpty) {
      return null;
    }

    for (final campus in _campuses) {
      if (_campusId(campus).trim() == id) {
        return campus;
      }
    }

    return null;
  }

  Map<String, dynamic>? _findInstructor(
      String instructorId,
      ) {
    final id = instructorId.trim();

    if (id.isEmpty) {
      return null;
    }

    for (final instructor in _instructors) {
      final value =
          instructor['id']?.toString().trim() ?? '';

      if (value == id) {
        return instructor;
      }
    }

    return null;
  }

  String _instructorName(String instructorId) {
    final id = instructorId.trim();

    if (id.isEmpty) {
      return 'Not assigned';
    }

    final instructor = _findInstructor(id);

    if (instructor == null) {
      return 'Instructor unavailable';
    }

    final name =
        instructor['name']?.toString().trim() ?? '';

    if (name.isNotEmpty) {
      return name;
    }

    final email =
        instructor['email']?.toString().trim() ?? '';

    if (email.isNotEmpty) {
      return email;
    }

    return 'Instructor';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not set';
    }

    return DateFormat('dd MMM yyyy').format(date);
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('FirebaseException: ', '');
  }

  void _showSnackBar(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          isError ? Colors.red.shade700 : null,
        ),
      );
  }

  // ============================================================
  // CLASS DAY HELPERS
  // ============================================================

  Set<String> _parseClassDays(String value) {
    final result = <String>{};

    if (value.trim().isEmpty) {
      return result;
    }

    final parts = value
        .split(',')
        .map((day) => day.trim())
        .where((day) => day.isNotEmpty);

    for (final day in parts) {
      if (_allDays.contains(day)) {
        result.add(day);
      }
    }

    return result;
  }

  String _classDaysToString(Set<String> days) {
    return _allDays
        .where((day) => days.contains(day))
        .join(', ');
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<BatchModel> get _filteredBatches {
    final query =
    _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List<BatchModel>.from(_batches);
    }

    return _batches.where((batch) {
      final course =
      _findCourse(batch.courseId);

      final campus =
      _findCampus(batch.campusId);

      final instructor =
      _findInstructor(batch.instructorId);

      final searchableText = [
        batch.id,
        batch.courseId,
        course != null
            ? _courseName(course)
            : '',
        batch.campusId,
        campus != null
            ? _campusName(campus)
            : '',
        batch.classDay,
        batch.classTime,
        batch.room,
        batch.instructorId,
        instructor?['name']
            ?.toString() ??
            '',
        instructor?['email']
            ?.toString() ??
            '',
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // ============================================================
  // CREATE / EDIT BATCH
  // ============================================================

  Future<void> _showBatchDialog({
    BatchModel? existingBatch,
  }) async {
    String? selectedCourseId =
    existingBatch?.courseId.trim();

    String? selectedCampusId =
    existingBatch?.campusId.trim();

    String classTime =
        existingBatch?.classTime.trim() ?? '';

    String room =
        existingBatch?.room.trim() ?? '';

    int seats =
        existingBatch?.seats ?? 30;

    int enrolledStudents =
        existingBatch?.enrolledStudents ?? 0;

    bool isOpen =
        existingBatch?.isOpen ?? true;

    DateTime? startDate =
        existingBatch?.startDate;

    // ----------------------------------------------------------
    // FIX:
    // Existing Firebase values can be:
    // Monday, Wednesday, Friday
    // Tuesday, Thursday, Saturday
    //
    // So we use a Set instead of a single dropdown value.
    // ----------------------------------------------------------

    final selectedDays = <String>{};

    if (existingBatch != null) {
      selectedDays.addAll(
        _parseClassDays(
          existingBatch.classDay,
        ),
      );
    }

    if (selectedDays.isEmpty) {
      selectedDays.add('Monday');
    }

    // ----------------------------------------------------------
    // Safety for inactive/missing course
    // ----------------------------------------------------------

    if (selectedCourseId != null &&
        !_courses.any(
              (course) =>
          _courseId(course) ==
              selectedCourseId,
        )) {
      selectedCourseId = null;
    }

    // ----------------------------------------------------------
    // Safety for inactive/missing campus
    // ----------------------------------------------------------

    if (selectedCampusId != null &&
        !_campuses.any(
              (campus) =>
          _campusId(campus) ==
              selectedCampusId,
        )) {
      selectedCampusId = null;
    }

    final formKey =
    GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            Future<void> saveBatch() async {
              final form =
                  formKey.currentState;

              if (form == null) {
                return;
              }

              if (!form.validate()) {
                return;
              }

              final courseId =
                  selectedCourseId?.trim() ?? '';

              final campusId =
                  selectedCampusId?.trim() ?? '';

              if (courseId.isEmpty) {
                _showSnackBar(
                  'Please select a course.',
                  isError: true,
                );
                return;
              }

              if (campusId.isEmpty) {
                _showSnackBar(
                  'Please select a campus.',
                  isError: true,
                );
                return;
              }

              if (selectedDays.isEmpty) {
                _showSnackBar(
                  'Please select at least one class day.',
                  isError: true,
                );
                return;
              }

              if (classTime.trim().isEmpty) {
                _showSnackBar(
                  'Please enter class time.',
                  isError: true,
                );
                return;
              }

              if (room.trim().isEmpty) {
                _showSnackBar(
                  'Please enter room.',
                  isError: true,
                );
                return;
              }

              if (seats <= 0) {
                _showSnackBar(
                  'Total seats must be greater than 0.',
                  isError: true,
                );
                return;
              }

              if (enrolledStudents < 0) {
                _showSnackBar(
                  'Enrolled students cannot be negative.',
                  isError: true,
                );
                return;
              }

              if (enrolledStudents > seats) {
                _showSnackBar(
                  'Enrolled students cannot exceed total seats.',
                  isError: true,
                );
                return;
              }

              setDialogState(() {
                saving = true;
              });

              try {
                final classDay =
                _classDaysToString(
                  selectedDays,
                );

                // ------------------------------------------------
                // CREATE
                // ------------------------------------------------

                if (existingBatch == null) {
                  await _batchService.createBatch(
                    courseId: courseId,
                    campusId: campusId,
                    instructorId: '',
                    classDay: classDay,
                    classTime: classTime.trim(),
                    room: room.trim(),
                    startDate: startDate,
                    seats: seats,
                    enrolledStudents:
                    enrolledStudents,
                    isOpen: isOpen,
                  );
                }

                // ------------------------------------------------
                // UPDATE
                // ------------------------------------------------

                else {
                  await _batchService.updateBatch(
                    batchId: existingBatch.id,
                    courseId: courseId,
                    campusId: campusId,
                    instructorId:
                    existingBatch.instructorId,
                    classDay: classDay,
                    classTime: classTime.trim(),
                    room: room.trim(),
                    startDate: startDate,
                    seats: seats,
                    enrolledStudents:
                    enrolledStudents,
                    isOpen: isOpen,
                  );
                }

                if (dialogContext.mounted) {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                }

                await _loadData();

                _showSnackBar(
                  existingBatch == null
                      ? 'Batch created successfully.'
                      : 'Batch updated successfully.',
                );
              } catch (e) {
                if (!context.mounted) {
                  return;
                }

                setDialogState(() {
                  saving = false;
                });

                _showSnackBar(
                  'Unable to save batch: '
                      '${_cleanError(e)}',
                  isError: true,
                );
              }
            }

            return AlertDialog(
              title: Text(
                existingBatch == null
                    ? 'Create New Batch'
                    : 'Edit Batch',
              ),

              content: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 520,
                ),
                child: SizedBox(
                  width: 520,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          // ==================================================
                          // COURSE
                          // ==================================================

                          DropdownButtonFormField<String>(
                            initialValue:
                            selectedCourseId,
                            isExpanded: true,
                            decoration:
                            const InputDecoration(
                              labelText: 'Course',
                              prefixIcon: Icon(
                                Icons.school_outlined,
                              ),
                              border:
                              OutlineInputBorder(),
                            ),
                            items:
                            _courses.map(
                                  (course) {
                                final id =
                                _courseId(course);

                                return DropdownMenuItem<
                                    String>(
                                  value: id,
                                  child: Text(
                                    _courseName(
                                      course,
                                    ),
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: saving
                                ? null
                                : (value) {
                              setDialogState(
                                    () {
                                  selectedCourseId =
                                      value;
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please select a course';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // CAMPUS
                          // ==================================================

                          DropdownButtonFormField<String>(
                            initialValue:
                            selectedCampusId,
                            isExpanded: true,
                            decoration:
                            const InputDecoration(
                              labelText: 'Campus',
                              prefixIcon: Icon(
                                Icons
                                    .location_on_outlined,
                              ),
                              border:
                              OutlineInputBorder(),
                            ),
                            items:
                            _campuses.map(
                                  (campus) {
                                final id =
                                _campusId(campus);

                                return DropdownMenuItem<
                                    String>(
                                  value: id,
                                  child: Text(
                                    _campusName(
                                      campus,
                                    ),
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: saving
                                ? null
                                : (value) {
                              setDialogState(
                                    () {
                                  selectedCampusId =
                                      value;
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please select a campus';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // CLASS DAYS
                          // ==================================================

                          Align(
                            alignment:
                            Alignment.centerLeft,
                            child: Text(
                              'Class Days',
                              style:
                              Theme.of(
                                context,
                              )
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Container(
                            width: double.infinity,
                            decoration:
                            BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey
                                    .shade300,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                12,
                              ),
                            ),
                            child: Column(
                              children:
                              _allDays.map(
                                    (day) {
                                  final checked =
                                  selectedDays
                                      .contains(
                                    day,
                                  );

                                  return CheckboxListTile(
                                    dense: true,
                                    contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 12,
                                    ),
                                    title: Text(day),
                                    value: checked,
                                    onChanged:
                                    saving
                                        ? null
                                        : (value) {
                                      setDialogState(
                                            () {
                                          if (value ==
                                              true) {
                                            selectedDays
                                                .add(
                                              day,
                                            );
                                          } else {
                                            // At least one
                                            // day must remain.
                                            if (selectedDays
                                                .length >
                                                1) {
                                              selectedDays
                                                  .remove(
                                                day,
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets
                                .all(
                              10,
                            ),
                            decoration:
                            BoxDecoration(
                              color: Colors
                                  .grey
                                  .shade100,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                8,
                              ),
                            ),
                            child: Text(
                              'Selected: '
                                  '${_classDaysToString(selectedDays)}',
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // CLASS TIME
                          // ==================================================

                          TextFormField(
                            initialValue:
                            classTime,
                            enabled: !saving,
                            decoration:
                            const InputDecoration(
                              labelText:
                              'Class Time',
                              hintText:
                              'e.g. 5:00 PM - 7:00 PM',
                              prefixIcon:
                              Icon(
                                Icons
                                    .access_time_outlined,
                              ),
                              border:
                              OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              classTime = value;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter class time';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // ROOM
                          // ==================================================

                          TextFormField(
                            initialValue: room,
                            enabled: !saving,
                            decoration:
                            const InputDecoration(
                              labelText: 'Room',
                              hintText:
                              'e.g. Lab 1',
                              prefixIcon:
                              Icon(
                                Icons
                                    .meeting_room_outlined,
                              ),
                              border:
                              OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              room = value;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter room';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // START DATE
                          // ==================================================

                          InkWell(
                            onTap: saving
                                ? null
                                : () async {
                              final selected =
                              await showDatePicker(
                                context:
                                context,
                                initialDate:
                                startDate ??
                                    DateTime
                                        .now(),
                                firstDate:
                                DateTime(
                                  2020,
                                ),
                                lastDate:
                                DateTime(
                                  2100,
                                ),
                              );

                              if (selected !=
                                  null) {
                                setDialogState(
                                      () {
                                    startDate =
                                        selected;
                                  },
                                );
                              }
                            },
                            child:
                            InputDecorator(
                              decoration:
                              const InputDecoration(
                                labelText:
                                'Start Date',
                                prefixIcon:
                                Icon(
                                  Icons
                                      .event_outlined,
                                ),
                                border:
                                OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatDate(
                                  startDate,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // SEATS
                          // ==================================================

                          Row(
                            children: [
                              Expanded(
                                child:
                                TextFormField(
                                  initialValue:
                                  seats
                                      .toString(),
                                  enabled:
                                  !saving,
                                  keyboardType:
                                  TextInputType
                                      .number,
                                  decoration:
                                  const InputDecoration(
                                    labelText:
                                    'Total Seats',
                                    prefixIcon:
                                    Icon(
                                      Icons
                                          .groups_outlined,
                                    ),
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                  onChanged:
                                      (value) {
                                    seats =
                                        int.tryParse(
                                          value,
                                        ) ??
                                            0;
                                  },
                                  validator:
                                      (value) {
                                    final number =
                                    int.tryParse(
                                      value ?? '',
                                    );

                                    if (number ==
                                        null ||
                                        number <=
                                            0) {
                                      return 'Invalid';
                                    }

                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child:
                                TextFormField(
                                  initialValue:
                                  enrolledStudents
                                      .toString(),
                                  enabled:
                                  !saving,
                                  keyboardType:
                                  TextInputType
                                      .number,
                                  decoration:
                                  const InputDecoration(
                                    labelText:
                                    'Enrolled',
                                    prefixIcon:
                                    Icon(
                                      Icons
                                          .person_outline,
                                    ),
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                  onChanged:
                                      (value) {
                                    enrolledStudents =
                                        int.tryParse(
                                          value,
                                        ) ??
                                            0;
                                  },
                                  validator:
                                      (value) {
                                    final number =
                                    int.tryParse(
                                      value ?? '',
                                    );

                                    if (number ==
                                        null ||
                                        number < 0) {
                                      return 'Invalid';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          // ==================================================
                          // OPEN / CLOSED
                          // ==================================================

                          SwitchListTile(
                            contentPadding:
                            EdgeInsets.zero,
                            title:
                            const Text(
                              'Batch Open',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                            subtitle: Text(
                              isOpen
                                  ? 'Students can apply/enroll'
                                  : 'Applications are closed',
                            ),
                            value: isOpen,
                            onChanged: saving
                                ? null
                                : (value) {
                              setDialogState(
                                    () {
                                  isOpen =
                                      value;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // ACTIONS
              // ==================================================

              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                  const Text('Cancel'),
                ),

                FilledButton.icon(
                  onPressed:
                  saving ? null : saveBatch,
                  icon: saving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons
                        .save_outlined,
                  ),
                  label: Text(
                    saving
                        ? 'Saving...'
                        : existingBatch == null
                        ? 'Create'
                        : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ASSIGN / CHANGE INSTRUCTOR
  // ============================================================

  Future<void> _assignInstructor(
      BatchModel batch,
      ) async {
    String? selectedInstructorId =
    batch.instructorId.trim().isNotEmpty
        ? batch.instructorId.trim()
        : null;

    final availableInstructors =
    _instructors.where((instructor) {
      final id =
          instructor['id']?.toString().trim() ?? '';

      return id.isNotEmpty;
    }).toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            Future<void> assign() async {
              final instructorId =
                  selectedInstructorId
                      ?.trim() ??
                      '';

              if (instructorId.isEmpty) {
                _showSnackBar(
                  'Please select an instructor.',
                  isError: true,
                );
                return;
              }

              setDialogState(() {
                saving = true;
              });

              try {
                await _instructorService
                    .assignInstructor(
                  batchId: batch.id,
                  instructorId:
                  instructorId,
                );

                if (dialogContext.mounted) {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                }

                await _loadData();

                _showSnackBar(
                  'Instructor assigned successfully.',
                );
              } catch (e) {
                if (!context.mounted) {
                  return;
                }

                setDialogState(() {
                  saving = false;
                });

                _showSnackBar(
                  'Unable to assign instructor: '
                      '${_cleanError(e)}',
                  isError: true,
                );
              }
            }

            return AlertDialog(
              title: Text(
                batch.instructorId
                    .trim()
                    .isEmpty
                    ? 'Assign Instructor'
                    : 'Change Instructor',
              ),

              content: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 520,
                ),
                child: SizedBox(
                  width: 520,
                  child: availableInstructors
                      .isEmpty
                      ? const Padding(
                    padding:
                    EdgeInsets
                        .symmetric(
                      vertical: 20,
                    ),
                    child: Text(
                      'No active instructors are available.',
                    ),
                  )
                      : DropdownButtonFormField<
                      String>(
                    initialValue:
                    availableInstructors
                        .any(
                          (instructor) =>
                      instructor[
                      'id']
                          ?.toString()
                          .trim() ==
                          selectedInstructorId,
                    )
                        ? selectedInstructorId
                        : null,
                    isExpanded: true,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Instructor',
                      prefixIcon:
                      Icon(
                        Icons
                            .person_outline,
                      ),
                      border:
                      OutlineInputBorder(),
                    ),
                    items:
                    availableInstructors
                        .map(
                          (instructor) {
                        final id =
                            instructor[
                            'id']
                                ?.toString()
                                .trim() ??
                                '';

                        final name =
                            instructor[
                            'name']
                                ?.toString()
                                .trim() ??
                                '';

                        final email =
                            instructor[
                            'email']
                                ?.toString()
                                .trim() ??
                                '';

                        final displayName =
                        name.isNotEmpty
                            ? name
                            : email.isNotEmpty
                            ? email
                            : 'Instructor';

                        return DropdownMenuItem<
                            String>(
                          value: id,
                          child: Text(
                            displayName,
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: saving
                        ? null
                        : (value) {
                      setDialogState(
                            () {
                          selectedInstructorId =
                              value;
                        },
                      );
                    },
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                  const Text('Cancel'),
                ),

                SizedBox(
                  width: 120,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed:
                    saving ||
                        availableInstructors
                            .isEmpty
                        ? null
                        : assign,
                    icon: saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons
                          .person_add_outlined,
                      size: 18,
                    ),
                    label: Text(
                      saving
                          ? 'Assigning...'
                          : 'Assign',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // REMOVE INSTRUCTOR
  // ============================================================

  Future<void> _removeInstructor(
      BatchModel batch,
      ) async {
    final instructorName =
    _instructorName(
      batch.instructorId,
    );

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove Instructor?',
          ),
          content: Text(
            'Remove $instructorName from this batch?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(false),
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(true),
              child:
              const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _instructorService
          .removeInstructor(
        batchId: batch.id,
        instructorId:
        batch.instructorId,
      );

      await _loadData();

      _showSnackBar(
        'Instructor removed successfully.',
      );
    } catch (e) {
      _showSnackBar(
        'Unable to remove instructor: '
            '${_cleanError(e)}',
        isError: true,
      );
    }
  }

  // ============================================================
  // TOGGLE BATCH
  // ============================================================

  Future<void> _toggleBatch(
      BatchModel batch,
      ) async {
    try {
      await _batchService.setBatchOpenStatus(
        batchId: batch.id,
        isOpen: !batch.isOpen,
      );

      await _loadData();

      _showSnackBar(
        batch.isOpen
            ? 'Batch closed successfully.'
            : 'Batch opened successfully.',
      );
    } catch (e) {
      _showSnackBar(
        'Unable to update batch status: '
            '${_cleanError(e)}',
        isError: true,
      );
    }
  }

  // ============================================================
  // DELETE BATCH
  // ============================================================

  Future<void> _deleteBatch(
      BatchModel batch,
      ) async {
    final course =
    _findCourse(batch.courseId);

    final courseName =
    course != null
        ? _courseName(course)
        : batch.courseId.trim().isEmpty
        ? 'Unknown course'
        : batch.courseId;

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          const Text('Delete Batch?'),
          content: Text(
            'Are you sure you want to delete the '
                '$courseName batch?\n\n'
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(false),
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              style:
              FilledButton.styleFrom(
                backgroundColor:
                Colors.red,
              ),
              onPressed: () =>
                  Navigator.of(context)
                      .pop(true),
              child:
              const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _batchService.deleteBatch(
        batch.id,
      );

      await _loadData();

      _showSnackBar(
        'Batch deleted successfully.',
      );
    } catch (e) {
      _showSnackBar(
        'Unable to delete batch: '
            '${_cleanError(e)}',
        isError: true,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final batches =
        _filteredBatches;

    return Scaffold(
      backgroundColor:
      AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child:
              _buildBody(batches),
            ),
          ],
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        heroTag:
        'coordinator-batches-create-batch',
        onPressed: _isLoading
            ? null
            : () => _showBatchDialog(),
        icon:
        const Icon(Icons.add),
        label:
        const Text('Create Batch'),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch Management',
                  style:
                  Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                    color:
                    AppColors.primary,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Create, manage and assign instructors',
                  style:
                  Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            _isLoading
                ? null
                : _loadData,
            icon:
            const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      child: TextField(
        controller:
        _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration:
        InputDecoration(
          hintText:
          'Search by course, campus, room or instructor...',
          prefixIcon:
          const Icon(Icons.search),
          suffixIcon:
          _searchQuery.isEmpty
              ? null
              : IconButton(
            onPressed: () {
              _searchController
                  .clear();

              setState(() {
                _searchQuery =
                '';
              });
            },
            icon:
            const Icon(
              Icons.clear,
            ),
          ),
          filled: true,
          fillColor:
          Colors.white,
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            borderSide:
            BorderSide.none,
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            borderSide: BorderSide(
              color:
              Colors.grey.shade200,
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            borderSide:
            BorderSide(
              color:
              AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      List<BatchModel> batches,
      ) {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_courses.isEmpty ||
        _campuses.isEmpty) {
      return _buildSetupWarning();
    }

    if (batches.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return _buildEmptySearch();
      }

      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          100,
        ),
        itemCount:
        batches.length,
        itemBuilder:
            (context, index) {
          return _buildBatchCard(
            batches[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // SETUP WARNING
  // ============================================================

  Widget _buildSetupWarning() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .warning_amber_rounded,
              size: 64,
              color:
              Colors.orange.shade700,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Course or Campus data is missing',
              textAlign:
              TextAlign.center,
              style:
              Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Please add active courses and campuses '
                  'in Firestore before creating batches.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FilledButton.icon(
              onPressed:
              _loadData,
              icon:
              const Icon(
                Icons.refresh,
              ),
              label:
              const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .groups_2_outlined,
              size: 72,
              color: AppColors
                  .primary
                  .withAlpha(110),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'No Batches Yet',
              style:
              Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Create your first batch to start managing '
                  'students and instructors.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FilledButton.icon(
              onPressed:
                  () => _showBatchDialog(),
              icon:
              const Icon(Icons.add),
              label:
              const Text(
                'Create Batch',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .search_off_rounded,
              size: 64,
              color:
              Colors.grey.shade400,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'No matching batches',
              style:
              Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Try searching with another course, campus, '
                  'room or instructor name.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BATCH CARD
  // ============================================================

  Widget _buildBatchCard(
      BatchModel batch,
      ) {
    final course =
    _findCourse(batch.courseId);

    final campus =
    _findCampus(batch.campusId);

    final courseName =
    course != null
        ? _courseName(course)
        : batch.courseId.trim().isEmpty
        ? 'Unknown Course'
        : batch.courseId;

    final campusName =
    campus != null
        ? _campusName(campus)
        : batch.campusId.trim().isEmpty
        ? 'Unknown Campus'
        : batch.campusId;

    final instructorName =
    _instructorName(
      batch.instructorId,
    );

    final seatsLeft =
        batch.seatsLeft;

    final progress =
    batch.seats <= 0
        ? 0.0
        : (batch.enrolledStudents /
        batch.seats)
        .clamp(0.0, 1.0);

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 0,
      color:
      Colors.white,
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        side: BorderSide(
          color:
          Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // TOP
            // ------------------------------------------------------

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        Theme.of(
                          context,
                        )
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Batch ID: ${batch.id}',
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        TextStyle(
                          fontSize: 12,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                _statusChip(
                  batch.isOpen,
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ------------------------------------------------------
            // INFO
            // ------------------------------------------------------

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _infoItem(
                  Icons
                      .location_on_outlined,
                  campusName,
                ),
                _infoItem(
                  Icons
                      .calendar_today_outlined,
                  batch.classDay,
                ),
                _infoItem(
                  Icons
                      .access_time_outlined,
                  batch.classTime,
                ),
                _infoItem(
                  Icons
                      .meeting_room_outlined,
                  batch.room,
                ),
                _infoItem(
                  Icons.event_outlined,
                  _formatDate(
                    batch.startDate,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ------------------------------------------------------
            // SEATS
            // ------------------------------------------------------

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .groups_outlined,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Flexible(
                            child: Text(
                              '${batch.enrolledStudents} / '
                                  '${batch.seats} students',
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      ClipRRect(
                        borderRadius:
                        BorderRadius
                            .circular(
                          10,
                        ),
                        child:
                        LinearProgressIndicator(
                          value:
                          progress,
                          minHeight: 7,
                          backgroundColor:
                          Colors
                              .grey
                              .shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                      color: seatsLeft >
                          0
                          ? Colors.green
                          .withAlpha(
                        25,
                      )
                          : Colors.red
                          .withAlpha(
                        25,
                      ),
                    ),
                    child: Text(
                      seatsLeft > 0
                          ? '$seatsLeft seats left'
                          : 'Full',
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                        color: seatsLeft >
                            0
                            ? Colors
                            .green
                            .shade700
                            : Colors
                            .red
                            .shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ------------------------------------------------------
            // INSTRUCTOR
            // ------------------------------------------------------

            _buildInstructorSection(
              batch: batch,
              instructorName:
              instructorName,
            ),

            const SizedBox(
              height: 14,
            ),

            // ------------------------------------------------------
            // ACTIONS
            // ------------------------------------------------------

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 120,
                  height: 44,
                  child:
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showBatchDialog(
                          existingBatch:
                          batch,
                        ),
                    icon:
                    const Icon(
                      Icons
                          .edit_outlined,
                      size: 18,
                    ),
                    label:
                    const Text(
                      'Edit',
                    ),
                  ),
                ),

                SizedBox(
                  width: 120,
                  height: 44,
                  child:
                  OutlinedButton.icon(
                    onPressed: () =>
                        _toggleBatch(
                          batch,
                        ),
                    icon: Icon(
                      batch.isOpen
                          ? Icons
                          .lock_outline
                          : Icons
                          .lock_open_outlined,
                      size: 18,
                    ),
                    label: Text(
                      batch.isOpen
                          ? 'Close'
                          : 'Open',
                    ),
                  ),
                ),

                SizedBox(
                  width: 48,
                  height: 44,
                  child:
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    onSelected:
                        (value) {
                      if (value ==
                          'remove_instructor') {
                        _removeInstructor(
                          batch,
                        );
                      } else if (value ==
                          'delete') {
                        _deleteBatch(
                          batch,
                        );
                      }
                    },
                    itemBuilder:
                        (context) {
                      return [
                        if (batch
                            .instructorId
                            .trim()
                            .isNotEmpty)
                          const PopupMenuItem<
                              String>(
                            value:
                            'remove_instructor',
                            child: Row(
                              mainAxisSize:
                              MainAxisSize
                                  .min,
                              children: [
                                Icon(
                                  Icons
                                      .person_remove_outlined,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Remove Instructor',
                                ),
                              ],
                            ),
                          ),
                        const PopupMenuItem<
                            String>(
                          value:
                          'delete',
                          child: Row(
                            mainAxisSize:
                            MainAxisSize
                                .min,
                            children: [
                              Icon(
                                Icons
                                    .delete_outline,
                                color:
                                Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Delete Batch',
                                style:
                                TextStyle(
                                  color:
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                    child:
                    const Center(
                      child: Icon(
                        Icons.more_vert,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INSTRUCTOR SECTION
  // ============================================================

  Widget _buildInstructorSection({
    required BatchModel batch,
    required String instructorName,
  }) {
    final buttonLabel =
    batch.instructorId
        .trim()
        .isEmpty
        ? 'Assign'
        : 'Change';

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration:
      BoxDecoration(
        color:
        AppColors.background,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final maxWidth =
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 300.0;

          final buttonWidth =
          maxWidth >= 430
              ? 125.0
              : 130.0;

          final instructorInfo =
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                AppColors
                    .primary
                    .withAlpha(
                  25,
                ),
                child: Icon(
                  Icons
                      .person_outline,
                  color:
                  AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Instructor',
                      style:
                      TextStyle(
                        fontSize: 11,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      instructorName,
                      maxLines:
                      maxWidth >= 430
                          ? 1
                          : 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actionButton =
          SizedBox(
            width: buttonWidth,
            height: 44,
            child:
            OutlinedButton.icon(
              onPressed: () =>
                  _assignInstructor(
                    batch,
                  ),
              icon:
              const Icon(
                Icons
                    .person_add_outlined,
                size: 17,
              ),
              label:
              Text(buttonLabel),
            ),
          );

          // ------------------------------------------------------
          // SMALL
          // ------------------------------------------------------

          if (maxWidth < 430) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                instructorInfo,
                const SizedBox(
                  height: 10,
                ),
                actionButton,
              ],
            );
          }

          // ------------------------------------------------------
          // LARGE
          // ------------------------------------------------------

          return Row(
            children: [
              Expanded(
                child:
                instructorInfo,
              ),
              const SizedBox(
                width: 10,
              ),
              actionButton,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
      bool isOpen,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: isOpen
            ? Colors.green
            .withAlpha(25)
            : Colors.red
            .withAlpha(25),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            isOpen
                ? Icons
                .check_circle_outline
                : Icons
                .cancel_outlined,
            size: 15,
            color: isOpen
                ? Colors
                .green
                .shade700
                : Colors
                .red
                .shade700,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            isOpen
                ? 'Open'
                : 'Closed',
            style:
            TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              color: isOpen
                  ? Colors
                  .green
                  .shade700
                  : Colors
                  .red
                  .shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
      IconData icon,
      String text,
      ) {
    final safeText =
    text.trim().isEmpty
        ? 'Not set'
        : text.trim();

    return Container(
      constraints:
      const BoxConstraints(
        maxWidth: 260,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color:
            AppColors.primary,
          ),
          const SizedBox(
            width: 6,
          ),
          Flexible(
            child: Text(
              safeText,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}