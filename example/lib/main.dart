import 'package:flutter/material.dart';
import 'package:hidden_drawer/hidden_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Drawer Example',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _drawerKey = GlobalKey<HiddenDrawerState>();

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_drawerKey.currentState.isOpened) {
          _drawerKey.currentState.close();
          return false;
        } else {
          return true;
        }
      },
      child: HiddenDrawer(
        key: _drawerKey,
        drawer: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: ListTileTheme(
              iconColor: Colors.white,
              textColor: Colors.white,
              selectedColor: Colors.white,
              selectedTileColor: Colors.white.withOpacity(0.25),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    selected: _selected == 0,
                    onTap: () {
                      setState(() {
                        _selected = 0;
                      });
                      _drawerKey.currentState.close();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    selected: _selected == 1,
                    onTap: () {
                      setState(() {
                        _selected = 1;
                      });
                      _drawerKey.currentState.close();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        child: IndexedStack(
          index: _selected,
          children: [
            HomePage(),
            SettingPage(),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            HiddenDrawer.of(context).toggle();
          },
        ),
        title: Text('Home Page'),
      ),
      body: SafeArea(
        child: Center(
          child: Text('Home Page'),
        ),
      ),
    );
  }
}

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            HiddenDrawer.of(context).toggle();
          },
        ),
        title: Text('Setting Page'),
      ),
      body: SafeArea(
        child: Center(
          child: Text('Setting Page'),
        ),
      ),
    );
  }
}
