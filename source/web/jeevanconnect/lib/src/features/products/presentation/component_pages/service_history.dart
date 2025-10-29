import 'package:flutter/material.dart';

import '../../../../config/presentation/app_palette.dart';
import '../../../../packages/pagenated_table/paged_datatable.dart';
import '../../../../shared/domain/date_time_formatter.dart';
import '../../../../shared/presentation/components/white_space.dart';
import '../../../../shared/presentation/widgets/general_status_indicator.dart';
import '../../../../shared/presentation/widgets/sliding_page_parent.dart';
import '../../data/product_repository.dart';
import '../../domain/service_ticket.dart';
import 'service/ticket_page.dart';

class ServiceTicketsTab extends StatefulWidget {
  const ServiceTicketsTab({super.key});

  @override
  State<ServiceTicketsTab> createState() => _ServiceTicketsTabState();
}

class _ServiceTicketsTabState extends State<ServiceTicketsTab> {
  final tableController = PagedDataTableController<String, ServiceTicket>();

  @override
  void dispose() {
    super.dispose();
    tableController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WhiteSpace.all20,
      child: PagedDataTableTheme(
        data: PagedDataTableThemeData(
          backgroundColor: AppPalette.greyS2,
          footerTextStyle: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: AppPalette.black),
          rowColor: (index) =>
              index.isEven ? const Color.fromARGB(255, 235, 231, 231) : null,
        ),
        child: PagedDataTable<String, ServiceTicket>(
          controller: tableController,
          initialPageSize: 100,
          configuration: const PagedDataTableConfiguration(),
          pageSizes: const [10, 20, 50, 100],
          fetcher: (pageSize, sortModel, filterModel, pageToken) async {
            final serviceTickets =
                await ProductRepository().getServiceTickets();
            return (
              serviceTickets.items.reversed.toList(),
              serviceTickets.nextPageToken
            );
          },
          filters: const [],
          fixedColumnCount: 0,
          filterBarChild: null,
          columns: [
            RowSelectorColumn(),
            TableColumn(
              title: const Text("Ticket ID"),
              cellBuilder: (context, item, index) => TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) {
                          return SlidingPage(
                              child: ServiceTicketPage(
                            ticket: item,
                          ));
                        },
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  },
                  child: Text(
                    item.ticketId,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppPalette.pink, fontWeight: FontWeight.w800),
                  )),
              size: const FractionalColumnSize(.2),
            ),
            TableColumn(
              title: const Text("Status"),
              cellBuilder: (context, item, index) => GeneralStatusIndicator(
                  currentValue: item.status,
                  labels: const [
                    'Initiated',
                    'Under review',
                    'In progress',
                    'Closed',
                    'Declined'
                  ],
                  hints: const [
                    'BK',
                    'UR',
                    'IP',
                    'CL',
                    'DL'
                  ],
                  foreGroudColor: const [
                    AppPalette.white,
                    AppPalette.brown,
                    AppPalette.blueS9,
                    AppPalette.greenS8,
                    AppPalette.white,
                  ],
                  backGroudColor: const [
                    AppPalette.orange,
                    AppPalette.amber,
                    AppPalette.blueC1,
                    AppPalette.greenS1,
                    AppPalette.greyC3,
                  ]),
              size: const FractionalColumnSize(.2),
            ),
            TableColumn(
              title: const Text("Booked On"),
              cellBuilder: (context, item, index) => Text(
                DateTimeFormat.getTimeStamp(item.bookedOn),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppPalette.black),
              ),
              size: const FractionalColumnSize(.5),
            ),
            TableColumn(
                title: const Text("Last Updated"),
                cellBuilder: (context, item, index) => Text(
                      DateTimeFormat.getTimeStamp(item.lastUpdated),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: AppPalette.black),
                    ),
                size: const RemainingColumnSize()),
          ],
        ),
      ),
    );
  }
}
