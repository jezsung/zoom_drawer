import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'zoom_drawer_status.dart';

class ZoomDrawerController extends ValueNotifier<ZoomDrawerStatus> {
  ZoomDrawerController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
  })  : _animationController = AnimationController(
          vsync: vsync,
          duration: duration,
        ),
        super(ZoomDrawerStatus.closed) {
    _animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          value = ZoomDrawerStatus.closed;
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          value = ZoomDrawerStatus.animating;
          break;
        case AnimationStatus.completed:
          value = ZoomDrawerStatus.open;
          break;
      }
    });
  }

  final AnimationController _animationController;

  Animation<double> get animation => _animationController.view;
  double get animationValue => _animationController.value;
  set animationValue(v) {
    _animationController.value = v;
  }

  bool get isOpen => _animationController.isCompleted;
  bool get isClosed => _animationController.isDismissed;
  bool get isAnimating => _animationController.isAnimating;

  Future<void> open() async {
    if (isAnimating) return;
    await _animationController.forward();
  }

  Future<void> close() async {
    if (isAnimating) return;
    await _animationController.reverse();
  }

  Future<void> toggle() async {
    if (isAnimating) return;
    if (isOpen) {
      await _animationController.reverse();
    } else {
      await _animationController.forward();
    }
  }

  Future<void> fling({
    double velocity = 1.0,
    SpringDescription? springDescription,
    AnimationBehavior? animationBehavior,
  }) async {
    await _animationController.fling(
      velocity: velocity,
      springDescription: springDescription,
      animationBehavior: animationBehavior,
    );
  }

  @mustCallSuper
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
