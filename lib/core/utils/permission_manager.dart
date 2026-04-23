import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// Requests SMS reading permission from the user.
  /// Returns true if granted, false if denied or permanently denied.
  static Future<bool> requestSmsPermission() async {
    // 1. Check the current status
    var status = await Permission.sms.status;

    // 2. If it is already granted, we're good to go
    if (status.isGranted) {
      return true;
    }

    // 3. If it is permanently denied, we can't request it again via the app.
    // The user has to manually go to settings.
    if (status.isPermanentlyDenied) {
      // You could trigger a custom dialog here telling them to open settings
      // await openAppSettings();
      return false;
    }

    // 4. Otherwise, trigger the OS pop-up to ask the user
    status = await Permission.sms.request();

    return status.isGranted;
  }
}
