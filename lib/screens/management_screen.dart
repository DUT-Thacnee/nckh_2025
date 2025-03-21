import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_storage_service.dart';
import '../models/location_data.dart';
import 'device_map_screen.dart';

class ManagementScreen extends StatefulWidget {
  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedDeviceId;
  List<LocationData> _deviceData = [];
  
  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocationStorageService(prefs);
    final dataList = await storageService.getAllLocationData();
    setState(() {
      _deviceData = dataList;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Setting 1'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Setting 2'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Reset settings
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings have been reset')),
              );
            },
            child: Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings saved')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToDeviceMap(LocationData deviceData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceMapScreen(deviceData: deviceData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            final deviceId = 'device${index + 1}';
            final deviceData = _deviceData.firstWhere(
              (data) => data.deviceId == deviceId,
              orElse: () => LocationData(
                deviceId: deviceId,
                latitude: 16.056789 + (index * 0.01),
                longitude: 108.134799 + (index * 0.01),
                timestamp: DateTime.now(),
              ),
            );

            return GestureDetector(
              onTap: () => _navigateToDeviceMap(deviceData),
              child: Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${deviceData.deviceId}'),
                      Text('Status: ${_deviceData.contains(deviceData) ? "Active" : "Inactive"}'),
                      Text('Description: Location data available'),
                      SizedBox(height: 8),
                      Text('Latitude: ${deviceData.latitude.toStringAsFixed(6)}'),
                      Text('Longitude: ${deviceData.longitude.toStringAsFixed(6)}'),
                      Text('Last Updated: ${deviceData.timestamp.toString().substring(0, 16)}'),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToDeviceMap(deviceData),
                          icon: Icon(Icons.map),
                          label: Text('View on Map'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
} 