import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEScreen extends StatefulWidget {
  const BLEScreen({Key? key}) : super(key: key);

  @override
  State<BLEScreen> createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  List<BluetoothService> _services = [];

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
      if (state == BluetoothAdapterState.on) {
        _startScan();
      }
    });

    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }
  }

  Future<void> _toggleBluetooth() async {
    if (_adapterState == BluetoothAdapterState.on) {
      if (!kIsWeb && Platform.isAndroid) {
        await FlutterBluePlus.turnOff();
      }
    } else if (_adapterState == BluetoothAdapterState.off) {
      if (!kIsWeb && Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    if (_adapterState != BluetoothAdapterState.on) {
      print("Bluetooth is not on. Cannot start scan.");
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    _scanResultsSubscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        setState(() {
          _scanResults = results;
        });
      },
      onError: (error) {
        print("Scan Error: $error");
        setState(() {
          _isScanning = false;
        });
      },
    );

    FlutterBluePlus.cancelWhenScanComplete(_scanResultsSubscription!);

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    } catch (e) {
      print("Error starting scan: $e");
      setState(() {
        _isScanning = false;
      });
    }
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
      setState(() {
          _isScanning = false;
      });
  }

  Future<void> _stopScan() async {
    if (!_isScanning) return;

    await FlutterBluePlus.stopScan();
        setState(() {
            _isScanning = false;
        });
  }
  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isScanning) {
      await _stopScan();
    }

    if (_connectedDevice != null) {
      await _disconnectFromDevice();
    }

    _connectionStateSubscription = device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected) {
        print("${device.disconnectReason?.code} ${device.disconnectReason?.description}");
        setState(() {
          _connectedDevice = null;
          _services = [];
        });
      } else if (state == BluetoothConnectionState.connected) {
        setState(() {
          _connectedDevice = device;
        });
        _discoverServices(device);
      }
    });

    device.cancelWhenDisconnected(_connectionStateSubscription!, delayed: true);

    try {
      await device.connect();
    } catch (e) {
      print("Connect Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect: $e")),
      );
            setState(() {
        _connectedDevice = null;
      });
    }
  }

  Future<void> _disconnectFromDevice() async {
    if (_connectedDevice == null) return;

    try {
      await _connectedDevice!.disconnect();
    } catch (e) {
      print("Disconnect Error: $e");
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    if (_connectedDevice == null) return;

    try {
      List<BluetoothService> services = await device.discoverServices();
      setState(() {
        _services = services;
      });

      for (BluetoothService service in _services) {
        print("Service UUID: ${service.uuid}");
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print("  Characteristic UUID: ${characteristic.uuid}");
        }
      }
    } catch (e) {
      print("Discover Services Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to discover services: $e")),
      );
    }
  }
  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _connectedDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Screen'),
      ),
      body: Column(
        children: [
          // Turn On/Off Bluetooth Button
          ElevatedButton(
            onPressed: _toggleBluetooth,
            child: Text(
              _adapterState == BluetoothAdapterState.on
                  ? 'Turn Off Bluetooth'
                  : 'Turn On Bluetooth',
            ),
          ),

          // Scan Button
          ElevatedButton(
            onPressed: _isScanning ? _stopScan : _startScan,
            child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
          ),

          // Display Scan Results
          Expanded(
            child: _buildScanResultsList(),
          ),
          // Display Connected Device and Services (if connected)
           if (_connectedDevice != null) ...[
                const Divider(),
                const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Connected Device:", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text("${_connectedDevice!.remoteId} - ${_connectedDevice!.platformName}"),
                ElevatedButton(onPressed: _disconnectFromDevice, child: const Text("Disconnect")),

                const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Services:", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              _buildServicesList(),
            ],
        ],
      ),
    );
  }

 Widget _buildScanResultsList() {
    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        return ListTile(
          title: Text(result.advertisementData.advName.isNotEmpty ? result.advertisementData.advName: "N/A"),
          subtitle: Text(result.device.remoteId.toString()),
          trailing: ElevatedButton(
              onPressed: () => _connectToDevice(result.device),
              child: const Text("Connect"),
          ),
        );
      },
    );
  }

    Widget _buildServicesList() {
    return Column(
      children: _services.map((service) {
        return ExpansionTile(
          title: Text("Service: ${service.uuid}"),
          children: service.characteristics.map((char) {
            return ListTile(
              title: Text("Characteristic: ${char.uuid}"),
              subtitle: Row(
                children: [
                   if (char.properties.read) ...[
                                ElevatedButton(
                                    onPressed: () async {
                                        try {
                                            List<int> value = await char.read();
                                              print("Read value: $value");
                                            // Show the read value. Consider using hex format.
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Read: ${value.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}"))
                                            );

                                        } catch(e) {
                                             print("Read Error: $e");
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Read Failed: $e"))
                                            );
                                        }
                                    },
                                    child: const Text("Read"),
                                ),
                                const SizedBox(width: 8)
                            ],


                    if (char.properties.write) ...[
                        ElevatedButton(
                        onPressed: () async {
                            // Example: Write [0x12, 0x34] to the characteristic
                            try {
                                await char.write([0x12, 0x34], withoutResponse: char.properties.writeWithoutResponse);
                                  print("Write successful");
                                ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(content: Text("Write Success"))
                                );

                                // If it's a write with response, you might want to read afterward to confirm
                                if (!char.properties.writeWithoutResponse) {
                                    List<int> value = await char.read();  // Read back value.
                                }

                            } catch (e) {
                                print("Write error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Write Failed: $e"))
                                );
                            }
                        },
                        child: const Text("Write"),
                        ),
                        const SizedBox(width: 8),
                    ],



                    if (char.properties.notify)
                        ElevatedButton(
                          onPressed: () async {
                            try {
                                bool isNotifying = char.isNotifying;
                                await char.setNotifyValue(!isNotifying); // Toggle notify
                                // Listen to notifications
                                if (!isNotifying) { // Only subscribe if we're turning it ON
                                      char.onValueReceived.listen((value) {
                                        // Handle notification data
                                        print("Notification: $value");
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Notify: ${value.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}"))
                                        );
                                      });
                                }

                                  print("${!isNotifying?'Subscribed':'Unsubscribed'} to notifications");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("${!isNotifying?'Subscribed':'Unsubscribed'} to notifications"))
                                  );

                            } catch(e) {
                              print("Notify error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Notify Failed: $e"))
                              );
                            }
                          },
                          child: Text(char.isNotifying ? "Unsubscribe" : "Subscribe"),
                        ),

                ],
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}