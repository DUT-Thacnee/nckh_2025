import 'package:flutter/material.dart';
import 'dart:async';
import '../services/bluetooth_service.dart';

class BleInfoDialog extends StatefulWidget {
  final BluetoothService bluetoothService;

  const BleInfoDialog({Key? key, required this.bluetoothService})
      : super(key: key);

  @override
  _BleInfoDialogState createState() => _BleInfoDialogState();
}

class _BleInfoDialogState extends State<BleInfoDialog> {
  Timer? _rssiTimer;

  @override
  void initState() {
    super.initState();
    // Cập nhật RSSI mỗi 2 giây
    _rssiTimer = Timer.periodic(Duration(seconds: 2), (_) {
      if (mounted) {
        widget.bluetoothService.updateRssi().then((_) => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    _rssiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.bluetoothService.connectedDevice;
    final rssi = widget.bluetoothService.lastRssi;

    return AlertDialog(
      title: Text('Thông tin thiết bị'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tên: ${device?.platformName ?? "Unknown"}'),
          Text('Địa chỉ: ${device?.remoteId.str ?? "N/A"}'),
          Text('RSSI: ${rssi ?? "N/A"} dBm'),
          Text('Trạng thái: ${widget.bluetoothService.isConnected ? "Đã kết nối" : "Đã ngắt kết nối"}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await widget.bluetoothService.restart();
            Navigator.pop(context);
          },
          child: Text('Cài lại'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    );
  }
} 