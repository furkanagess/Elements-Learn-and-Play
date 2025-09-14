# Unified Data Service System

## Overview

The Unified Data Service System replaces the previous mixin-based approach with a more performant, centralized data management solution. This system provides caching, error handling, and state management for API calls across the application.

## Architecture

### 🏗️ **Core Components**

1. **`DataService`** - Singleton service for API calls with caching
2. **`DataLoadingState`** - State management for loading, error, and data states
3. **`DataProviderMixin`** - Optional mixin for views that need state management
4. **`DataLoadingWidget`** - Widget for handling different loading states

### 🚀 **Key Features**

- **Caching**: Automatic caching of API responses
- **Error Handling**: Built-in error state management
- **Performance**: Reduced API calls through intelligent caching
- **State Management**: Centralized loading state handling
- **Memory Efficiency**: Singleton pattern prevents multiple instances

## Usage Examples

### Basic Data Fetching

```dart
class MyView extends StatefulWidget {
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  final DataService _dataService = DataService();
  late Future<List<PeriodicElement>> _elementList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _elementList = _dataService.fetchElements(widget.apiType);

    // Simulate loading delay for better UX
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    return FutureBuilder<List<PeriodicElement>>(
      future: _elementList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ElementCard(element: snapshot.data![index]);
            },
          );
        }
        return const ErrorWidget();
      },
    );
  }
}
```

### With State Management Mixin

```dart
class MyView extends StatefulWidget {
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> with DataProviderMixin {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await fetchElementsWithState(widget.apiType);
  }

  @override
  Widget build(BuildContext context) {
    return DataLoadingWidget(
      loadingState: loadingState,
      dataBuilder: (data) {
        final elements = data as List<PeriodicElement>;
        return ListView.builder(
          itemCount: elements.length,
          itemBuilder: (context, index) {
            return ElementCard(element: elements[index]);
          },
        );
      },
      errorBuilder: (error) {
        return Center(
          child: Column(
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Migration Guide

### Before (Mixin-based)

```dart
class _ElementsListViewState extends State<ElementsListView>
    with ElementsListViewMixin {
  // Mixin handles all data fetching logic
  // No direct control over loading states
  // Limited error handling
}
```

### After (Direct Data Service)

```dart
class _ElementsListViewState extends State<ElementsListView> {
  final DataService _dataService = DataService();
  late Future<List<PeriodicElement>> _elementList;
  bool _isLoading = true;

  void _initializeData() {
    _elementList = _dataService.fetchElements(widget.apiType);
    // Direct control over loading states
    // Better error handling
    // Caching benefits
  }
}
```

## API Reference

### DataService

#### Methods

```dart
// Fetch elements with caching
Future<List<PeriodicElement>> fetchElements(String apiType)

// Fetch info with caching
Future<List<Info>> fetchInfo(String apiType)

// Clear cache for specific API type
void clearCache(String apiType)

// Clear all caches
void clearAllCaches()

// Check if data is cached
bool isCached(String apiType, {bool isElement = true})
```

### DataLoadingState

#### Properties

```dart
bool isLoading    // Loading state
String? error     // Error message
Object? data      // Loaded data
bool hasError     // Has error
bool hasData      // Has data
```

#### Methods

```dart
DataLoadingState copyWith({
  bool? isLoading,
  String? error,
  Object? data,
})
```

### DataProviderMixin

#### Methods

```dart
// Update loading state
void updateLoadingState(DataLoadingState newState)

// Set loading state
void setLoading(bool isLoading)

// Set error state
void setError(String error)

// Set data state
void setData(Object data)

// Fetch elements with state management
Future<List<PeriodicElement>> fetchElementsWithState(String apiType)

// Fetch info with state management
Future<List<Info>> fetchInfoWithState(String apiType)

// Clear cache
void clearCache(String apiType)
```

### DataLoadingWidget

#### Constructor

```dart
DataLoadingWidget({
  required DataLoadingState loadingState,
  required Widget Function(Object data) dataBuilder,
  Widget Function(String error)? errorBuilder,
  Widget? loadingWidget,
})
```

## Performance Benefits

### 🎯 **Caching**

- **Reduced API Calls**: Data is cached and reused
- **Faster Loading**: Subsequent loads are instant
- **Network Efficiency**: Less bandwidth usage

### 🚀 **Memory Management**

- **Singleton Pattern**: Single instance across the app
- **Automatic Cleanup**: Proper disposal of resources
- **Efficient State**: Minimal state management overhead

### 🔧 **Error Handling**

- **Centralized Errors**: Consistent error handling
- **Retry Logic**: Built-in retry mechanisms
- **User Feedback**: Clear error messages

## Best Practices

### ✅ **Do**

- Use DataService for all API calls
- Implement proper loading states
- Handle errors gracefully
- Use caching for frequently accessed data
- Clear cache when data becomes stale

### ❌ **Don't**

- Create multiple DataService instances
- Ignore loading states
- Skip error handling
- Cache sensitive or frequently changing data
- Forget to dispose of resources

## File Structure

```
lib/core/services/data/
├── data_service.dart    # Main data service
└── README.md           # This documentation
```

## Testing

### Unit Tests

```dart
test('DataService caches elements correctly', () async {
  final service = DataService();

  // First call
  final elements1 = await service.fetchElements('metals');

  // Second call should use cache
  final elements2 = await service.fetchElements('metals');

  expect(identical(elements1, elements2), true);
  expect(service.isCached('metals'), true);
});
```

### Widget Tests

```dart
testWidgets('DataLoadingWidget shows loading state', (tester) async {
  const loadingState = DataLoadingState(isLoading: true);

  await tester.pumpWidget(
    MaterialApp(
      home: DataLoadingWidget(
        loadingState: loadingState,
        dataBuilder: (data) => Text('Data: $data'),
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Future Enhancements

- [ ] Add offline support
- [ ] Implement data synchronization
- [ ] Add background refresh
- [ ] Create data persistence
- [ ] Add analytics tracking
- [ ] Implement data compression

This unified data service system provides a robust, performant solution for managing API calls and data fetching across the application while ensuring consistency and ease of use.
