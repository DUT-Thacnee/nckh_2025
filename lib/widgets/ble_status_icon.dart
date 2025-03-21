import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import './ble_info_dialog.dart';

class BleStatusIcon extends StatelessWidget {
  final BluetoothService bluetoothService;

  const BleStatusIcon({Key? key, required this.bluetoothService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Stream.periodic(Duration(seconds: 1))
          .asyncMap((_) => bluetoothService.isConnected),
      builder: (context, snapshot) {
        final bool isConnected = snapshot.data ?? false;
        
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => BleInfoDialog(
                bluetoothService: bluetoothService,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.bluetooth,
              color: isConnected ? Colors.blue : Colors.grey,
              size: 24,
            ),
          ),
        );
      },
    );
  }
} 