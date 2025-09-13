import 'package:flutter/material.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onTap;

  const SOSButton({super.key, required this.onTap});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 🟢 Pulsing aura effect (behind everything)
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final opacity = (_opacityAnimation.value - (0.2 * index))
                  .clamp(0.0, 1.0);

              return Transform.scale(
                scale: _scaleAnimation.value - (0.15 * index),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index.isEven
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // 🔴 Outer circle (bright redAccent-like)
        Container(
          width: 270,
          height: 270,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFCDD2), // lighter than redAccent
          ),
        ),

        // 🔴 Middle circle (redAccent)
        Container(
          width: 225,
          height: 225,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
          ),
        ),

        // 🔴 Main SOS button (center, on top)
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.red[700]!, Colors.red[600]!],
                stops: const [0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Color.fromARGB(115, 167, 167, 167),
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
