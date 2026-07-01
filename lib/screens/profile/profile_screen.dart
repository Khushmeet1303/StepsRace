// Profile: name, avatar color, goal stepper, stats, group management, sign-out
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/step_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirestoreService();
  final _nameCtrl = TextEditingController();
  String _color = 'coral';
  UserProfile? _profile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final p = await _firestore.getProfile(uid);
    if (p != null && mounted) {
      setState(() {
        _profile = p;
        _nameCtrl.text = p.name;
        _color = p.color;
      });
    }
  }

  Future<void> _saveProfile() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final goal = context.read<StepProvider>().goal;
    try {
      await _firestore.saveProfile(uid, _nameCtrl.text.trim(), _color, goal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved ✓'), backgroundColor: AppColors.leaf),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.coral),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = context.watch<StepProvider>();
    final group = context.watch<GroupProvider>();
    final auth = context.watch<AuthProvider>();
    final avatarColor = kAvatarColors[_color] ?? AppColors.coral;

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            Text('Profile', style: AppText.fredoka(22, AppColors.ink)),
            const SizedBox(height: 16),

            // ── Identity card ────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: avatarColor,
                        child: Text(
                          initials(_nameCtrl.text.isEmpty ? 'You' : _nameCtrl.text),
                          style: AppText.fredoka(20, Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
    
                          controller: _nameCtrl,
                          onChanged: (_) => setState(() {}),
                          style: AppText.fredoka(17, AppColors.ink),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            hintText: 'Your name',
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Color picker
                    Text('Avatar color', style: AppText.dmSans(12, AppColors.inkSoft, weight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: kAvatarColors.entries.map((entry) {
                        final isActive = entry.key == _color;
                        return GestureDetector(
                          onTap: () => setState(() => _color = entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive ? AppColors.ink : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Goal stepper
                    Text('Daily step goal', style: AppText.dmSans(12, AppColors.inkSoft, weight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _StepBtn(
                        label: '–',
                        onTap: () => steps.updateGoal(
                          (steps.goal - kGoalStep).clamp(kMinGoal, 100000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(formatSteps(steps.goal), style: AppText.fredoka(20, AppColors.ink)),
                      const SizedBox(width: 12),
                      _StepBtn(
                        label: '+',
                        onTap: () => steps.updateGoal(steps.goal + kGoalStep),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
                        child: Text(_saving ? 'Saving…' : 'Save Profile',
                            style: AppText.fredoka(15, AppColors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Stats card ───────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your stats', style: AppText.dmSans(12, AppColors.inkSoft, weight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: [
                        _StatBox(value: formatSteps(steps.todaySteps), label: "today's steps"),
                        _StatBox(value: '${(steps.pct * 100).round()}%', label: 'of goal today'),
                        _StatBox(value: steps.goalHit ? '🎉 Yes' : 'Not yet', label: 'goal hit today'),
                        _StatBox(value: '—', label: 'avg this week'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Group card ───────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your group', style: AppText.dmSans(12, AppColors.inkSoft, weight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    if (group.inGroup) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(group.group!.name, style: AppText.dmSans(14, AppColors.ink, weight: FontWeight.w700)),
                              Text('${group.members.length} members', style: AppText.dmSans(11, AppColors.inkSoft)),
                            ]),
                          ),
                          _InviteChip(code: group.group!.inviteCode),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.sandDeep),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () async {
                            final uid = auth.user?.uid;
                            if (uid != null) await group.leaveGroup(uid);
                          },
                          child: Text('Leave group', style: AppText.dmSans(14, AppColors.inkSoft, weight: FontWeight.w700)),
                        ),
                      ),
                    ] else
                      Text('Not in a group. Join one from the Track tab!',
                          style: AppText.dmSans(13, AppColors.inkSoft)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Sign out ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.sandDeep),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await auth.signOut();
                },
                child: Text('Sign out', style: AppText.dmSans(14, AppColors.inkSoft, weight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StepBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.sandDeep, width: 1.5),
        ),
        child: Center(child: Text(label, style: AppText.fredoka(18, AppColors.ink))),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sandDeep,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppText.fredoka(17, AppColors.ink)),
          const SizedBox(height: 2),
          Text(label, style: AppText.dmSans(11, AppColors.inkSoft)),
        ],
      ),
    );
  }
}

class _InviteChip extends StatelessWidget {
  final String code;
  const _InviteChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite code copied!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.sandDeep,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(code, style: AppText.fredoka(13, AppColors.ink)),
      ),
    );
  }
}
