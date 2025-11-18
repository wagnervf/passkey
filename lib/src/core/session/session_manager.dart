class SessionManager {
  static DateTime lastActivity = DateTime.now();
  static const Duration timeout = Duration(minutes: 5);

  static void updateActivity() {
    lastActivity = DateTime.now();
  }

  static bool isExpired() {
    return DateTime.now().difference(lastActivity) > timeout;
  }
}
