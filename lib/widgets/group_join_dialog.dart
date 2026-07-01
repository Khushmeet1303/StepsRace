// Bottom sheet modal: create a new group or join by invite code
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/group_provider.dart';

class GroupJoinDialog extends StatefulWidget {
  final String uid;
  const GroupJoinDialog({super.key, required this.uid});

  @override
  State<GroupJoinDialog> createState() => _GroupJoinDialogState();
}

class _GroupJoinDialogState extends State<GroupJoinDialog> {
  bool _isJoin = true;
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final group = context.read<GroupProvider>();
    if (_isJoin) {
      final code = _codeCtrl.text.trim().toUpperCase();
      if (code.isEmpty) return;
      final ok = await group.joinGroup(code, widget.uid);
      if (mounted) {
        if (ok) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(group.error ?? 'Code not found'), backgroundColor: AppColors.coral),
          );
          group.clearError();
        }
      }
    } else {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) return;
      await group.createGroup(name, widget.uid);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.sandDeep,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Text('Race Together!', style: AppText.fredoka(22, AppColors.coralDark)),
          const SizedBox(height: 20),

          // Toggle
          Row(children: [
            _ToggleBtn('Join Group', _isJoin, () => setState(() => _isJoin = true)),
            const SizedBox(width: 10),
            _ToggleBtn('Create Group', !_isJoin, () => setState(() => _isJoin = false)),
          ]),
          const SizedBox(height: 20),

          if (_isJoin) ...[
            Text(
              'Enter the 6-character invite code shared by a friend.',
              style: AppText.dmSans(13, AppColors.inkSoft),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: AppText.fredoka(22, AppColors.ink),
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'ABC123',
                counterText: '',
              ),
            ),
          ] else ...[
            Text(
              'Give your group a fun name — your friends will join with an invite code.',
              style: AppText.dmSans(13, AppColors.inkSoft),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Weekend Walkers'),
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: group.loading ? null : _submit,
              child: group.loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_isJoin ? 'Join Group' : 'Create Group',
                      style: AppText.fredoka(16, AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.coral : AppColors.sandDeep,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: AppText.dmSans(13, active ? AppColors.white : AppColors.inkSoft,
                    weight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
