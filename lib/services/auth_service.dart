import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'users';
  static const String KEY_USER = 'user_data';
  static const String KEY_TOKEN = 'auth_token';
  static const String KEY_IS_LOGGED_IN = 'is_logged_in';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<List<User>> _getUsers() async {
    final String? usersJson = _prefs.getString(_userKey);
    if (usersJson == null) return [];
    
    List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((user) => User.fromJson(user)).toList();
  }

  Future<void> _saveUsers(List<User> users) async {
    final String usersJson = jsonEncode(users.map((user) => user.toJson()).toList());
    await _prefs.setString(_userKey, usersJson);
  }

  Future<bool> register(String name, String password) async {
    final users = await _getUsers();
    
    // Kiểm tra xem tên người dùng đã tồn tại chưa
    if (users.any((user) => user.name == name)) {
      return false;
    }

    // Tạo user mới với ID ngẫu nhiên
    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      password: password,
    );

    users.add(newUser);
    await _saveUsers(users);
    return true;
  }

  Future<User?> authenticateUser(String name, String password) async {
    final users = await _getUsers();
    
    return users
        .where((user) => user.name == name && user.password == password)
        .firstOrNull;
  }

  Future<void> printUserData() async {
    final String? usersJson = _prefs.getString(_userKey);
    print('Stored Users Data: $usersJson');
  }

  Future<void> clearAllData() async {
    await _prefs.remove(_userKey);
  }

  Future<String> getUserDataForAdmin() async {
    final String? usersJson = _prefs.getString(_userKey);
    if (usersJson == null) return 'Không có dữ liệu người dùng';
    
    try {
      // Format JSON để dễ đọc hơn
      final dynamic parsedJson = jsonDecode(usersJson);
      return const JsonEncoder.withIndent('  ').convert(parsedJson);
    } catch (e) {
      return 'Lỗi khi đọc dữ liệu: $e';
    }
  }

  bool isAdmin(String name, String password) {
    return name == "thac&nam" && password == "nckh2025";
  }

  Future<void> deleteUser(String userId) async {
    final users = await _getUsers();
    users.removeWhere((user) => user.id == userId);
    await _saveUsers(users);
  }

  Future<List<Map<String, dynamic>>> getUsersList() async {
    final users = await _getUsers();
    return users.map((user) => user.toJson()).toList();
  }

  // Lưu thông tin người dùng
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _prefs.setString(KEY_USER, jsonEncode(userData));
      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userString = _prefs.getString(KEY_USER);
      if (userString == null) return null;
      return jsonDecode(userString) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Lưu token xác thực
  Future<bool> saveAuthToken(String token) async {
    try {
      await _prefs.setString(KEY_TOKEN, token);
      return true;
    } catch (e) {
      print('Error saving auth token: $e');
      return false;
    }
  }

  // Lấy token xác thực
  Future<String?> getAuthToken() async {
    try {
      return _prefs.getString(KEY_TOKEN);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Đánh dấu người dùng đã đăng nhập
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    try {
      await _prefs.setBool(KEY_IS_LOGGED_IN, isLoggedIn);
      return true;
    } catch (e) {
      print('Error setting logged in status: $e');
      return false;
    }
  }

  // Kiểm tra người dùng đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    try {
      return _prefs.getBool(KEY_IS_LOGGED_IN) ?? false;
    } catch (e) {
      print('Error checking logged in status: $e');
      return false;
    }
  }

  // Đăng nhập và lưu thông tin người dùng
  Future<bool> login(String username, String password) async {
    try {
      // Kiểm tra xác thực người dùng
      final user = await authenticateUser(username, password);
      
      if (user != null) {
        // Đăng nhập thành công, lưu thông tin người dùng
        await saveUserData({
          'id': user.id,
          'username': user.name,
          'name': 'User ${user.name.toUpperCase()}',
        });
        await saveAuthToken('token_${DateTime.now().millisecondsSinceEpoch}');
        await setLoggedIn(true);
        return true;
      }
      
      // Kiểm tra nếu là admin
      if (isAdmin(username, password)) {
        await saveUserData({
          'id': 'admin',
          'username': username,
          'name': 'Administrator',
          'isAdmin': true,
        });
        await saveAuthToken('admin_token_${DateTime.now().millisecondsSinceEpoch}');
        await setLoggedIn(true);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Đăng xuất
  Future<bool> logout() async {
    try {
      await _prefs.remove(KEY_USER);
      await _prefs.remove(KEY_TOKEN);
      await _prefs.setBool(KEY_IS_LOGGED_IN, false);
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
} 