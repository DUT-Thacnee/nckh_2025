class BleDevice {
  final String name;
  final String address;
  final String serviceUuid;
  final String characteristicUuid;

  BleDevice({
    required this.name,
    required this.address,
    required this.serviceUuid,
    required this.characteristicUuid,
  });
} 