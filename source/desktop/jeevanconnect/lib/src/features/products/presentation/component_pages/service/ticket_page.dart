import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jeevanconnect/src/config/presentation/app_palette.dart';

import '../../../../../packages/timeline/timeline.dart';
import '../../../../../shared/domain/date_time_formatter.dart';
import '../../../../../shared/presentation/components/white_space.dart';
import '../../../../../shared/presentation/widgets/general_status_indicator.dart';
import '../../../data/product_repository.dart';

class ServiceTicketPage extends StatelessWidget {
  final dynamic ticket;
  const ServiceTicketPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.greyC2,
      body: Padding(
        padding: WhiteSpace.all30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Service Ticket - ${ticket.ticketId}",
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            WhiteSpace.b32,
            Row(
              children: [
                WhiteSpace.w56,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                    WhiteSpace.b32,
                    Text(
                      "Booked on",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                    WhiteSpace.b32,
                    Text(
                      "Last updated on",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: AppPalette.greyC3),
                    ),
                  ],
                ),
                WhiteSpace.w56,
                Column(
                  children: [
                    GeneralStatusIndicator(
                        isInTable: true,
                        currentValue: ticket.status,
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
                    WhiteSpace.b32,
                    Text(
                      DateTimeFormat.getTimeStamp(ticket.bookedOn),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    WhiteSpace.b32,
                    Text(
                      DateTimeFormat.getTimeStamp(ticket.lastUpdated),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            WhiteSpace.b32,
            const Divider(),
            WhiteSpace.b32,
            Text(
              "Logs",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            WhiteSpace.b32,
            GetServiceLogs(ticketId: ticket.ticketId)
          ],
        ),
      ),
    );
  }
}

class GetServiceLogs extends StatefulWidget {
  final dynamic ticketId;
  const GetServiceLogs({super.key, required this.ticketId});

  @override
  State<GetServiceLogs> createState() => _GetServiceLogsState();
}

class _GetServiceLogsState extends State<GetServiceLogs> {
  bool isLoading = true;
  List serviceLogs = [];

  _getServiceLogs() async {
    final logs = await ProductRepository().getServiceLog(widget.ticketId);
    serviceLogs = logs.items;
    isLoading = false;
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => setState(() {}));
  }

  @override
  void initState() {
    isLoading = true;
    _getServiceLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CupertinoActivityIndicator(
              radius: 20,
              color: Theme.of(context).primaryColorLight,
            ),
          )
        : Expanded(
            child: Timeline.tileBuilder(
              theme: TimelineThemeData(
                nodePosition: 0.15,
                color: const Color(0xff989898),
                indicatorTheme: const IndicatorThemeData(position: 0),
              ),
              shrinkWrap: true,
              builder: TimelineTileBuilder.connectedFromStyle(
                contentsAlign: ContentsAlign.basic,
                oppositeContentsBuilder: (context, index) => Padding(
                  padding: WhiteSpace.all10,
                  child: Text(
                    serviceLogs[index].timeStamp,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w500, color: AppPalette.grey),
                  ),
                ),
                contentsBuilder: (context, index) => Padding(
                  padding: WhiteSpace.all10,
                  child: Text(
                    serviceLogs[index].content,
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                connectorStyleBuilder: (context, index) =>
                    ConnectorStyle.dashedLine,
                indicatorStyleBuilder: (context, index) =>
                    IndicatorStyle.outlined,
                itemCount: serviceLogs.length,
              ),
            ),
          );
  }
}
