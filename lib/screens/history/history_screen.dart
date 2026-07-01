// Calendar-style history list + streak banner
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/day_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _firestore = FirestoreService();
  List<DayRecord>? _records;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    try {
      final records = await _firestore.getHistory(uid, days: 30);
      if (mounted) setState(() { _records = records; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _calcStreak(List<DayRecord> records) {
    int streak = 0;
    for (final r in records) {
      if (r.goalHit) streak++;
      else break;
    }
    return streak;
  }

  int _calcBestStreak(List<DayRecord> records) {
    int best = 0, current = 0;
    for (final r in records) {
      if (r.goalHit) { current++; best = best < current ? current : best; }
      else current = 0;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.coral,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              Text('Your history', style: AppText.fredoka(22, AppColors.ink)),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppColors.coral))
              else if (_records == null || _records!.isEmpty)
                _EmptyState()
              else ...[
                _StreakBanner(
                  streak: _calcStreak(_records!),
                  bestStreak: _calcBestStreak(_records!),
                ),
                const SizedBox(height: 14),
                ..._records!.map((r) => _HistoryRow(record: r)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int streak;
  final int bestStreak;

  const _StreakBanner({required this.streak, required this.bestStreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.leafLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppText.dmSans(13, AppColors.leafDark),
                children: [
                  TextSpan(
                    text: '$streak day streak',
                    style: AppText.fredoka(17, AppColors.leafDark),
                  ),
                  TextSpan(text: '  —  your best is $bestStreak days'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final DayRecord record;
  const _HistoryRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              friendlyDate(record.date),
              style: AppText.dmSans(13, AppColors.ink, weight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              '${formatSteps(record.steps)} steps',
              style: AppText.dmSans(13, AppColors.inkSoft),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: record.goalHit ? AppColors.leaf : const Color(0xFFD9D4C6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                record.goalHit ? '✓' : '–',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: record.goalHit ? Colors.white : AppColors.inkSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No history yet', style: AppText.fredoka(20, AppColors.ink)),
          const SizedBox(height: 8),
          Text('Start walking to build your streak!',
              style: AppText.dmSans(14, AppColors.inkSoft)),
        ],
      ),
    );
  }
}
