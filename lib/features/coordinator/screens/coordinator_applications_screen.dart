import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../models/application_model.dart';
import '../services/coordinator_application_service.dart';

class CoordinatorApplicationsScreen extends StatefulWidget {
  const CoordinatorApplicationsScreen({
    super.key,
  });

  @override
  State<CoordinatorApplicationsScreen> createState() =>
      _CoordinatorApplicationsScreenState();
}

class _CoordinatorApplicationsScreenState
    extends State<CoordinatorApplicationsScreen> {
  final CoordinatorApplicationService _service =
      CoordinatorApplicationService.instance;

  List<ApplicationModel> _applications = [];

  bool _isLoading = true;
  bool _isUpdating = false;

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  // ============================================================
  // LOAD APPLICATIONS
  // ============================================================

  Future<void> _loadApplications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final applications =
      await _service.getApplications();

      if (!mounted) return;

      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Unable to load applications.\n$e',
      );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<ApplicationModel> get _filteredApplications {
    if (_selectedFilter == 'all') {
      return _applications;
    }

    return _applications.where((application) {
      final status =
      application.status
          .trim()
          .toLowerCase();

      if (_selectedFilter == 'waitlisted') {
        return status == 'waitlisted' ||
            status == 'waiting_list';
      }

      return status == _selectedFilter;
    }).toList();
  }

  // ============================================================
  // COUNT STATUS
  // ============================================================

  int _countStatus(String status) {
    return _applications.where((application) {
      final applicationStatus =
      application.status
          .trim()
          .toLowerCase();

      if (status == 'waitlisted') {
        return applicationStatus == 'waitlisted' ||
            applicationStatus == 'waiting_list';
      }

      return applicationStatus == status;
    }).length;
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updateStatus({
    required ApplicationModel application,
    required String status,
  }) async {
    if (_isUpdating) {
      return;
    }

    String? rejectionReason;

    if (status == 'rejected') {
      rejectionReason =
      await _showRejectionDialog();

      if (rejectionReason == null ||
          rejectionReason.trim().isEmpty) {
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _service.updateApplicationStatus(
        applicationId: application.id,
        status: status,
        rejectionReason: rejectionReason,
      );

      if (!mounted) return;

      await _loadApplications();

      if (!mounted) return;

      _showSuccess(
        '${_formatStatus(status)} successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Unable to update application.\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // ============================================================
  // REJECTION DIALOG
  // ============================================================

  Future<String?> _showRejectionDialog() async {
    final controller =
    TextEditingController();

    final result =
    await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Application',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText:
              'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final reason =
                controller.text.trim();

                if (reason.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  reason,
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showApplicationDetails(
      ApplicationModel application,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ApplicationDetailsSheet(
          application: application,
          isUpdating: _isUpdating,
          onStatusSelected: (status) {
            Navigator.pop(sheetContext);

            _updateStatus(
              application: application,
              status: status,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';

      case 'waitlisted':
      case 'waiting_list':
        return 'Waitlisted';

      case 'rejected':
        return 'Rejected';

      case 'submitted':
        return 'Submitted';

      default:
        if (status.isEmpty) {
          return 'Updated';
        }

        return status[0].toUpperCase() +
            status.substring(1).toLowerCase();
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;

      case 'waitlisted':
      case 'waiting_list':
        return Colors.orange;

      case 'rejected':
        return Colors.red;

      case 'submitted':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_rounded;

      case 'waitlisted':
      case 'waiting_list':
        return Icons.hourglass_top_rounded;

      case 'rejected':
        return Icons.cancel_rounded;

      case 'submitted':
        return Icons.mark_email_unread_rounded;

      default:
        return Icons.info_rounded;
    }
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filteredApplications =
        _filteredApplications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Applications',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            _isLoading
                ? null
                : _loadApplications,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: _isLoading
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : _applications.isEmpty
            ? _buildEmptyState()
            : ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24,
          ),
          children: [
            _buildHeader(),

            const SizedBox(
              height: 16,
            ),

            _buildSummaryCards(),

            const SizedBox(
              height: 20,
            ),

            _buildFilterBar(),

            const SizedBox(
              height: 16,
            ),

            if (filteredApplications.isEmpty)
              _buildNoFilterResults()
            else
              ...filteredApplications.map(
                    (application) {
                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child:
                    _ApplicationCard(
                      application:
                      application,
                      statusColor:
                      _statusColor(
                        application
                            .status,
                      ),
                      statusIcon:
                      _statusIcon(
                        application
                            .status,
                      ),
                      statusText:
                      _formatStatus(
                        application
                            .status,
                      ),
                      onTap: () {
                        _showApplicationDetails(
                          application,
                        );
                      },
                    ),
                  );
                },
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inbox_rounded,
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
                  'Application Inbox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_applications.length} total applications',
                  style: TextStyle(
                    color:
                    Colors.white.withValues(
                      alpha: 0.85,
                    ),
                    fontSize: 13,
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
  // SUMMARY
  // ============================================================

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Submitted',
            count:
            _countStatus('submitted'),
            icon:
            Icons.mark_email_unread_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Accepted',
            count:
            _countStatus('accepted'),
            icon:
            Icons.check_circle_outline_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Waitlisted',
            count:
            _countStatus('waitlisted'),
            icon:
            Icons.hourglass_empty_rounded,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Rejected',
            count:
            _countStatus('rejected'),
            icon:
            Icons.cancel_outlined,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    const filters = [
      'all',
      'submitted',
      'accepted',
      'waitlisted',
      'rejected',
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected =
              _selectedFilter == filter;

          return Padding(
            padding:
            const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              label: Text(
                filter == 'all'
                    ? 'All'
                    : _formatStatus(
                  filter,
                ),
              ),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter =
                      filter;
                });
              },
              selectedColor:
              AppColors.primary,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight:
                FontWeight.w600,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
          MediaQuery.of(context)
              .size
              .height *
              0.65,
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration:
                    BoxDecoration(
                      color:
                      AppColors
                          .accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 42,
                      color:
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'No Applications Yet',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'New student applications will appear here.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color:
                      AppColors
                          .textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NO FILTER RESULTS
  // ============================================================

  Widget _buildNoFilterResults() {
    return Container(
      padding:
      const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 44,
            color:
            AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching applications',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another application status.',
            style: TextStyle(
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard
    extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),
          const SizedBox(height: 7),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color:
              AppColors.textSecondary,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// APPLICATION CARD
// ============================================================

class _ApplicationCard
    extends StatelessWidget {
  final ApplicationModel application;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.application,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius:
      BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(20),
        child: Container(
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                    AppColors
                        .accentLight,
                    child: Text(
                      _initials(
                        application.fullName,
                      ),
                      style: TextStyle(
                        color:
                        AppColors.primary,
                        fontWeight:
                        FontWeight.w800,
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
                          application
                              .fullName,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          application
                              .courseName,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style: TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    color: statusColor,
                    icon: statusIcon,
                    text: statusText,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .location_on_outlined,
                      text: application
                          .campusName
                          .isEmpty
                          ? application.city
                          : application
                          .campusName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .school_outlined,
                      text: application
                          .education,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors
                        .textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tap to review application',
                    style: TextStyle(
                      color: AppColors
                          .textSecondary,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
    )
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge
    extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _StatusBadge({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(alpha: 0.10),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO ITEM
// ============================================================

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.isEmpty
                ? 'Not specified'
                : text,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// APPLICATION DETAILS SHEET
// ============================================================

class _ApplicationDetailsSheet
    extends StatelessWidget {
  final ApplicationModel application;
  final bool isUpdating;
  final void Function(String status)
  onStatusSelected;

  const _ApplicationDetailsSheet({
    required this.application,
    required this.isUpdating,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
          MediaQuery.of(context)
              .size
              .height *
              0.88,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                    AppColors
                        .accentLight,
                    child: Text(
                      _initials(
                        application.fullName,
                      ),
                      style: TextStyle(
                        color:
                        AppColors.primary,
                        fontSize: 18,
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
                          application
                              .fullName,
                          style:
                          const TextStyle(
                            fontSize: 21,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          application
                              .courseName,
                          style: TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Application Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Status',
                value:
                _formatStatus(
                  application.status,
                ),
                icon:
                Icons.info_outline_rounded,
              ),
              _DetailRow(
                label: 'Student ID',
                value:
                application.studentId,
                icon:
                Icons.badge_outlined,
              ),
              _DetailRow(
                label: 'CNIC',
                value:
                application.cnic,
                icon: Icons
                    .credit_card_outlined,
              ),
              _DetailRow(
                label: 'Education',
                value:
                application.education,
                icon:
                Icons.school_outlined,
              ),
              _DetailRow(
                label: 'City',
                value:
                application.city,
                icon: Icons
                    .location_city_outlined,
              ),
              _DetailRow(
                label: 'Campus',
                value:
                application.campusName,
                icon: Icons
                    .location_on_outlined,
              ),
              _DetailRow(
                label: 'Course',
                value:
                application.courseName,
                icon: Icons
                    .menu_book_outlined,
              ),
              _DetailRow(
                label: 'Batch',
                value:
                application.batchId.isEmpty
                    ? 'Not assigned'
                    : application
                    .batchId,
                icon:
                Icons.groups_outlined,
              ),
              if (application
                  .whyJoin
                  .isNotEmpty)
                _DetailRow(
                  label: 'Why Join',
                  value:
                  application.whyJoin,
                  icon: Icons
                      .lightbulb_outline_rounded,
                  multiline: true,
                ),
              if (application
                  .rejectionReason !=
                  null &&
                  application
                      .rejectionReason!
                      .trim()
                      .isNotEmpty)
                _DetailRow(
                  label:
                  'Rejection Reason',
                  value: application
                      .rejectionReason!,
                  icon: Icons
                      .warning_amber_rounded,
                  multiline: true,
                ),
              const SizedBox(height: 20),
              const Text(
                'Update Application',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label:
                'Accept Application',
                icon: Icons
                    .check_circle_outline_rounded,
                color: Colors.green,
                enabled: !isUpdating,
                onPressed: () {
                  onStatusSelected(
                    'accepted',
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label:
                'Wait-list Application',
                icon: Icons
                    .hourglass_top_rounded,
                color: Colors.orange,
                enabled: !isUpdating,
                onPressed: () {
                  onStatusSelected(
                    'waitlisted',
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label:
                'Reject Application',
                icon: Icons
                    .cancel_outlined,
                color: Colors.red,
                enabled: !isUpdating,
                onPressed: () {
                  onStatusSelected(
                    'rejected',
                  );
                },
              ),
              if (isUpdating) ...[
                const SizedBox(height: 16),
                const Center(
                  child:
                  CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatStatus(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';

      case 'waitlisted':
      case 'waiting_list':
        return 'Waitlisted';

      case 'rejected':
        return 'Rejected';

      case 'submitted':
        return 'Submitted';

      default:
        if (status.isEmpty) {
          return 'Unknown';
        }

        return status[0].toUpperCase() +
            status.substring(1)
                .toLowerCase();
    }
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
    )
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow
    extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool multiline;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty
                      ? 'Not specified'
                      : value,
                  maxLines:
                  multiline ? null : 2,
                  overflow: multiline
                      ? null
                      : TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class _ActionButton
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed:
        enabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
        style:
        ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor:
          Colors.white,
          disabledBackgroundColor:
          Colors.grey.shade300,
          disabledForegroundColor:
          Colors.grey.shade600,
          elevation: 0,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}