import 'package:flutter/material.dart';

import '../../../config/presentation/app_palette.dart';
import '../../../packages/pagenated_table/paged_datatable.dart';
import '../../../routing/routes.dart';
import '../../../shared/presentation/components/button.dart';
import '../../../shared/presentation/components/white_space.dart';
import '../../../shared/presentation/widgets/binary_status_indicator.dart';
import '../../authentication/authentication.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({super.key});

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  final tableController = PagedDataTableController<String, Product>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedDataTableTheme(
      data: PagedDataTableThemeData(
        backgroundColor: AppPalette.greyS2,
        footerTextStyle: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: AppPalette.black),
        rowColor: (index) =>
            index.isEven ? const Color.fromARGB(255, 235, 231, 231) : null,
      ),
      child: PagedDataTable<String, Product>(
        controller: tableController,
        initialPageSize: 100,
        configuration: const PagedDataTableConfiguration(),
        pageSizes: const [10, 20, 50, 100],
        fetcher: (pageSize, sortModel, filterModel, pageToken) async {
          final products = await ProductRepository().getProducts();
          return (products.items, products.nextPageToken);
        },
        filters: const [],
        fixedColumnCount: 2,
        filterBarChild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (AuthenticationRepository().isAdminUser)
              Button(
                hoverColor: null,
                onPressed: () {
                  context.push(Routes.registerProduct, rootNavigator: true);
                },
                minWidth: 150,
                child: Text(
                  "Register Product",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            WhiteSpace.w6,
            PopupMenuButton(
                icon: const Icon(Icons.more_vert_outlined),
                itemBuilder: (context) => <PopupMenuEntry>[]),
            WhiteSpace.w6,
          ],
        ),
        columns: [
          RowSelectorColumn(),
          TableColumn(
            title: const Text("Serial Number"),
            cellBuilder: (context, item, index) => TextButton(
                onPressed: () {
                  context.push(Routes.product,
                      arguments: {'product': item}, rootNavigator: true);
                },
                child: Text(
                  item.serialNumber,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppPalette.pink, fontWeight: FontWeight.w800),
                )),
            size: const FractionalColumnSize(.2),
          ),
          TableColumn(
            title: const Text("Lot Number"),
            cellBuilder: (context, item, index) => Text(
              item.lotNumber,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.2),
          ),
          TableColumn(
            title: const Text("Product"),
            cellBuilder: (context, item, index) => Text(
              item.productName,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const FractionalColumnSize(.35),
          ),
          TableColumn(
            title: const Text("Status"),
            cellBuilder: (context, item, index) => BinaryStatusIndicator(
                isActive: item.isActive, labels: ("Active", "Inactive")),
            size: const FractionalColumnSize(.3),
          ),
          TableColumn(
            title: const Text("Workspace"),
            cellBuilder: (context, item, index) => Text(
              item.workspace.name,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppPalette.black),
            ),
            size: const RemainingColumnSize(),
          ),
        ],
      ),
    );
  }
}
