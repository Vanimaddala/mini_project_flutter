import 'package:flutter/material.dart';
import 'mentees_list.dart';
import 'todays_permission_dashboard.dart';
import 'login.dart'; // Import the login screen

class CseFacultyPage extends StatefulWidget {
  final String name;
  final String role;
  final String branch;
  final String photo;
  final String token;

  const CseFacultyPage({
    Key? key,
    required this.name,
    required this.role,
    required this.branch,
    required this.photo,
    required this.token,
  }) : super(key: key);

  @override
  _CseFacultyPageState createState() => _CseFacultyPageState();
}

class _CseFacultyPageState extends State<CseFacultyPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

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
    String departmentName;
    String motto;

    if (widget.branch == 'CSE') {
      departmentName = 'Department of Computer Science and Engineering';
      motto = 'Excellence and Expedition';
    } else {
      departmentName = 'Department of Electronics and Communication';
      motto = 'Insights and Innovation';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome !'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: NetworkImage(widget.photo),
                ),
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    widget.role,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    widget.branch,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    departmentName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    motto,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                  'National university of India for Technology and Innovation '),
              onTap: () {
                // Handle navigation or any action
              },
            ),
            ListTile(
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
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          MenteesPermissionListPage(token: widget.token),
          TodaysPermissionDashboard(
            token: widget.token,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mentees Permission List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today\'s Permission List',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
