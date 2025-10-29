part of "paged_datatable.dart";

class RefreshTable<K extends Comparable<K>, T> extends StatefulWidget {
  const RefreshTable({super.key});

  @override
  State<RefreshTable> createState() => _RefreshTableState<K, T>();
}

class _RefreshTableState<K extends Comparable<K>, T>
    extends State<RefreshTable<K, T>> {
  late final theme = PagedDataTableTheme.of(context);
  late final controller = TableControllerProvider.of<K, T>(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        IconButton(
          splashRadius: 20,
          tooltip: "Refresh",
          onPressed: () => controller.refresh(fromStart: false),
          icon: const Icon(Icons.refresh_outlined),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onChanged);
  }
}

class PageSizeSelector<K extends Comparable<K>, T> extends StatefulWidget {
  const PageSizeSelector({super.key});

  @override
  State<PageSizeSelector> createState() => _PageSizeSelectorState<K, T>();
}

class _PageSizeSelectorState<K extends Comparable<K>, T>
    extends State<PageSizeSelector<K, T>> {
  late final theme = PagedDataTableTheme.of(context);
  late final controller = TableControllerProvider.of<K, T>(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    assert(controller._pageSizes != null,
        "PageSizeSelector widget can be used only if the pageSizes property is set.");

    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          "Rows per page",
          style: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: AppPalette.black),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: DropdownButtonFormField<int>(
            value: controller.pageSize,
            items: controller._pageSizes!
                .map((pageSize) => DropdownMenuItem(
                    value: pageSize, child: Text(pageSize.toString())))
                .toList(growable: false),
            onChanged: controller._state == _TableState.fetching
                ? null
                : (newPageSize) {
                    if (newPageSize != null) {
                      controller.pageSize = newPageSize;
                    }
                  },
            style: theme.footerTextStyle.copyWith(fontSize: 14),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppPalette.greyC2)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppPalette.greyC2)),
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onChanged);
  }
}

class TotalItems<K extends Comparable<K>, T> extends StatefulWidget {
  const TotalItems({super.key});

  @override
  State<TotalItems> createState() => _TotalItemsState<K, T>();
}

class _TotalItemsState<K extends Comparable<K>, T>
    extends State<TotalItems<K, T>> {
  late final theme = PagedDataTableTheme.of(context);
  late final controller = TableControllerProvider.of<K, T>(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text("Showing ${controller._totalItems} elements"),
        const SizedBox(width: 10),
      ],
    );
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onChanged);
  }
}

class CurrentPage<K extends Comparable<K>, T> extends StatefulWidget {
  const CurrentPage({super.key});

  @override
  State<CurrentPage> createState() => _CurrentPageState<K, T>();
}

class _CurrentPageState<K extends Comparable<K>, T>
    extends State<CurrentPage<K, T>> {
  late final theme = PagedDataTableTheme.of(context);
  late final controller = TableControllerProvider.of<K, T>(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          "Page ${controller._currentPageIndex + 1}/${(controller._totalItems ~/ controller._currentPageSize) + 1}",
          style: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: AppPalette.black),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onChanged);
  }
}

class NavigationButtons<K extends Comparable<K>, T> extends StatefulWidget {
  const NavigationButtons({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationButtonsState<K, T>();
}

class _NavigationButtonsState<K extends Comparable<K>, T>
    extends State<NavigationButtons<K, T>> {
  late final theme = PagedDataTableTheme.of(context);
  late final controller = TableControllerProvider.of<K, T>(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addListener(_onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        IconButton(
          tooltip: "Previous page",
          splashRadius: 20,
          icon: const Icon(Icons.keyboard_arrow_left_rounded),
          onPressed: (controller.hasPreviousPage &&
                  controller._state != _TableState.fetching)
              ? controller.previousPage
              : null,
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: "Next page",
          splashRadius: 20,
          icon: const Icon(Icons.keyboard_arrow_right_rounded),
          onPressed: (controller.hasNextPage &&
                  controller._state != _TableState.fetching)
              ? controller.nextPage
              : null,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onChanged);
  }
}
