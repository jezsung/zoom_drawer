import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'allow_multiple_horizontal_drag_gesture_recognizer.dart';
import 'default_zoom_drawer_controller.dart';
import 'zoom_drawer_controller.dart';
import 'zoom_drawer_status.dart';

class ZoomDrawer extends StatefulWidget {
  const ZoomDrawer({
    Key? key,
    this.controller,
    this.drawerWidth,
    this.scale = 0.75,
    this.backgroundColor,
    this.openCurve = Curves.easeInOut,
    this.closeCurve = Curves.easeInOut,
    this.childBorderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.drawerEdgeDragWidth = kMinInteractiveDimension,
    required this.drawer,
    required this.child,
  }) : super(key: key);

  final ZoomDrawerController? controller;
  final double? drawerWidth;
  final double scale;
  final Color? backgroundColor;
  final Curve openCurve;
  final Curve closeCurve;
  final BorderRadius childBorderRadius;
  final double drawerEdgeDragWidth;
  final Widget drawer;
  final Widget child;

  @override
  ZoomDrawerState createState() => ZoomDrawerState();
}

class ZoomDrawerState extends State<ZoomDrawer> {
  late final Animation _childAnimation;
  late final Animation<double> _curvedAnimation;
  late final Animation<BorderRadius?> _borderRadiusAnimation;

  bool _shouldDrag = false;

  ZoomDrawerController get _controller => widget.controller ?? DefaultZoomDrawerController.of(context);
  double get _drawerWidth => widget.drawerWidth ?? min(256.0, MediaQuery.of(context).size.width);

  @override
  void initState() {
    super.initState();
    _curvedAnimation = CurvedAnimation(
      parent: _controller.animation,
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
    final xOffset = _drawerWidth + max(0.0, ((screenWidth - _drawerWidth - (screenWidth * widget.scale)) / 2));
    final yOffset = (screenHeight - screenHeight * widget.scale) / 2;

    _childAnimation = Matrix4Tween(
      begin: Matrix4.translationValues(0, 0, 0)..scale(1.0),
      end: Matrix4.translationValues(xOffset, yOffset, 0)..scale(widget.scale),
    ).animate(_curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: widget.backgroundColor ?? Theme.of(context).backgroundColor),
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset(-1, 0),
            end: Offset.zero,
          ).animate(_curvedAnimation),
          child: SizedBox(
            width: widget.drawerWidth,
            child: widget.drawer,
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
          child: RawGestureDetector(
            gestures: {
              TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => TapGestureRecognizer(),
                (instance) {
                  instance
                    ..onTap = () {
                      if (_controller.isOpen) {
                        _controller.close();
                      }
                    };
                },
              ),
              AllowMultipleHorizontalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<AllowMultipleHorizontalDragGestureRecognizer>(
                () => AllowMultipleHorizontalDragGestureRecognizer(),
                (instance) {
                  instance
                    ..onStart = (details) {
                      final dragWidth = widget.drawerEdgeDragWidth + MediaQuery.of(context).padding.left;
                      final shouldOpen = _controller.isClosed && details.localPosition.dx <= dragWidth;
                      final shouldClose = _controller.isOpen;
                      _shouldDrag = shouldOpen || shouldClose;
                    }
                    ..onUpdate = (details) {
                      if (!_shouldDrag || _controller.isAnimating) return;

                      final screenWidth = MediaQuery.of(context).size.width;
                      final xOffset =
                          _drawerWidth + max(0.0, ((screenWidth - _drawerWidth - (screenWidth * widget.scale)) / 2));
                      _controller.animationValue += details.primaryDelta! / xOffset;
                    }
                    ..onEnd = (details) {
                      if (!_shouldDrag) return;

                      final dragVelocity = details.velocity.pixelsPerSecond.dx.abs();
                      if (dragVelocity >= kMinFlingVelocity) {
                        final visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;
                        _controller.fling(velocity: visualVelocity);
                      } else if (_controller.animationValue < 0.5) {
                        _controller.close();
                      } else {
                        _controller.open();
                      }
                    };
                },
              ),
            },
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, child) {
                return AbsorbPointer(
                  absorbing: value != ZoomDrawerStatus.closed,
                  child: child,
                );
              },
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
