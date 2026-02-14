import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/features/activity/data/model/activity_item.dart';
import 'package:finguard_app/features/activity/viewmodel/activity_viewmodel.dart';
import 'package:finguard_app/features/activity/view/widgets/insight_card_widget.dart';
import 'package:finguard_app/features/activity/view/widgets/date_header_widget.dart';
import 'package:finguard_app/features/activity/view/widgets/activity_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() async {
      try {
        await context.read<ActivityViewmodel>().loadActivities(refresh: true);
      } catch (e) {
        // Error already handled in viewmodel
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ActivityViewmodel>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ActivityViewmodel>().loadActivities(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewmodel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: _buildBody(vm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'This month overview',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ActivityViewmodel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange[300],
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorTitle(vm.error!),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getErrorMessage(vm.error!),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.loadActivities(refresh: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E5CE6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.items.isEmpty && vm.insight == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transactions and updates\nwill appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: _calculateItemCount(vm),
        itemBuilder: (context, index) {
          if (index == 0 && vm.insight != null) {
            return InsightCardWidget(insight: vm.insight!);
          }

          final timelineIndex = vm.insight != null ? index - 1 : index;

          if (timelineIndex == vm.items.length && vm.hasMore) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: vm.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }

          if (timelineIndex < vm.items.length) {
            final item = vm.items[timelineIndex];
            
            // If it's a date header, collect all items for this date group
            if (item is ActivityDateHeader) {
              final groupItems = _collectGroupItems(vm.items, timelineIndex);
              final isLastGroup = _isLastGroup(vm.items, timelineIndex, groupItems.length);
              final settings = context.watch<AppSettings>();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateHeaderWidget(header: item),
                  ActivityGroupCard(
                    items: groupItems,
                    showConnector: !isLastGroup,
                    settings: settings,
                  ),
                ],
              );
            }
            // Skip non-header items as they're already included in the group card
            return const SizedBox.shrink();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<ActivityItem> _collectGroupItems(List<ActivityItem> items, int headerIndex) {
    final groupItems = <ActivityItem>[];
    
    // Start from the item after the header
    for (int i = headerIndex + 1; i < items.length; i++) {
      final item = items[i];
      // Stop when we hit the next header
      if (item is ActivityDateHeader) {
        break;
      }
      groupItems.add(item);
    }
    
    return groupItems;
  }

  bool _isLastGroup(List<ActivityItem> items, int headerIndex, int groupSize) {
    // Check if this is the last group by seeing if there's another header after this group
    final nextIndex = headerIndex + groupSize + 1;
    if (nextIndex >= items.length) return true;
    
    // Check if there's another date header after this group
    for (int i = nextIndex; i < items.length; i++) {
      if (items[i] is ActivityDateHeader) {
        return false;
      }
    }
    
    return true;
  }

  int _calculateItemCount(ActivityViewmodel vm) {
    int count = vm.items.length;
    if (vm.insight != null) count++;
    if (vm.hasMore) count++;
    return count;
  }

  String _getErrorTitle(String error) {
    if (error.contains('Authentication')) {
      return 'Authentication Required';
    } else if (error.contains('not available') || error.contains('404')) {
      return 'Feature Coming Soon';
    } else if (error.contains('timeout') || error.contains('internet')) {
      return 'Connection Issue';
    }
    return 'Something went wrong';
  }

  String _getErrorMessage(String error) {
    if (error.contains('Authentication')) {
      return 'Please try logging in again to access your activities';
    } else if (error.contains('not available') || error.contains('404')) {
      return 'This feature is being set up and will be\navailable soon';
    } else if (error.contains('timeout') || error.contains('internet')) {
      return 'Please check your internet connection\nand try again';
    }
    return 'We couldn\'t load your activities.\nPlease try again';
  }
}
