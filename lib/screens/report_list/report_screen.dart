import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iu_job_assessment/providers/report_provider.dart';
import 'package:iu_job_assessment/screens/report_list/report_item_widget.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Main reports screen with list and pagination
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial reports when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsProvider.notifier).loadInitialReports();
    });

    // Set up scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      ref.read(reportsProvider.notifier).loadMoreReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      //floatingActionButton: _buildAddReportButton(),
    );
  }

  /// Build the app bar with location and search icons
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset('assets/svgs/Logomark Custom.svg'),
      ),
      title: const Text('My reports'),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement search functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search functionality coming soon')),
            );
          },
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  /// Build the main body content
  Widget _buildBody() {
    final reportsState = ref.watch(reportsProvider);
    final totalReports = ref.watch(totalReportsProvider);
    final isEmpty = ref.watch(isReportsEmptyProvider);

    if (isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(reportsProvider.notifier).refreshReports();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _calculateItemCount(reportsState),
              itemBuilder: (context, index) {
                return _buildListItem(context, index, reportsState);
              },
            ),
          ),
        ),
        _buildBottomInfo(reportsState.reports.length, totalReports),
      ],
    );
  }

  /// Calculate total item count including loading indicators
  int _calculateItemCount(reportsState) {
    int count = reportsState.reports.length;

    // Add loading item if loading more
    if (reportsState.isLoading && reportsState.reports.isNotEmpty) {
      count += 3; // Show 3 loading items
    }

    return count;
  }

  /// Build individual list items
  Widget _buildListItem(BuildContext context, int index, reportsState) {
    final reportsLength = reportsState.reports.length;

    // Show loading items at the end
    if (index >= reportsLength) {
      return const LoadingReportItemWidget();
    }

    final report = reportsState.reports[index];
    return ReportItemWidget(
      report: report,
      onTap: () {
        // TODO: Navigate to report details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on ${report.type}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  /// Build empty state when no reports
  Widget _buildEmptyState() {
    final reportsState = ref.watch(reportsProvider);

    if (reportsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (reportsState.error != null) {
      return _buildErrorState(reportsState.error!);
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No reports available',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first report',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
        _buildAddReportButton(),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(reportsProvider.notifier).refreshReports();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build bottom pagination info
  Widget _buildBottomInfo(int currentCount, int total) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 - $currentCount of $total',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final reportsState = ref.watch(reportsProvider);

                  if (!reportsState.hasMore) {
                    return const SizedBox.shrink();
                  }

                  return TextButton(
                    onPressed: reportsState.isLoading
                        ? null
                        : () {
                            ref
                                .read(reportsProvider.notifier)
                                .loadMoreReports();
                          },
                    child: reportsState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Text(
                            'Load more',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final reportsState = ref.watch(reportsProvider);

              if (reportsState.hasMore) {
                return const SizedBox.shrink();
              }

              return Text(
                "No more reports available",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              );
            },
          ),
          _buildAddReportButton(),
        ],
      ),
    );
  }

  /// Build Add Report button
  Widget _buildAddReportButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: AppColors.primary,
          ),
          onPressed: _showAddReportDialog,
          icon: const Icon(Icons.add_circle, color: AppColors.background),
          label: const Text(
            'Add Report',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.background,
            ),
          ),
        ),
      ],
    );
  }

  /// Show add report dialog
  void _showAddReportDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddReportDialog(
        onAdd: (type, location) {
          ref
              .read(reportsProvider.notifier)
              .addReport(type: type, location: location);
        },
      ),
    );
  }
}

/// Dialog for adding new reports
class _AddReportDialog extends StatefulWidget {
  final Function(String type, String location) onAdd;

  const _AddReportDialog({required this.onAdd});

  @override
  State<_AddReportDialog> createState() => _AddReportDialogState();
}

// Temporary class for adding new reports
class _AddReportDialogState extends State<_AddReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Report'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Report Type',
                hintText: 'e.g., Incident Report',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a report type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Building A - Floor 1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Report'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onAdd(
        _typeController.text.trim(),
        _locationController.text.trim(),
      );
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report added successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
