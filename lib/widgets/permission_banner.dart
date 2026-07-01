// Soft nudge banner shown when step permission was denied
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/theme.dart';

class PermissionBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const PermissionBanner({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.amberDark.withOpacity(0.1),
        border: Border.all(color: AppColors.amber, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enable Activity Recognition in Settings for accurate step counting.',
              style: AppText.dmSans(12, AppColors.amberDark),
            ),
          ),
          TextButton(
            onPressed: openAppSettings,
            child: Text('Fix', style: AppText.dmSans(12, AppColors.amber, weight: FontWeight.w700)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.inkSoft),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
