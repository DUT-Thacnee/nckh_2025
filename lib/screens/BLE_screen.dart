import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEScreen extends StatefulWidget {
  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  BluetoothDevice? device;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

Future<void> _intitial_BLE() async {
// first, check if bluetooth is supported by your hardware
// Note: The platform is initialized on the first call to any FlutterBluePlus method.
  if (await FlutterBluePlus.isSupported == false) {
    print("Bluetooth not supported by this device");
    return;
  }

// handle bluetooth on & off
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
  var subscription =
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
    print(state);
    if (state == BluetoothAdapterState.on) {
      // usually start scanning, connecting, etc
    } else {
      // show an error to the user, etc
    }
  });

// cancel to prevent duplicate listeners
  subscription.cancel();
}

Future<void> _scan_BLE() async {
// listen to scan results
// Note: `onScanResults` clears the results between scans. You should use
//  `scanResults` if you want the current scan results *or* the results from the previous scan.
  var subscription = FlutterBluePlus.onScanResults.listen(
    (results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
      }
    },
    onError: (e) => print(e),
  );

// cleanup: cancel subscription when scanning stops
  FlutterBluePlus.cancelWhenScanComplete(subscription);

// Wait for Bluetooth enabled & permission granted
// In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;

// Start scanning w/ timeout
// Optional: use `stopScan()` as an alternative to timeout
  await FlutterBluePlus.startScan(
      withServices: [Guid("180D")], // match any of the specified services
      withNames: ["Bluno"], // *or* any of the specified names
      timeout: Duration(seconds: 15));

// wait for scanning to stop
  await FlutterBluePlus.isScanning.where((val) => val == false).first;
}

Future<void> _connect_BLE(BluetoothDevice device) async {
  // listen for disconnection
  var subscription =
      device.connectionState.listen((BluetoothConnectionState state) async {
    if (state == BluetoothConnectionState.disconnected) {
      // 1. typically, start a periodic timer that tries to
      //    reconnect, or just call connect() again right now
      // 2. you must always re-discover services after disconnection!
      print(
          "${device.disconnectReason?.code} ${device.disconnectReason?.description}");
    }
  });

// cleanup: cancel subscription when disconnected
//   - [delayed] This option is only meant for `connectionState` subscriptions.
//     When `true`, we cancel after a small delay. This ensures the `connectionState`
//     listener receives the `disconnected` event.
//   - [next] if true, the the stream will be canceled only on the *next* disconnection,
//     not the current disconnection. This is useful if you setup your subscriptions
//     before you connect.
  device.cancelWhenDisconnected(subscription, delayed: true, next: true);

// Connect to the device
  await device.connect();

// Disconnect from device
  await device.disconnect();

// cancel to prevent duplicate listeners
  subscription.cancel();
}

Future<void> _auto_connect_BLE(BluetoothDevice device) async {
  // enable auto connect
//  - note: autoConnect is incompatible with mtu argument, so you must call requestMtu yourself
  await device.connect(autoConnect: true, mtu: null);

// wait until connection
//  - when using autoConnect, connect() always returns immediately, so we must
//    explicity listen to `device.connectionState` to know when connection occurs
  await device.connectionState
      .where((val) => val == BluetoothConnectionState.connected)
      .first;

// disable auto connect
  await device.disconnect();
}

// interface to the Bluetooth in here
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Bluetooth Low Energy'),
    ),
    body: Center(
      child: Text('Bluetooth Low Energy'),
    ),
  );
}
