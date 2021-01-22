library hidden_drawer;

import 'dart:math';

import 'package:flutter/material.dart';

class HiddenDrawer extends StatefulWidget {
  final Widget drawer;
  final Widget child;
  final double drawerWidth;
  final double scale;
  final Duration duration;
  final Decoration backgroundDecoration;
  final Curve openCurve;
  final Curve closeCurve;
  final BorderRadius childBorderRadius;
  final double drawerEdgeDragWidth;

  const HiddenDrawer({
    Key key,
    @required this.drawer,
    @required this.child,
    this.drawerWidth = 256,
    this.scale = 0.75,
    this.duration = const Duration(milliseconds: 300),
    this.backgroundDecoration,
    this.openCurve = Curves.easeInOut,
    this.closeCurve = Curves.easeInOut,
    this.childBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.drawerEdgeDragWidth = 48,
  })  : assert(drawer != null),
        assert(child != null),
        assert(drawerWidth != null),
        assert(scale != null && 0 < scale && scale <= 1),
        assert(duration != null),
        assert(openCurve != null),
        assert(closeCurve != null),
        super(key: key);

  static HiddenDrawerState of(BuildContext context) => context.findAncestorStateOfType<HiddenDrawerState>();

  @override
  HiddenDrawerState createState() => HiddenDrawerState();
}

class HiddenDrawerState extends State<HiddenDrawer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _curvedAnimation;
  Animation _childAnimation;
  Animation _borderRadiusAnimation;
  bool _shouldDrag;

  bool get isOpened => _controller.isCompleted;
  bool get isClosed => _controller.isDismissed;
  bool get isOpening => _controller.status == AnimationStatus.forward;
  bool get isClosing => _controller.status == AnimationStatus.reverse;
  bool get isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addStatusListener((status) {
      setState(() {});
    });
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.openCurve,
      reverseCurve: widget.closeCurve,
    );
    _borderRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.zero,
      end: widget.childBorderRadius,
    ).animate(_curvedAnimation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final xOffset =
        widget.drawerWidth + max(0.0, ((screenWidth - widget.drawerWidth - (screenWidth * widget.scale)) / 2));
    final yOffset = (screenHeight - screenHeight * widget.scale) / 2;

    _childAnimation = Matrix4Tween(
      begin: Matrix4.translationValues(0, 0, 0)..scale(1.0),
      end: Matrix4.translationValues(xOffset, yOffset, 0)..scale(widget.scale),
    ).animate(_curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void open() {
    if (isAnimating) return;
    _controller.forward();
  }

  void close() {
    if (isAnimating) return;
    _controller.reverse();
  }

  void toggle() {
    if (isAnimating) return;
    if (isOpened) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: widget.backgroundDecoration ?? BoxDecoration(color: Theme.of(context).backgroundColor),
        ),
        FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInQuart,
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-1, 0),
              end: Offset.zero,
            ).animate(_curvedAnimation),
            child: SizedBox(
              width: widget.drawerWidth,
              child: widget.drawer,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _childAnimation,
          builder: (context, child) {
            return Transform(
              transform: _childAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              if (isOpened) {
                close();
              }
            },
            onHorizontalDragStart: (details) {
              final dragWidth = widget.drawerEdgeDragWidth + MediaQuery.of(context).padding.left;
              final shouldOpen = isClosed && details.localPosition.dx <= dragWidth;
              final shouldClose = isOpened;
              _shouldDrag = shouldOpen || shouldClose;
            },
            onHorizontalDragUpdate: (details) {
              if (!_shouldDrag) return;
              final screenWidth = MediaQuery.of(context).size.width;
              final xOffset = widget.drawerWidth +
                  max(0.0, ((screenWidth - widget.drawerWidth - (screenWidth * widget.scale)) / 2));
              _controller.value += details.primaryDelta / xOffset;
            },
            onHorizontalDragEnd: (details) {
              if (!_shouldDrag) return;

              final dragVelocity = details.velocity.pixelsPerSecond.dx.abs();
              if (dragVelocity >= 365) {
                final visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;
                _controller.fling(velocity: visualVelocity);
              } else if (_controller.value < 0.5) {
                close();
              } else {
                open();
              }
            },
            child: AbsorbPointer(
              absorbing: !isClosed,
              child: AnimatedBuilder(
                animation: _borderRadiusAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: _borderRadiusAnimation.value,
                    child: child,
                  );
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
