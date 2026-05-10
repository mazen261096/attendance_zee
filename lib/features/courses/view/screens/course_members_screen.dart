import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';
import '../widgets/member_tile.dart';
import '../widgets/join_request_tile.dart';

class CourseMembersScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  final bool isAdmin;

  const CourseMembersScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.isAdmin,
  });

  @override
  State<CourseMembersScreen> createState() => _CourseMembersScreenState();
}

class _CourseMembersScreenState extends State<CourseMembersScreen> {
  late final CourseCubit _courseCubit;
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = SupabaseService().currentUser?.id ?? '';
    _courseCubit = getIt<CourseCubit>();
    _courseCubit.getCourseMembers(courseId: widget.courseId);
    if (widget.isAdmin) {
      _courseCubit.getJoinRequests(courseId: widget.courseId);
    }
  }

  @override
  void dispose() {
    _courseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _courseCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.courseName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                _courseCubit.getCourseMembers(courseId: widget.courseId);
                if (widget.isAdmin) {
                  _courseCubit.getJoinRequests(courseId: widget.courseId);
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Join Requests (admin only) ──
                  if (widget.isAdmin && state.joinRequests.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.pending_actions_rounded,
                            size: 18, color: AppConfig.warningColor),
                        const SizedBox(width: 8),
                        Text(
                          'Pending Requests (${state.joinRequests.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppConfig.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...state.joinRequests
                        .where((r) => r.isPending)
                        .map((req) => JoinRequestTile(
                              request: req,
                              onApprove: () => _courseCubit.approveJoinRequest(
                                requestId: req.id,
                              ),
                              onReject: () => _courseCubit.rejectJoinRequest(
                                requestId: req.id,
                              ),
                            )),
                    const Divider(height: 32),
                  ],
                  // ── Members List ──
                  Row(
                    children: [
                      Icon(Icons.people_rounded,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Members (${state.members.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.isGetMembersLoading)
                    const AppLoadingIndicator(itemCount: 3)
                  else if (state.members.isEmpty)
                    const AppEmptyState(
                      icon: Icons.people_outline,
                      title: 'No Members',
                      subtitle: 'Share the code to invite students',
                    )
                  else
                    ...state.members.map((member) => MemberTile(
                          member: member,
                          isCurrentUserAdmin: widget.isAdmin,
                          currentUserId: _currentUserId,
                          onRemove: (m) => _courseCubit.removeMember(
                            memberId: m.id,
                          ),
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
