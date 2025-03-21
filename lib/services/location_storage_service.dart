import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_data.dart';

class LocationStorageService {
  final SharedPreferences _prefs;
  static const String KEY_LOCATION_DATA = 'location_data';

  LocationStorageService(this._prefs);

  Future<void> saveLocationData(LocationData data) async {
    final List<String> dataList = _prefs.getStringList(KEY_LOCATION_DATA) ?? [];
    
    // Kiểm tra xem đã có dữ liệu của thiết bị này chưa
    final index = dataList.indexWhere((item) {
      final itemData = LocationData.fromJson(jsonDecode(item));
      return itemData.deviceId == data.deviceId;
    });
    
    // Nếu đã có, cập nhật; nếu chưa có, thêm mới
    if (index >= 0) {
      dataList[index] = jsonEncode(data.toJson());
    } else {
      dataList.add(jsonEncode(data.toJson()));
    }
    
    await _prefs.setStringList(KEY_LOCATION_DATA, dataList);
  }

  Future<LocationData?> getLocationData(String deviceId) async {
    final List<String> dataList = _prefs.getStringList(KEY_LOCATION_DATA) ?? [];
    
    final dataString = dataList.firstWhere(
      (item) {
        final itemData = LocationData.fromJson(jsonDecode(item));
        return itemData.deviceId == deviceId;
      },
      orElse: () => '',
    );
    
    if (dataString.isEmpty) {
      return null;
    }
    
    return LocationData.fromJson(jsonDecode(dataString));
  }

  Future<List<LocationData>> getAllLocationData() async {
    final List<String> dataList = _prefs.getStringList(KEY_LOCATION_DATA) ?? [];
    
    return dataList.map((item) => LocationData.fromJson(jsonDecode(item))).toList();
  }

  Future<void> clearAllLocationData() async {
    await _prefs.remove(KEY_LOCATION_DATA);
  }

  Future<void> removeLocationData(String deviceId) async {
    final List<String> dataList = _prefs.getStringList(KEY_LOCATION_DATA) ?? [];
    
    final filteredList = dataList.where((item) {
      final itemData = LocationData.fromJson(jsonDecode(item));
      return itemData.deviceId != deviceId;
    }).toList();
    
    await _prefs.setStringList(KEY_LOCATION_DATA, filteredList);
  }
} 