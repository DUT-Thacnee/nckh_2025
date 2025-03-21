import 'package:flutter/material.dart';
import '../models/location_data.dart';

class DeviceMapScreen extends StatefulWidget {
  final LocationData deviceData;

  const DeviceMapScreen({Key? key, required this.deviceData}) : super(key: key);

  @override
  _DeviceMapScreenState createState() => _DeviceMapScreenState();
}

class _DeviceMapScreenState extends State<DeviceMapScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device ${widget.deviceData.deviceId}'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Map View Placeholder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection('Device Information', [
                      {
                        'label': 'Device ID',
                        'value': widget.deviceData.deviceId
                      },
                      {'label': 'Status', 'value': 'Active'},
                    ]),
                    SizedBox(height: 16),
                    _buildInfoSection('Location Data', [
                      {
                        'label': 'Latitude',
                        'value': widget.deviceData.latitude.toString()
                      },
                      {
                        'label': 'Longitude',
                        'value': widget.deviceData.longitude.toString()
                      },
                      {
                        'label': 'Last Updated',
                        'value': widget.deviceData.timestamp.toString()
                      },
                    ]),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _navigateToDeviceMap(widget.deviceData),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        item['value']!,
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
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
}
