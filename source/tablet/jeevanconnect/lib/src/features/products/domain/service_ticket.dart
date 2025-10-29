import 'product.dart';

class ServiceTicket {
  String ticketId;
  DateTime bookedOn;
  DateTime lastUpdated;
  String status;
  Product ventilator;

  ServiceTicket({
    required this.ticketId,
    required this.bookedOn,
    required this.lastUpdated,
    required this.status,
    required this.ventilator,
  });

  factory ServiceTicket.fromJson(dynamic json) {
    final ventilator = Product.fromJson(json['ventilator']);

    return ServiceTicket(
      ticketId: json['ticket_id'],
      ventilator: ventilator,
      status: json['status'],
      bookedOn: DateTime.parse(json['booked_on']),
      lastUpdated: DateTime.parse(json['updated_at']),
    );
  }
}
