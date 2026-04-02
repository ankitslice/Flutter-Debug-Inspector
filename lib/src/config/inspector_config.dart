/// Optional configuration for what the inspector records and when.
class InspectorConfig {
  const InspectorConfig({
    this.isHybridApp = false,
    this.enabledInRelease = false,
  });

  /// Hint for UI; hybrid mode is normally set from Android on
  /// `FlutterDebugRegistry.isHybridApp`.
  final bool isHybridApp;

  /// When false (default), host apps should only install observers in debug/profile.
  final bool enabledInRelease;
}
