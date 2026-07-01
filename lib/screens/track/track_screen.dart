// Main race screen: animated track, group setup, step counter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/step_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/user_profile.dart';
import '../../widgets/group_join_dialog.dart';
import '../../widgets/permission_banner.dart';
import '../../services/permission_service.dart';
import 'track_painter.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> with TickerProviderStateMixin {
  late AnimationController _walkCtrl;
  late ConfettiController _confettiCtrl;
  bool _confettiFired = false;
  bool _permBannerVisible = false;

  @override
  void initState() {
    super.initState();
    _walkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
    _checkPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSteps());
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionService().checkStepPermission();
    if (mounted) setState(() => _permBannerVisible = !granted);
  }

  void _initSteps() {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) context.read<StepProvider>().init(uid);
  }

  @override
  void dispose() {
    _walkCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  List<UserProfile> _buildMemberList(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final steps = context.read<StepProvider>();
    final group = context.read<GroupProvider>();
    final uid = auth.user?.uid ?? '';

    if (group.inGroup) {
      // Merge local step count for current user into the group list
      return group.members.map((m) {
        if (m.uid == uid) return m.copyWith(steps: steps.todaySteps);
        return m;
      }).toList();
    }

    // Solo mode — just show the current user
    return [
      UserProfile(
        uid: uid,
        name: 'You',
        color: 'coral',
        goal: steps.goal,
        steps: steps.todaySteps,
      ),
    ];
  }

  void _checkConfetti(List<UserProfile> members, String uid) {
    final me = members.where((m) => m.uid == uid).firstOrNull;
    if (me != null && me.goalHit && !_confettiFired) {
      _confettiFired = true;
      _confettiCtrl.play();
    } else if (me != null && !me.goalHit) {
      _confettiFired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final steps = context.watch<StepProvider>();
    final group = context.watch<GroupProvider>();
    final uid = auth.user?.uid ?? '';
    final members = _buildMemberList(context);
    _checkConfetti(members, uid);

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.coral,
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          group.inGroup ? group.group!.name : 'Step Race',
                          style: AppText.fredoka(22, AppColors.coralDark),
                        ),
                        Text(
                          group.inGroup
                              ? '${group.members.length} racers · goal ${formatSteps(steps.goal)}'
                              : 'Solo mode',
                          style: AppText.dmSans(12, AppColors.inkSoft),
                        ),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(formatSteps(steps.todaySteps),
                            style: AppText.fredoka(24, AppColors.coralDark)),
                        Text('your steps', style: AppText.dmSans(11, AppColors.inkSoft)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Permission banner
                  if (_permBannerVisible) ...[
                    PermissionBanner(onDismiss: () => setState(() => _permBannerVisible = false)),
                    const SizedBox(height: 12),
                  ],

                  // Track card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _walkCtrl,
                            builder: (_, __) => CustomPaint(
                              size: const Size(double.infinity, 280),
                              painter: TrackPainter(
                                members: members,
                                walkAnim: _walkCtrl.value,
                                localUid: uid,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Legend chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: members.map((m) {
                              final color = kAvatarColors[m.color] ?? AppColors.coral;
                              final pct = (m.pct * 100).round();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.sandDeep,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${m.name} · $pct%',
                                      style: AppText.dmSans(12, AppColors.inkSoft)),
                                ]),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: group.inGroup
                            ? null
                            : () => _showGroupDialog(context, uid),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.leaf),
                        child: Text(
                          group.inGroup ? 'In a group ✓' : 'Join / Create Group',
                          style: AppText.fredoka(14, AppColors.white),
                        ),
                      ),
                    ),
                    if (group.inGroup) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.sandDeep),
                          backgroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => setState(() {}),
                        child: Text('Sync', style: AppText.fredoka(14, AppColors.ink)),
                      ),
                    ],
                  ]),

                  // Progress bar for current user
                  const SizedBox(height: 18),
                  Row(children: [
                    Text('${(steps.pct * 100).round()}% of goal',
                        style: AppText.dmSans(12, AppColors.inkSoft, weight: FontWeight.w700)),
                    const Spacer(),
                    Text(formatSteps(steps.goal), style: AppText.dmSans(12, AppColors.inkSoft)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: steps.pct,
                      minHeight: 10,
                      backgroundColor: AppColors.sandDeep,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        steps.goalHit ? AppColors.leaf : AppColors.coral,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confetti burst at top-center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                colors: const [AppColors.coral, AppColors.leaf, AppColors.amber, AppColors.purple],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupDialog(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupJoinDialog(uid: uid),
    );
  }
}
