import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Lớp này đã được đơn giản hóa và loại bỏ tất cả code liên quan đến Mapbox
class MapboxService {
  // Hằng số giả lập
  static const String MAPBOX_ACCESS_TOKEN = 'REMOVED';
  static const String STYLE_URL = 'REMOVED';

  // Phương thức khởi tạo đơn giản
  Future<void> initialize() async {
    print('MapboxService initialized (simplified version)');
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<Map<String, dynamic>> getSavedMapParameters() async {
    return {
      'centerLat': 16.056789,
      'centerLng': 108.134799,
      'zoom': 14.0,
      'pitch': 0.0,
      'bearing': 0.0,
      'radius': 1.0,
    };
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<bool> isLocationInDownloadedRegion(double lat, double lng) async {
    return false;
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<Map<String, dynamic>> getRegionInfo() async {
    return {
      'regionId': 'dummy_region',
      'centerLat': 16.056789,
      'centerLng': 108.134799,
      'zoom': 14.0,
      'pitch': 0.0,
      'bearing': 0.0,
      'radius': 1.0,
    };
  }

  // Phương thức giả lập để tương thích với code hiện tại
  Future<List<String>> listOfflineRegions() async {
    return [];
  }

  void dispose() {
    // Không làm gì
  }
}
