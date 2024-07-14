import 'package:_first_one/views/add_documents.dart';
import 'package:_first_one/views/categories.dart';
import 'package:_first_one/views/favourites.dart';
import 'package:_first_one/views/settings.dart';
import 'package:_first_one/views/your_documents.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget>? _body;

  @override
  void initState() {
    super.initState();
    _body = [
      YourDocuments(),
      AddDocuments(),
      Favourites(),
      Categories(),
      Settings()
    ];

    // Subscribe to the user stream
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body![_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
        iconSize: 35,
        selectedFontSize: 1,
        unselectedFontSize: 1,
      ),
    );
  }
}
