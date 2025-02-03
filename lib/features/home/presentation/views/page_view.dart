import 'package:flutter/material.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/features/home/presentation/views/chat_view.dart';
import 'package:physio_app/features/home/presentation/views/home_view.dart';
import 'package:physio_app/features/home/presentation/views/profile_view.dart';

class SelectorPageView extends StatefulWidget {
  const SelectorPageView({super.key});

  @override
  State<SelectorPageView> createState() => _SelectorPageViewState();
}

class _SelectorPageViewState extends State<SelectorPageView> {
  int _selectedIndex = 0;
  final PageController pageController = PageController();

  final List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    ChatView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: const Text('Physio App'),
      ),
      body: PageView(
        controller: pageController,
        children: _widgetOptions,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.secondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
