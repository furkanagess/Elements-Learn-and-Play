import 'dart:async';
import 'dart:developer' as developer;

/// Performance monitoring for animations
/// Tracks memory usage, frame drops, and animation performance
class AnimationPerformanceMonitor {
  static final AnimationPerformanceMonitor _instance =
      AnimationPerformanceMonitor._internal();
  factory AnimationPerformanceMonitor() => _instance;
  AnimationPerformanceMonitor._internal();

  final Map<String, AnimationMetrics> _metrics = {};
  final List<PerformanceAlert> _alerts = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Start monitoring animation performance
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPerformance();
    });

    developer.log('Animation performance monitoring started');
  }

  /// Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;

    developer.log('Animation performance monitoring stopped');
  }

  /// Record animation start
  void recordAnimationStart(String key, MonitoringAnimationType type) {
    final metrics = _metrics[key] ?? AnimationMetrics(key: key, type: type);
    metrics.startTime = DateTime.now();
    metrics.isRunning = true;
    _metrics[key] = metrics;
  }

  /// Record animation end
  void recordAnimationEnd(String key) {
    final metrics = _metrics[key];
    if (metrics != null) {
      metrics.endTime = DateTime.now();
      metrics.isRunning = false;
      metrics.duration = metrics.endTime!.difference(metrics.startTime!);
      metrics.totalRuns++;

      // Check for performance issues
      _checkAnimationPerformance(metrics);
    }
  }

  /// Record frame drop
  void recordFrameDrop(String key) {
    final metrics = _metrics[key];
    if (metrics != null) {
      metrics.frameDrops++;
    }
  }

  /// Record memory usage
  void recordMemoryUsage(String key, int memoryBytes) {
    final metrics = _metrics[key];
    if (metrics != null) {
      metrics.memoryUsage = memoryBytes;
      metrics.maxMemoryUsage = metrics.maxMemoryUsage > memoryBytes
          ? metrics.maxMemoryUsage
          : memoryBytes;
    }
  }

  /// Get performance metrics for a specific animation
  AnimationMetrics? getMetrics(String key) {
    return _metrics[key];
  }

  /// Get all performance metrics
  Map<String, AnimationMetrics> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Get performance alerts
  List<PerformanceAlert> getAlerts() {
    return List.unmodifiable(_alerts);
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _alerts.clear();
  }

  /// Check overall performance
  void _checkPerformance() {
    final now = DateTime.now();
    final runningAnimations = _metrics.values.where((m) => m.isRunning).length;
    final totalMemoryUsage = _metrics.values.fold<int>(
      0,
      (sum, m) => sum + (m.memoryUsage ?? 0),
    );

    // Check for too many running animations
    if (runningAnimations > 10) {
      _addAlert(
        PerformanceAlert(
          type: AlertType.tooManyAnimations,
          message: 'Too many running animations: $runningAnimations',
          timestamp: now,
          severity: AlertSeverity.warning,
        ),
      );
    }

    // Check for high memory usage
    if (totalMemoryUsage > 50 * 1024 * 1024) {
      // 50MB
      _addAlert(
        PerformanceAlert(
          type: AlertType.highMemoryUsage,
          message:
              'High memory usage: ${(totalMemoryUsage / 1024 / 1024).toStringAsFixed(1)}MB',
          timestamp: now,
          severity: AlertSeverity.warning,
        ),
      );
    }

    // Check for stuck animations
    for (final metrics in _metrics.values) {
      if (metrics.isRunning &&
          metrics.startTime != null &&
          now.difference(metrics.startTime!).inSeconds > 10) {
        _addAlert(
          PerformanceAlert(
            type: AlertType.stuckAnimation,
            message: 'Animation stuck: ${metrics.key}',
            timestamp: now,
            severity: AlertSeverity.error,
          ),
        );
      }
    }
  }

  /// Check individual animation performance
  void _checkAnimationPerformance(AnimationMetrics metrics) {
    // Check for slow animations
    if (metrics.duration != null && metrics.duration!.inMilliseconds > 2000) {
      _addAlert(
        PerformanceAlert(
          type: AlertType.slowAnimation,
          message:
              'Slow animation: ${metrics.key} (${metrics.duration!.inMilliseconds}ms)',
          timestamp: DateTime.now(),
          severity: AlertSeverity.warning,
        ),
      );
    }

    // Check for high frame drops
    if (metrics.frameDrops > 5) {
      _addAlert(
        PerformanceAlert(
          type: AlertType.highFrameDrops,
          message:
              'High frame drops: ${metrics.key} (${metrics.frameDrops} drops)',
          timestamp: DateTime.now(),
          severity: AlertSeverity.warning,
        ),
      );
    }
  }

  /// Add performance alert
  void _addAlert(PerformanceAlert alert) {
    _alerts.add(alert);

    // Keep only last 100 alerts
    if (_alerts.length > 100) {
      _alerts.removeAt(0);
    }

    // Log critical alerts
    if (alert.severity == AlertSeverity.error) {
      developer.log(
        'Animation Performance Alert: ${alert.message}',
        name: 'AnimationPerformance',
        level: 1000, // Error level
      );
    }
  }

  /// Get performance summary
  PerformanceSummary getSummary() {
    final totalAnimations = _metrics.length;
    final runningAnimations = _metrics.values.where((m) => m.isRunning).length;
    final totalRuns = _metrics.values.fold<int>(
      0,
      (sum, m) => sum + m.totalRuns,
    );
    final totalFrameDrops = _metrics.values.fold<int>(
      0,
      (sum, m) => sum + m.frameDrops,
    );
    final totalMemoryUsage = _metrics.values.fold<int>(
      0,
      (sum, m) => sum + (m.memoryUsage ?? 0),
    );
    final maxMemoryUsage = _metrics.values.fold<int>(
      0,
      (sum, m) => sum + m.maxMemoryUsage,
    );

    return PerformanceSummary(
      totalAnimations: totalAnimations,
      runningAnimations: runningAnimations,
      totalRuns: totalRuns,
      totalFrameDrops: totalFrameDrops,
      totalMemoryUsage: totalMemoryUsage,
      maxMemoryUsage: maxMemoryUsage,
      alerts: _alerts.length,
      criticalAlerts: _alerts
          .where((a) => a.severity == AlertSeverity.error)
          .length,
    );
  }
}

