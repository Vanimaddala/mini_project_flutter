import 'package:flutter/material.dart';
import 'grant_event_permissions.dart';
import 'grant_outpass_permissions.dart';
import 'todays_permission_dashboard.dart';
import 'permission_analytics.dart';
import 'login.dart';
import 'sec.dart';

class CseHodPage extends StatefulWidget {
  final String? name;
  final String? role;
  final String? branch;
  final String? token;
  final String? photo;

  const CseHodPage({
    Key? key,
    this.name,
    this.role,
    this.branch,
    this.token,
    this.photo,
  }) : super(key: key);

  @override
  _CseHodPageState createState() => _CseHodPageState();
}

class _CseHodPageState extends State<CseHodPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [],
      ),

      // Drawer Menu
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrawerHeader(),
            ListTile(
              leading: Icon(Icons.school, color: Colors.black),
              title: Text(
                'Phd in Data Mining at University of Sreekar',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // Page Content
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          GrantEventPermissions(token: widget.token ?? ""),
          GrantOutpassPermissions(
            hodDepartment: widget.branch ?? "",
            token: widget.token ?? "",
          ),
          EventPermissionsPage(token: widget.token ?? ""),
          HourlyOutpassAnalytics(token: widget.token ?? ""),
          Sec(token: widget.token ?? ""),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Outpasses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Security',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // Drawer Header Widget
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.photo ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.branch == 'CSD'
                ? 'Head of Department of Computer Science and Data Science'
                : 'Head of Department of Artificial Intelligence and Machine Learning',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            widget.branch == 'CSD'
                ? '"Data is the new oil — extract, refine, and power innovation."'
                : '"The future belongs to those who understand and teach machines to learn."',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'MLR Institute Of Technology',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
