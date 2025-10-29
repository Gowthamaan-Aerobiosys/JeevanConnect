part of 'paged_datatable.dart';

typedef Fetcher<K extends Comparable<K>, T>
    = FutureOr<(List<T> resultset, K? nextPageToken)> Function(int pageSize,
        SortModel? sortModel, FilterModel filterModel, K? pageToken);

typedef RowChangeListener<K extends Comparable<K>, T> = void Function(
    int index, T item);

final class PagedDataTableController<K extends Comparable<K>, T>
    extends ChangeNotifier {
  final List<T> _currentDataset =
      []; // the current dataset that is being displayed
  final Map<String, FilterState> _filtersState =
      {}; // The list of filters' states
  final Map<int, K> _paginationKeys =
      {}; // it's a map because on not found map will return null, list will throw
  final Set<int> _selectedRows = {}; // The list of selected row indexes
  final GlobalKey<FormState> _filtersFormKey = GlobalKey();
  late final List<int>? _pageSizes;
  late final Fetcher<K, T> _fetcher; // The function used to fetch items
  final Map<_ListenerType, dynamic> _listeners = {
    // The list of special listeners which all are functions

    // Callbacks for row change. The key of the map is the row index, the value the list of listeners for the row
    _ListenerType.rowChange: <int, List<RowChangeListener<K, T>>>{},
  };
  PagedDataTableConfiguration? _configuration;

  Object?
      _currentError; // If something went wrong when fetching items, this is the latest error
  int _totalItems = 0; // the total items in the current dataset
  int _currentPageSize = 0;
  int _currentPageIndex =
      0; // The current index of the page, used to lookup token inside _paginationKeys
  bool _hasNextPage =
      false; // a flag that indicates if there are more pages after the current one
  SortModel? _currentSortModel; // The current sort model of the table
  _TableState _state = _TableState.idle;

  bool get hasNextPage => _hasNextPage;

  bool get hasPreviousPage => _currentPageIndex != 0;

  int get totalItems => _totalItems;

  int get pageSize => _currentPageSize;

  set pageSize(int pageSize) {
    _currentPageSize = pageSize;
    refresh(fromStart: true);
    notifyListeners();
  }

  SortModel? get sortModel => _currentSortModel;

  List<int> get selectedRows => _selectedRows.toList(growable: false);

  List<T> get selectedItems => UnmodifiableListView(
      _selectedRows.map((index) => _currentDataset[index]));

  set sortModel(SortModel? sortModel) {
    _currentSortModel = sortModel;
    refresh(fromStart: true);
    notifyListeners();
  }

  void swipeSortModel([String? columnId]) {
    if (columnId != null && _currentSortModel?.fieldName != columnId) {
      sortModel = SortModel._(fieldName: columnId, descending: false);
      return;
    }

    // Ignore if no sort model
    if (_currentSortModel == null) return;

    if (_currentSortModel!.descending) {
      sortModel = null;
    } else {
      sortModel = SortModel._(
          fieldName: _currentSortModel!.fieldName, descending: true);
    }
  }

  Future<void> nextPage() => _fetch(_currentPageIndex + 1);

  Future<void> previousPage() => _fetch(_currentPageIndex - 1);

  void refresh({bool fromStart = false}) {
    if (fromStart) {
      _paginationKeys.clear();
      _totalItems = 0;
      _fetch();
    } else {
      _fetch(_currentPageIndex);
    }
  }

  void printDebugString() {
    if (kDebugMode) {
      final buf = StringBuffer();
      buf.writeln("TableController<$T>(");
      buf.writeln("   CurrentPageIndex($_currentPageIndex),");
      buf.writeln("   PaginationKeys(${_paginationKeys.values.join(", ")}),");
      buf.writeln("   Error($_currentError)");
      buf.writeln("   CurrentPageSize($_currentPageSize)");
      buf.writeln("   TotalItems($_totalItems)");
      buf.writeln("   State($_state)");
      buf.writeln(")");

      debugPrint(buf.toString());
    }
  }

  void removeRow(T item) {
    final index = _currentDataset.indexOf(item);
    removeRowAt(index);
    _notifyOnRowChanged(index);
  }

  void removeRowAt(int index) {
    if (index >= _totalItems) {
      throw ArgumentError(
          "index cannot be greater than or equals to the total list of items.",
          "index");
    }

    if (index < 0) {
      throw ArgumentError("index cannot be less than zero.", "index");
    }

    _currentDataset.removeAt(index);
    _totalItems--;
    _notifyOnRowChanged(index);
  }

  void insertAt(int index, T value) {
    _currentDataset.insert(index, value);
    _totalItems++;
    _notifyOnRowChanged(index);
  }

  void insert(T value) {
    insertAt(_totalItems, value);
    _notifyOnRowChanged(_totalItems);
  }

  void replace(int index, T value) {
    if (index >= _totalItems) {
      throw ArgumentError(
          "Index cannot be greater than or equals to the total size of the current dataset.",
          "index");
    }

    _currentDataset[index] = value;
    _notifyOnRowChanged(index);
  }

  void selectRow(int index) {
    _selectedRows.add(index);
    _notifyOnRowChanged(index);
  }

  void selectAllRows() {
    final iterable = Iterable<int>.generate(_totalItems);
    _selectedRows.addAll(iterable);
    _notifyRowChangedMany(iterable);
  }

  void unselectAllRows() {
    final selectedRows = _selectedRows.toList(growable: false);
    _selectedRows.clear();
    _notifyRowChangedMany(selectedRows);
  }

  void unselectRow(int index) {
    _selectedRows.remove(index);
    _notifyOnRowChanged(index);
  }

  void toggleRow(int index) {
    if (_selectedRows.contains(index)) {
      _selectedRows.remove(index);
    } else {
      _selectedRows.add(index);
    }
    _notifyOnRowChanged(index);
  }

  void addRowChangeListener(int index, RowChangeListener<K, T> onRowChange) {
    final listeners = _listeners[_ListenerType.rowChange]
        as Map<int, List<RowChangeListener<K, T>>>;
    final listenersForIndex = listeners[index] ?? [];
    listenersForIndex.add(onRowChange);
    listeners[index] = listenersForIndex;
  }

  void removeRowChangeListener(
      int index, RowChangeListener<K, T> rowChangeListener) {
    final listeners = _listeners[_ListenerType.rowChange]
        as Map<int, List<RowChangeListener<K, T>>>;
    final listenersForIndex = listeners[index];
    if (listenersForIndex == null) return;

    int? toRemove;
    for (int i = 0; i < listenersForIndex.length; i++) {
      if (listenersForIndex[i] == rowChangeListener) {
        toRemove = i;
        break;
      }
    }

    if (toRemove != null) listenersForIndex.removeAt(toRemove);
  }

  void removeFilter(String filterId) {
    final filter = _filtersState[filterId];
    if (filter == null) {
      throw ArgumentError("Filter with id $filterId not found.");
    }

    filter.value = null;
    notifyListeners();
    _fetch();
  }

  void removeFilters() {
    _filtersState.forEach((key, value) {
      value.value = null;
    });
    notifyListeners();
    _fetch();
  }

  void applyFilters() {
    if (_filtersState.values.any((element) => element.value != null)) {
      notifyListeners();
      _fetch();
    }
  }

  void setFilter(String filterId, dynamic value) {
    final filterState = _filtersState[filterId];
    if (filterState == null) {
      throw ArgumentError(
          "Filter with id $filterId does not exist.", "filterId");
    }

    filterState.value = value;
    applyFilters();
  }

  void _notifyOnRowChanged(int rowIndex) {
    final rowChangeListeners = (_listeners[_ListenerType.rowChange]
        as Map<int, List<RowChangeListener<K, T>>>);
    final listeners = rowChangeListeners[rowIndex];
    try {
      if (listeners != null) {
        final item = _currentDataset[rowIndex];

        for (final listener in listeners) {
          listener(rowIndex, item);
        }
      }
    } catch (_) {
      listeners?.clear();
      rowChangeListeners.remove(rowIndex);
    } finally {
      notifyListeners();
    }
  }

  void _notifyRowChangedMany(Iterable<int> indexes) {
    final listeners = (_listeners[_ListenerType.rowChange]
        as Map<int, List<RowChangeListener<K, T>>>);
    for (final index in indexes) {
      try {
        final listenerGroup = listeners[index];
        if (listenerGroup != null) {
          final value = _currentDataset[index]!;
          for (final listener in listenerGroup) {
            listener(index, value);
          }
        }
      } catch (_) {
        listeners.remove(index);
      }
    }
    notifyListeners();
  }

  void _init({
    required List<ReadOnlyTableColumn> columns,
    required List<int>? pageSizes,
    required int initialPageSize,
    required Fetcher<K, T> fetcher,
    required List<TableFilter> filters,
    required PagedDataTableConfiguration config,
  }) {
    if (_configuration != null) return;

    assert(columns.isNotEmpty, "columns cannot be empty.");

    _currentPageSize = initialPageSize;
    _pageSizes = pageSizes;
    _configuration = config;
    _fetcher = fetcher;
    _filtersState.addEntries(
        filters.map((filter) => MapEntry(filter.id, filter.createState())));

    // Schedule a fetch
    Future.microtask(_fetch);
  }

  void _reset({required List<ReadOnlyTableColumn> columns}) {
    assert(columns.isNotEmpty, "columns cannot be empty.");

    // Schedule a fetch
    Future.microtask(_fetch);
  }

  Future<void> _fetch([int page = 0]) async {
    _state = _TableState.fetching;
    _selectedRows.clear();
    notifyListeners();

    try {
      final pageToken = _paginationKeys[page];
      final filterModel = FilterModel._(
          _filtersState.map((key, value) => MapEntry(key, value.value)));

      var (items, nextPageToken) =
          await _fetcher(_currentPageSize, sortModel, filterModel, pageToken);
      _hasNextPage = nextPageToken != null;
      _currentPageIndex = page;
      if (nextPageToken != null) {
        _paginationKeys[page + 1] = nextPageToken;
      }

      if (_configuration!.copyItems) {
        items = items.toList();
      }
      _currentDataset.clear();
      _currentDataset.addAll(items);

      _totalItems = items.length;
      _state = _TableState.idle;
      _currentError = null;
      notifyListeners();
    } catch (err, stack) {
      debugPrint("An error occurred trying to fetch a page: $err");
      debugPrint(stack.toString());
      _state = _TableState.error;
      _currentError = err;
      _totalItems = 0;
      _currentDataset.clear();
      notifyListeners();
    }
  }
}

enum _TableState {
  idle,
  fetching,
  error,
}

enum _ListenerType {
  rowChange,
}
