// lib/widgets/typing_indicator.dart
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF1EFEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0.0),
              SizedBox(width: 4),
              _buildDot(0.2),
              SizedBox(width: 4),
              _buildDot(0.4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(double delay) {
    final double delayedValue = ((_controller.value + delay) % 1.0);
    final double opacityValue =
        (delayedValue < 0.5) ? delayedValue * 2 : (1.0 - delayedValue) * 2;

    return Opacity(
      opacity: 0.3 + (opacityValue * 0.7),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Color(0xFF6C88D7),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
