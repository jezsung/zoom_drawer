import 'package:flutter/material.dart';

import '../zoom_drawer.dart';

class DefaultZoomDrawerController extends StatefulWidget {
  const DefaultZoomDrawerController({
    Key? key,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  final Duration duration;

  static ZoomDrawerController of(BuildContext context) {
    final _ZoomDrawerControllerScope? scope = context.dependOnInheritedWidgetOfExactType<_ZoomDrawerControllerScope>();
    if (scope == null) {
      throw StateError('DefaultZoomDrawerController must be in the ancestor widgets');
    }
    return scope.controller;
  }

  @override
  _DefaultZoomDrawerControllerState createState() => _DefaultZoomDrawerControllerState();
}

class _DefaultZoomDrawerControllerState extends State<DefaultZoomDrawerController> with SingleTickerProviderStateMixin {
  late final ZoomDrawerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ZoomDrawerController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ZoomDrawerControllerScope(
      controller: _controller,
      enabled: TickerMode.of(context),
      child: Container(),
    );
  }
}

class _ZoomDrawerControllerScope extends InheritedWidget {
  const _ZoomDrawerControllerScope({
    Key? key,
    required this.controller,
    required this.enabled,
    required Widget child,
  }) : super(key: key, child: child);

  final ZoomDrawerController controller;
  final bool enabled;

  @override
  bool updateShouldNotify(_ZoomDrawerControllerScope old) {
    return enabled != old.enabled || controller != old.controller;
  }
}
