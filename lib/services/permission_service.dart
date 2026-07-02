// Requests activity recognition (Android) / motion+fitness (iOS) permissions
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  Future<bool> requestStepPermission() async {
    // activityRecognition covers Android; iOS uses a different entitlement
    // but permission_handler maps both correctly
    final status = await ph.Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> checkStepPermission() async {
    final status = await ph.Permission.activityRecognition.status;
    return status.isGranted;
  }

  Future<void> openAppSettings() => ph.openAppSettings();
}
