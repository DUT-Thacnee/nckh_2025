import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/management_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/register_screen.dart';
import 'screens/BLE_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Đảm bảo Flutter đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Khởi tạo AuthService
  final authService = AuthService(prefs);

  // Kiểm tra người dùng đã đăng nhập chưa
  final isLoggedIn = await authService.isLoggedIn();

  // Kiểm tra xem người dùng đăng nhập có phải là admin không
  bool isAdmin = false;
  if (isLoggedIn) {
    final userData = await authService.getUserData();
    isAdmin = userData?['isAdmin'] == true;
  }

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    isAdmin: isAdmin,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => isLoggedIn
            ? (isAdmin ? AdminScreen() : MainScreen())
            : LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(),
        '/admin': (context) => AdminScreen(),
        '/ble': (context) => BLEScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late AuthService _authService;
  String _username = '';

  // Khai báo _screens là late để khởi tạo sau trong initState
  late List<Widget> _screens = [
    // Màn hình 1: Bluetooth
    LoginScreen(),
    ManagementScreen(),
    Center(child: Text('Màn hình 3')),
    // Màn hình 4: Cài đặt và thông tin người dùng
    Builder(
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Xin chào, $_username',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog();
              },
              icon: Icon(Icons.logout),
              label: Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      setState(() {
        _username = userData['username'] ?? '';
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final success = await _authService.logout();
    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng xuất thất bại')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getAppBarTitle(),
        actions: [
          // Hiển thị nút đăng xuất ở tất cả các màn hình
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _showLogoutDialog,
          ),
          if (_selectedIndex == 3)
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                // Hiển thị thông tin ứng dụng
                showAboutDialog(
                  context: context,
                  applicationName: 'My App',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.app_settings_alt),
                  applicationLegalese: '© 2023 My Company',
                );
              },
            ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'Bluetooth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Quản lý',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Màn hình 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  // Phương thức để lấy tiêu đề cho AppBar dựa trên tab hiện tại
  Widget _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return Text('Bluetooth');
      case 1:
        return Text('Quản lý');
      case 2:
        return Text('Màn hình 3');
      case 3:
        return Text('Cài đặt');
      default:
        return Text('My App');
    }
  }
}
