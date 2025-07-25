// screens/report_list/report_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iu_job_assessment/providers/report_provider.dart';
import 'package:iu_job_assessment/screens/report_details/report_details_screen.dart';
import 'package:iu_job_assessment/screens/report_form/add_report_screen.dart';
import 'package:iu_job_assessment/screens/report_list/report_item_widget.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';
import 'package:iu_job_assessment/services/report_service.dart';

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
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  /// Build the app bar with location and search icons
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset('assets/svgs/logo_40_x_40.svg'),
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
        // Add a debug menu for development
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'clear_user_reports':
                await ref.read(reportsProvider.notifier).clearAllUserReports();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User reports cleared')),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_user_reports',
              child: Text('Clear User Reports'),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the main body content
  Widget _buildBody() {
    final reportsState = ref.watch(reportsProvider);
    final totalReports = ref.watch(totalReportsProvider);
    final loadedReports = ref.watch(loadedReportsProvider);
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
        _buildBottomInfo(loadedReports, totalReports),
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
    final bool userCreated = ReportService.isUserCreatedReportSync(report.id);

    return ReportItemWidget(
      report: report,
      isUserCreated: userCreated,
      onTap: () {
        // Navigate to report details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsScreen(report: report),
          ),
        );
      },
      onDelete: userCreated ? () => _showDeleteConfirmation(report.id) : null,
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(String reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(reportsProvider.notifier).deleteReport(reportId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Report deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: AppColors.primary,
          ),
          onPressed: () => _showAddReportScreen(context),
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

  /// Updated method to push AddReportScreen
  static void _showAddReportScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddReportScreen(),
        fullscreenDialog: true, // Makes it slide up from bottom
      ),
    );
  }
}
