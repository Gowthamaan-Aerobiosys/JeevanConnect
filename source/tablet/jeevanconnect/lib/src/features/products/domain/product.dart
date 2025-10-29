import '../../workspace/workspace.dart' show Workspace;

class Product {
  String productName;
  String modelName;
  String serialNumber;
  String lotNumber;
  DateTime manufacturedOn;
  bool active;
  Workspace workspace;
  String batterySerialNumber;
  DateTime batteryManufacturingDate;
  String softwareVersion;
  String status;
  bool onlineStatus;
  bool serviceStatus;
  String? location;
  String? department;
  DateTime createdAt;
  DateTime lastModified;

  Product(
      {required this.productName,
      required this.modelName,
      required this.serialNumber,
      required this.manufacturedOn,
      required this.lotNumber,
      required this.active,
      required this.workspace,
      required this.batterySerialNumber,
      required this.batteryManufacturingDate,
      required this.softwareVersion,
      required this.status,
      required this.onlineStatus,
      required this.serviceStatus,
      required this.location,
      required this.department,
      required this.createdAt,
      required this.lastModified});

  factory Product.fromJson(dynamic json) {
    final workspace = Workspace.fromJson(json['workspace']);

    return Product(
      productName: json['product_name'],
      modelName: json['model_name'],
      serialNumber: json['serial_number'],
      manufacturedOn: DateTime.parse(json['manufactured_on']),
      lotNumber: json['lot_number'],
      workspace: workspace,
      batterySerialNumber: json['battery_serial_number'],
      softwareVersion: json['software_version'],
      active: json['active'],
      batteryManufacturingDate:
          DateTime.parse(json['battery_manufacturing_date']),
      createdAt: DateTime.parse(json['created_at']),
      lastModified: DateTime.parse(json['modified_at']),
      status: json['status'],
      onlineStatus: json['is_online'],
      serviceStatus: json['is_on_service'],
      location: json['location'],
      department: json['department'],
    );
  }

  bool get isActive => active;
}
