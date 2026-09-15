import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/course_model.dart';
import '../../../../services/course_service.dart';
import '../screen/course_detail_screen.dart';
import '../widgets/course_card.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({
    super.key,
  });

  @override
  State<CourseListScreen> createState() =>
      _CourseListScreenState();
}

class _CourseListScreenState
    extends State<CourseListScreen> {
  late Future<List<CourseModel>> _coursesFuture;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture =
        CourseService.instance.getActiveCourses();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadCourses();
    });

    await _coursesFuture;
  }

  List<CourseModel> _filterCourses(
      List<CourseModel> courses,
      ) {
    if (_searchQuery.trim().isEmpty) {
      return courses;
    }

    final query =
    _searchQuery.toLowerCase().trim();

    return courses.where((course) {
      return course.name
          .toLowerCase()
          .contains(query) ||
          course.level
              .toLowerCase()
              .contains(query) ||
          course.description
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  void _openCourseDetails(
      CourseModel course,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          course: course,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
      ),

      body: FutureBuilder<List<CourseModel>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              onRetry: _refresh,
            );
          }

          final courses = _filterCourses(
            snapshot.data ?? [],
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    16,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration:
                    InputDecoration(
                      hintText:
                      'Search courses...',
                      prefixIcon:
                      const Icon(
                        Icons.search_rounded,
                      ),
                      suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery =
                            '';
                          });
                        },
                        icon:
                        const Icon(
                          Icons.clear,
                        ),
                      )
                          : null,
                    ),
                  ),
                ),

                Expanded(
                  child: courses.isEmpty
                      ? ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height:
                        MediaQuery.of(
                          context,
                        )
                            .size
                            .height *
                            .3,
                      ),
                      const Center(
                        child: Text(
                          'No courses found.',
                        ),
                      ),
                    ],
                  )
                      : ListView.separated(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    itemCount:
                    courses.length,
                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      height: 14,
                    ),
                    itemBuilder:
                        (context, index) {
                      final course =
                      courses[index];

                      return CourseCard(
                        course: course,
                        index: index,
                        onTap: () {
                          _openCourseDetails(
                            course,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: AppColors.textLight,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}