import 'package:flutter/material.dart';

class ReusableGradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;
  final VoidCallback onPressed;

  const ReusableGradientIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.colors,
    required this.onPressed,
    required String tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: IconButton(onPressed: onPressed, icon: Icon(icon), iconSize: size),
    );
  }
}
