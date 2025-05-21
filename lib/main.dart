// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(GatekeeprApp());

class GatekeeprApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryGreen = Color(0xFF7CFFB4);
    return MaterialApp(
      title: 'Gatekeepr Logs',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        hintColor: primaryGreen,
        scaffoldBackgroundColor: Colors.black,
        tabBarTheme: TabBarTheme(
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.white70,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: primaryGreen, width: 3),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_fetchData);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    String endpoint;
    switch (_tabController.index) {
      case 1:
        endpoint = 'residents/';
        break;
      case 2:
        endpoint = 'visitors/';
        break;
      default:
        endpoint = 'access-logs/';
    }
    final url = Uri.parse('https://gatekeepr.onrender.com/api/v1/$endpoint');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() => _data = json.decode(res.body));
    } else {
      setState(() => _data = []);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/images/auth.png', height: 32),
            SizedBox(width: 8),
            Text('Gatekeepr', style: TextStyle(color: accent)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'ALL'), Tab(text: 'Residents'), Tab(text: 'Visitors')],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: _loading
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(accent)))
              : _data.isEmpty
                  ? Center(child: Text('No data found', style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      padding: EdgeInsets.all(8),
                      itemCount: _data.length,
                      separatorBuilder: (_, __) => SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final item = _data[i];
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? item['email'] ?? 'Entry',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['timestamp'] ?? '',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
