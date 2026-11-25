import 'dart:async';

/// Keeps the vault session alive only while the user is active in the app.
class SessionManager {
  static const Duration timeout = Duration(minutes: 5);

  static DateTime lastActivity = DateTime.now();
  static Timer? _idleTimer;
  static Future<void> Function()? _onExpired;
  static bool _active = false;
  static bool _foreground = true;
  static bool _systemPickerOpen = false;
  static Future<void>? _expiryInProgress;

  static bool get isActive => _active;
  static bool get isForeground => _foreground;

  static void setForeground(bool foreground) {
    _foreground = foreground;
    if (foreground && _systemPickerOpen) {
      _systemPickerOpen = false;
      if (isExpired()) unawaited(expire());
    }
  }

  /// A native file picker may pause the Flutter activity briefly. Keep the
  /// privacy cover, while allowing the existing idle timeout to protect the vault.
  static void beginSystemPicker() {
    updateActivity();
    _systemPickerOpen = true;
  }

  static void endSystemPicker() {
    if (_foreground) _systemPickerOpen = false;
  }

  static Future<void> background({bool force = false}) {
    _foreground = false;
    if (!force && _systemPickerOpen && !isExpired()) return Future.value();
    return expire();
  }

  static void configure({required Future<void> Function() onExpired}) {
    _onExpired = onExpired;
    if (_active) _scheduleExpiry();
  }

  static void start() {
    if (!_foreground) return;
    _active = true;
    lastActivity = DateTime.now();
    _scheduleExpiry();
  }

  static void updateActivity() {
    if (!_active || !_foreground) return;
    if (isExpired()) {
      unawaited(expire());
      return;
    }
    lastActivity = DateTime.now();
    _scheduleExpiry();
  }

  static bool isExpired() =>
      _active && DateTime.now().difference(lastActivity) >= timeout;

  static Future<void> expire() {
    if (_expiryInProgress != null) return _expiryInProgress!;
    if (!_active) return Future.value();
    _active = false;
    _idleTimer?.cancel();
    _idleTimer = null;
    final callback = _onExpired;
    final future = callback == null ? Future<void>.value() : callback();
    _expiryInProgress = future.whenComplete(() => _expiryInProgress = null);
    return _expiryInProgress!;
  }

  static void stop() {
    _active = false;
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  static void dispose() {
    stop();
    _systemPickerOpen = false;
    _onExpired = null;
  }

  static void _scheduleExpiry() {
    _idleTimer?.cancel();
    if (_onExpired != null) {
      _idleTimer = Timer(timeout, () {
        unawaited(expire());
      });
    }
  }
}
