import 'package:flutter/material.dart';
import 'package:zoom_drawer/zoom_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zoom_drawer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final ZoomDrawerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ZoomDrawerController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller.isOpen) {
          await _controller.close();
          return false;
        } else {
          return true;
        }
      },
      child: ZoomDrawer(
        controller: _controller,
        childBorderRadius: BorderRadius.circular(16),
        drawer: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ],
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                print('icon button pressed');
                _controller.toggle();
              },
              icon: Icon(Icons.menu),
            ),
            title: Text('zoom_drawer Example'),
            actions: [
              IconButton(
                onPressed: () {
                  print('icon button pressed');
                  _controller.toggle();
                },
                icon: Icon(Icons.menu),
              ),
            ],
          ),
          body: Center(
            child: Text('zoom_drawer Example'),
          ),
        ),
      ),
    );
  }
}
