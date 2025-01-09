import 'package:flutter/material.dart';
import 'grant_event_permissions.dart';
import 'grant_outpass_permissions.dart';
import 'todays_permission_dashboard.dart';
import 'analytics.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
                  Text(
                    ' ${widget.name ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.branch == 'CSE' ? 'Computer Science and Engineering' : 'Electronics and Communication Engineering'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Role: ${widget.role ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'National University of India for Techonlogy and Innovation (NUITI)',
                style: TextStyle(color: Colors.black),
              ),
              leading: Icon(Icons.school, color: Colors.black),
              onTap: () {
                // Handle navigation
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
          TodaysPermissionDashboard(token: widget.token ?? ""),
          Analytics(token: widget.token ?? ""),
          Sec(token: widget.token ?? ""),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
}
