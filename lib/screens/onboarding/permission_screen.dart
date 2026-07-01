// Friendly permission explainer before requesting native dialog
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _requesting = false;
  final _permissionService = PermissionService();

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    final granted = await _permissionService.requestStepPermission();
    if (!mounted) return;
    await context.read<AuthProvider>().setPermissionGranted(granted);
    if (!granted) {
      setState(() => _requesting = false);
      _showDeniedDialog();
    }
  }

  void _showDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Permission needed', style: AppText.fredoka(18, AppColors.ink)),
        content: Text(
          'Step Race needs Activity Recognition to count your steps. '
          'You can enable it in Settings → Apps → Step Race → Permissions.',
          style: AppText.dmSans(14, AppColors.inkSoft),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Illustration
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.coralLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🏃', style: TextStyle(fontSize: 60))),
              ),
              const SizedBox(height: 32),
              Text('Count every step', style: AppText.fredoka(30, AppColors.coralDark)),
              const SizedBox(height: 14),
              Text(
                'Step Race uses your phone\'s motion sensor to count your steps automatically — '
                'no manual entry needed!\n\n'
                'We\'ll ask for Activity Recognition (Android) or Motion & Fitness (iOS) '
                'permission so your steps are tracked in the background.',
                style: AppText.dmSans(15, AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // iOS caveat banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.leafLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'On iPhone, steps are cached by iOS and loaded when you open the app. '
                        'Android tracks continuously in the background.',
                        style: AppText.dmSans(12, AppColors.leafDark),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requesting ? null : _requestPermission,
                  child: _requesting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text("Let's Go! 🏁", style: AppText.fredoka(16, AppColors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().setPermissionGranted(false);
                  // Allow skipping — banner on Track screen will nudge later
                  if (mounted) context.read<AuthProvider>().setPermissionGranted(true);
                },
                child: Text('Skip for now', style: AppText.dmSans(13, AppColors.inkSoft)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
