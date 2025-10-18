import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/core/services/data/data_service.dart';
import 'package:elements_app/feature/view/elementsList/elements_progressive_loading_view.dart';
import 'package:elements_app/feature/view/elementsList/widget/widgets.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/core/mixin/animation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ElementsListView extends StatefulWidget {
  final String apiType;
  final String title;
  const ElementsListView({
    super.key,
    required this.apiType,
    required this.title,
  });

  @override
  State<ElementsListView> createState() => _ElementsListViewState();
}

class _ElementsListViewState extends State<ElementsListView>
    with TickerProviderStateMixin, AnimationMixin<ElementsListView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<PeriodicElement> _filteredElements = [];
  bool _isGridView = false;
  String _searchQuery = '';

  // Data service and state
  final DataService _dataService = DataService();
  late Future<List<PeriodicElement>> _elementList;
  bool _isLoading = true;
  bool _isInitialized = false;

  // Animation controllers
  late AnimationController _viewTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScrollChanged);

    // Initialize animation controllers
    _viewTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _viewTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _viewTransitionController,
            curve: Curves.easeInOut,
          ),
        );

    // Start animation
    _viewTransitionController.forward();

    // Initialize data fetching
    _initializeData();
  }

  void _initializeData() {
    // Prevent multiple initializations
    if (_isInitialized) return;
    _isInitialized = true;

    // Clear cache for halogens to ensure fresh data
    if (widget.apiType.contains('halogens')) {
      _dataService.clearHalogensCache();
    }

    _elementList = _dataService.fetchElements(widget.apiType);

    // Remove artificial delay to prevent double loading
    _elementList
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        })
        .catchError((error) {
          // Handle error and still show content
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _viewTransitionController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _onScrollChanged() {
    // Search bar is now always visible in app bar
  }

  void _toggleViewMode() {
    // Reverse animation first, then change view mode
    _viewTransitionController.reverse().then((_) {
      setState(() {
        _isGridView = !_isGridView;
      });
      // Forward animation for new view
      _viewTransitionController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Progressive loading with skeleton cards for better UX
    if (_isLoading) {
      return ElementsProgressiveLoadingView(
        apiType: widget.apiType,
        title: widget.title,
        elementList: _elementList,
        searchController: _searchController,
        searchQuery: _searchQuery,
        onSearchChanged: _onSearchChanged,
        onClearSearch: _onClearSearch,
        onFilterPressed: () => _showFilterModal(context),
        isGridView: _isGridView,
        onToggleViewMode: _toggleViewMode,
      );
    }

    return AppScaffold(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Navigator.pop(context);
          },
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: ElementsListAppBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
            onFilterPressed: () => _showFilterModal(context),
          ),
          body: Column(
            children: [
              // Content
              Expanded(
                child: fadeSlideInWidget(
                  child: FutureBuilder<List<PeriodicElement>>(
                    future: _elementList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(); // Boş container döndürüyoruz çünkü ana loading zaten gösteriliyor
                      } else {
                        final elements = snapshot.data ?? [];
                        _filteredElements = _filterElements(elements);

                        if (_filteredElements.isEmpty &&
                            _searchQuery.isNotEmpty) {
                          return const EmptySearchState();
                        }

                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // View Mode Toggle
                                ViewModeToggle(
                                  isGridView: _isGridView,
                                  onToggle: _toggleViewMode,
                                ),
                                const SizedBox(height: 20),

                                // Elements Grid/List with animation
                                AnimatedBuilder(
                                  animation: _viewTransitionController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: _isGridView
                                            ? ElementsGridView(
                                                elements: _filteredElements,
                                              )
                                            : ElementsListWidget(
                                                elements: _filteredElements,
                                              ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 100), // Bottom padding
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // Modern Floating Action Button
          floatingActionButton: const ElementsListFAB(),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(onSortSelected: _sortElements),
    );
  }

  void _sortElements(String criteria) {
    setState(() {
      switch (criteria) {
        case 'number':
          _filteredElements.sort(
            (a, b) => (a.number ?? 0).compareTo(b.number ?? 0),
          );
          break;
        case 'name':
          _filteredElements.sort((a, b) {
            final aName = context.read<LocalizationProvider>().isTr
                ? (a.trName ?? '')
                : (a.enName ?? '');
            final bName = context.read<LocalizationProvider>().isTr
                ? (b.trName ?? '')
                : (b.enName ?? '');
            return aName.compareTo(bName);
          });
          break;
        case 'weight':
          _filteredElements.sort((a, b) {
            final aWeight =
                double.tryParse(a.weight?.replaceAll(',', '.') ?? '0') ?? 0;
            final bWeight =
                double.tryParse(b.weight?.replaceAll(',', '.') ?? '0') ?? 0;
            return aWeight.compareTo(bWeight);
          });
          break;
      }
    });
  }

  List<PeriodicElement> _filterElements(List<PeriodicElement> elements) {
    if (_searchQuery.isEmpty) {
      return elements;
    }

    final query = _searchQuery.toLowerCase();
    return elements.where((element) {
      final name = context.read<LocalizationProvider>().isTr
          ? element.trName?.toLowerCase() ?? ''
          : element.enName?.toLowerCase() ?? '';
      final symbol = element.symbol?.toLowerCase() ?? '';
      final number = element.number?.toString() ?? '';

      return name.contains(query) ||
          symbol.contains(query) ||
          number.contains(query);
    }).toList();
  }
}
