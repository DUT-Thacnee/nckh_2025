import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Lớp này đã được đơn giản hóa và loại bỏ tất cả code liên quan đến Bluetooth
class BluetoothService {
  // Stream controllers giả lập
  final _deviceNameController = StreamController<String>.broadcast();
  final _rssiController = StreamController<int>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Streams giả lập
  Stream<String> get deviceName => _deviceNameController.stream;
  Stream<int> get rssi => _rssiController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  // Trạng thái giả lập
  bool _isConnected = false;
  String _currentDeviceName = "Dummy Device";
  int _currentRssi = -70;

  // Phương thức khởi tạo đơn giản
  Future<void> initialize() async {
    print('BluetoothService initialized (simplified version)');
    _deviceNameController.add(_currentDeviceName);
    _rssiController.add(_currentRssi);
    _connectionStatusController.add(_isConnected);
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<bool> startScan() async {
    print('Bluetooth scan started (simulated)');
    return true;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<bool> stopScan() async {
    print('Bluetooth scan stopped (simulated)');
    return true;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<bool> connect(String deviceId) async {
    _isConnected = true;
    _connectionStatusController.add(_isConnected);
    print('Connected to device: $deviceId (simulated)');
    return true;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<bool> disconnect() async {
    _isConnected = false;
    _connectionStatusController.add(_isConnected);
    print('Disconnected from device (simulated)');
    return true;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  bool isConnected() {
    return _isConnected;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  String getConnectedDeviceName() {
    return _currentDeviceName;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  int getConnectedDeviceRssi() {
    return _currentRssi;
  }

  void dispose() {
    _deviceNameController.close();
    _rssiController.close();
    _connectionStatusController.close();
  }
}

class BLEScreen extends StatefulWidget {
  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  bool _isBluetoothOn = false; // Trạng thái Bluetooth
  List<BluetoothDevice> _devicesList = []; // Danh sách thiết bị phát hiện

  @override
  void initState() {
    super.initState();
    // Kiểm tra trạng thái Bluetooth khi khởi động
    FlutterBluePlus.state.listen((state) {
      setState(() {
        _isBluetoothOn = state == BluetoothAdapterState.on;
      });
    });
  }

  void _toggleBluetooth(bool value) async {
    if (value) {
      // Bật Bluetooth
      await FlutterBluePlus.turnOn();
      _startScanning();
    } else {
      // Tắt Bluetooth
      await FlutterBluePlus.turnOff();
      setState(() {
        _devicesList.clear(); // Xóa danh sách thiết bị khi tắt Bluetooth
      });
    }
  }

  void _startScanning() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _devicesList = results.map((r) => r.device).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Low Energy'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Bật Bluetooth'),
            value: _isBluetoothOn,
            onChanged: _toggleBluetooth,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devicesList[index].name.isNotEmpty
                      ? _devicesList[index].name
                      : 'Không tên'),
                  subtitle: Text(_devicesList[index].id.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
