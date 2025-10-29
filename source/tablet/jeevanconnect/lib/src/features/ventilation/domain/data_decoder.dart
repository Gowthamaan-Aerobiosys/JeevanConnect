import 'dart:typed_data';
import 'alerts.dart';
import 'monitoring_alert.dart';

class DataDecoder {
  List<double>? decodeLiveGraphPacket(Uint8List packet) {
    if (packet.isNotEmpty) {
      if (_validatePacket(packet)) {
        List<double> graphValues = [];
        graphValues.add(packet[3].toDouble());
        graphValues.add(_convertTo16Bit(packet[4], packet[5]));
        graphValues.add(_convertTo16Bit(packet[6], packet[7]));
        int cycleBit = (packet[8] & 0x01);
        int breathTypeBit = (packet[8] & 0x02) >> 1;
        graphValues.add(breathTypeBit.toDouble());
        int pauseResumeBit = (packet[8] & 0x08) >> 3;
        int modeByte = (packet[8] & 0xF0) >> 4;
        graphValues.add(pauseResumeBit.toDouble());
        graphValues.add(modeByte.toDouble());
        graphValues.add(cycleBit.toDouble());
        return graphValues;
      }
    }
    return null;
  }

  List<MonitoringAlert>? decodeAlertPacket(Uint8List packet) {
    if (packet.isNotEmpty) {
      if (_validatePacket(packet)) {
        List<MonitoringAlert> alerts = [];
        String alertString = packet
            .sublist(3, 7)
            .map((e) => e.toRadixString(2).padLeft(8, '0'))
            .toList()
            .join();
        for (int i = 0; i < alertString.length; i++) {
          if (alertString[i] == '1') {
            alerts.add(Alerts.monitoringAlerts[i]);
          }
        }
        return alerts;
      }
    }
    return null;
  }

  List<int>? decodeSamplePacket(Uint8List packet) {
    if (packet.isNotEmpty) {
      if (_validatePacket(packet)) {
        List<int> sampledParameterList = [];
        sampledParameterList.add((packet[7] & 0X80) >> 7);
        sampledParameterList.add(packet[7] & 0X7F);
        sampledParameterList.add(packet[8]);
        sampledParameterList.add(packet[5]);
        sampledParameterList.add(packet[6]);
        return sampledParameterList;
      }
    }
    return null;
  }

  List<int>? decodeModePacket(Uint8List packet) {
    if (packet.isNotEmpty) {
      if (_validateModePacket(packet)) {
        return packet.sublist(3, packet.length - 1);
      }
    }
    return null;
  }

  _validatePacket(Uint8List packet) {
    int checkSum = _getCheckSum(packet.sublist(3, packet.length - 1));
    return (checkSum == packet.last) &&
        ((packet[2] & 0X07) == (packet.length - 3));
  }

  _validateModePacket(Uint8List packet) {
    int checkSum = _getCheckSum(packet.sublist(3, packet.length - 1));
    return (checkSum == packet.last) && (packet[2] == (packet.length - 3));
  }

  _convertTo16Bit(int lsb, int msb) {
    int value = (msb << 8) | lsb;
    if ((value & 0X8000) == 0X8000) {
      return ((value & 0x7FFF) - 0x8000).toDouble();
    }
    return value.toDouble();
  }

  _getCheckSum(data) {
    int sum = data.fold(0, (p, c) => p + c);
    return Uint8List.fromList([sum])[0];
  }
}
