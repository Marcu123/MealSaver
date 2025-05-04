import 'package:flutter/material.dart';

class AnimatedFridge extends StatefulWidget {
  final VoidCallback onFridgeOpened;

  const AnimatedFridge({super.key, required this.onFridgeOpened});

  @override
  State<AnimatedFridge> createState() => _AnimatedFridgeState();
}

class _AnimatedFridgeState extends State<AnimatedFridge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool fridgeOpened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1, // un pic de zoom, nu exagerat
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onFridgeOpened();
        });
      }
    });
  }

  void _handleFridgeTap() {
    setState(() {
      fridgeOpened = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleFridgeTap,
      child: AnimatedCrossFade(
        firstChild: Image.asset('assets/images/fridge_closed.png', width: 200),
        secondChild: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset('assets/images/fridge_open.png', width: 220),
          ),
        ),
        crossFadeState:
            fridgeOpened ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}
