// Requests activity recognition (Android) / motion+fitness (iOS) permissions
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStepPermission() async {
    // activityRecognition covers Android; iOS uses a different entitlement
    // but permission_handler maps both correctly
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> checkStepPermission() async {
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  Future<void> openAppSettings() => openAppSettings();
}
