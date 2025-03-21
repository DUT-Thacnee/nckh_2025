import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_storage_service.dart';
import '../models/location_data.dart';

class LocationMonitorScreen extends StatefulWidget {
  @override
  _LocationMonitorScreenState createState() => _LocationMonitorScreenState();
}

class _LocationMonitorScreenState extends State<LocationMonitorScreen> {
  late LocationStorageService _storageService;
  List<LocationData> _locationDataList = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _storageService = LocationStorageService(prefs);
    _loadData();
  }

  Future<void> _loadData() async {
    final dataList = await _storageService.getAllLocationData();
    setState(() {
      _locationDataList = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Monitor'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _locationDataList.length,
        itemBuilder: (context, index) {
          final data = _locationDataList[index];
          return Card(
            child: ListTile(
              title: Text('Device ID: ${data.deviceId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Longitude: ${data.longitude}'),
                  Text('Latitude: ${data.latitude}'),
                  Text('Last Updated: ${data.timestamp}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 