/// Animation performance metrics
class AnimationMetrics {
  final String key;
  final MonitoringAnimationType type;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  bool isRunning = false;
  int totalRuns = 0;
  int frameDrops = 0;
  int? memoryUsage;
  int maxMemoryUsage = 0;

  AnimationMetrics({required this.key, required this.type});
}

/// Performance alert
class PerformanceAlert {
  final AlertType type;
  final String message;
  final DateTime timestamp;
  final AlertSeverity severity;

  PerformanceAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

/// Performance summary
class PerformanceSummary {
  final int totalAnimations;
  final int runningAnimations;
  final int totalRuns;
  final int totalFrameDrops;
  final int totalMemoryUsage;
  final int maxMemoryUsage;
  final int alerts;
  final int criticalAlerts;

  PerformanceSummary({
    required this.totalAnimations,
    required this.runningAnimations,
    required this.totalRuns,
    required this.totalFrameDrops,
    required this.totalMemoryUsage,
    required this.maxMemoryUsage,
    required this.alerts,
    required this.criticalAlerts,
  });
}

/// Alert types
enum AlertType {
  tooManyAnimations,
  highMemoryUsage,
  stuckAnimation,
  slowAnimation,
  highFrameDrops,
}

/// Alert severity levels
enum AlertSeverity { info, warning, error }

/// Animation types for monitoring
enum MonitoringAnimationType { fade, slide, scale, rotation, custom }
