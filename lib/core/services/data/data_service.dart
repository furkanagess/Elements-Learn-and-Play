import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/service/api_service.dart';
import 'package:flutter/material.dart';

/// Unified data service for managing API calls and data fetching
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final ApiService _apiService = ApiService();
  final Map<String, Future<List<PeriodicElement>>> _elementCache = {};
  final Map<String, Future<List<Info>>> _infoCache = {};

  /// Fetch elements with caching
  Future<List<PeriodicElement>> fetchElements(String apiType) {
    if (_elementCache.containsKey(apiType)) {
      return _elementCache[apiType]!;
    }

    final future = _apiService.fetchElements(apiType);
    _elementCache[apiType] = future;
    return future;
  }

  /// Fetch info with caching
  Future<List<Info>> fetchInfo(String apiType) {
    if (_infoCache.containsKey(apiType)) {
      return _infoCache[apiType]!;
    }

    final future = _apiService.fetchInfo(apiType);
    _infoCache[apiType] = future;
    return future;
  }

  /// Clear cache for specific API type
  void clearCache(String apiType) {
    _elementCache.remove(apiType);
    _infoCache.remove(apiType);
  }

  /// Clear cache for halogens specifically
  void clearHalogensCache() {
    _elementCache.remove(
      'https://raw.githubusercontent.com/furkanagess/periodic_table_data_set/master/halogens.json',
    );
  }

  /// Clear all caches
  void clearAllCaches() {
    _elementCache.clear();
    _infoCache.clear();
  }

  /// Check if data is cached
  bool isCached(String apiType, {bool isElement = true}) {
    if (isElement) {
      return _elementCache.containsKey(apiType);
    } else {
      return _infoCache.containsKey(apiType);
    }
  }
}

/// Data loading state management
class DataLoadingState {
  final bool isLoading;
  final String? error;
  final Object? data;

  const DataLoadingState({this.isLoading = false, this.error, this.data});

  DataLoadingState copyWith({bool? isLoading, String? error, Object? data}) {
    return DataLoadingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }

  bool get hasError => error != null;
  bool get hasData => data != null;
}

/// Generic data provider mixin for views
mixin DataProviderMixin<T extends StatefulWidget> on State<T> {
  final DataService _dataService = DataService();
  DataLoadingState _loadingState = const DataLoadingState();

  DataLoadingState get loadingState => _loadingState;

  /// Update loading state
  void updateLoadingState(DataLoadingState newState) {
    if (mounted) {
      setState(() {
        _loadingState = newState;
      });
    }
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    updateLoadingState(_loadingState.copyWith(isLoading: isLoading));
  }

  /// Set error state
  void setError(String error) {
    updateLoadingState(_loadingState.copyWith(isLoading: false, error: error));
  }

  /// Set data state
  void setData(Object data) {
    updateLoadingState(
      _loadingState.copyWith(isLoading: false, error: null, data: data),
    );
  }

  /// Fetch elements with state management
  Future<List<PeriodicElement>> fetchElementsWithState(String apiType) async {
    setLoading(true);
    try {
      final elements = await _dataService.fetchElements(apiType);
      setData(elements);
      return elements;
    } catch (e) {
      setError('Failed to load elements: ${e.toString()}');
      return [];
    }
  }

  /// Fetch info with state management
  Future<List<Info>> fetchInfoWithState(String apiType) async {
    setLoading(true);
    try {
      final info = await _dataService.fetchInfo(apiType);
      setData(info);
      return info;
    } catch (e) {
      setError('Failed to load info: ${e.toString()}');
      return [];
    }
  }

  /// Clear cache
  void clearCache(String apiType) {
    _dataService.clearCache(apiType);
  }
}

/// Widget for handling data loading states
class DataLoadingWidget extends StatelessWidget {
  final DataLoadingState loadingState;
  final Widget Function(Object data) dataBuilder;
  final Widget Function(String error)? errorBuilder;
  final Widget? loadingWidget;

  const DataLoadingWidget({
    super.key,
    required this.loadingState,
    required this.dataBuilder,
    this.errorBuilder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingState.isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (loadingState.hasError) {
      return errorBuilder?.call(loadingState.error!) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${loadingState.error}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry logic can be implemented here
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    if (loadingState.hasData) {
      return dataBuilder(loadingState.data!);
    }

    return const Center(child: Text('No data available'));
  }
}
