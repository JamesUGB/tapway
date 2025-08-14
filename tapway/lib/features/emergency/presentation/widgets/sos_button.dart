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
        // Pulsing aura effect (multiple layers)
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Clamp opacity values to ensure they're between 0.0 and 1.0
              final opacity = (_opacityAnimation.value - (0.2 * index)).clamp(
                0.0,
                1.0,
              );

              return Transform.scale(
                scale: _scaleAnimation.value - (0.15 * index),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 250,
                    height: 250,
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

        // Main SOS button
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.red[700],
              shape: BoxShape.circle,
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
              gradient: RadialGradient(
                colors: [Colors.red[800]!, Colors.red[600]!],
                stops: const [0.7, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
