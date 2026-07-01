// Real-time leaderboard ranking group members by % of goal completed
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/user_profile.dart';
import '../../widgets/group_join_dialog.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final group = context.watch<GroupProvider>();
    final uid = auth.user?.uid ?? '';

    final sorted = [...group.members]
      ..sort((a, b) => b.pct.compareTo(a.pct));

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's leaderboard", style: AppText.fredoka(22, AppColors.ink)),
              const SizedBox(height: 4),
              Text(
                group.inGroup ? group.group!.name : 'Join a group to race',
                style: AppText.dmSans(13, AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              if (!group.inGroup)
                _NoGroupCard(uid: uid)
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (_, i) => _LeaderRow(
                      rank: i + 1,
                      member: sorted[i],
                      isMe: sorted[i].uid == uid,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final UserProfile member;
  final bool isMe;

  const _LeaderRow({required this.rank, required this.member, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = kAvatarColors[member.color] ?? AppColors.coral;
    final pct = (member.pct * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.coralLight : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: AppColors.coral, width: 1.5) : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 22,
            child: Text(
              rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank',
              style: AppText.fredoka(15, AppColors.inkSoft),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          // Avatar circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                initials(member.name),
                style: AppText.fredoka(13, Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member.name}${isMe ? ' (you)' : ''}',
                  style: AppText.dmSans(14, AppColors.ink, weight: FontWeight.w700),
                ),
                Text(
                  '${formatSteps(member.steps)} steps',
                  style: AppText.dmSans(11, AppColors.inkSoft),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: member.pct,
                    minHeight: 6,
                    backgroundColor: AppColors.sandDeep,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('$pct%', style: AppText.fredoka(15, AppColors.ink)),
        ],
      ),
    );
  }
}

class _NoGroupCard extends StatelessWidget {
  final String uid;
  const _NoGroupCard({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Race with friends!', style: AppText.fredoka(20, AppColors.ink)),
            const SizedBox(height: 8),
            Text(
              'Join or create a group to see everyone on the leaderboard.',
              style: AppText.dmSans(14, AppColors.inkSoft),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => GroupJoinDialog(uid: uid),
              ),
              child: Text('Join a Group', style: AppText.fredoka(15, AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
