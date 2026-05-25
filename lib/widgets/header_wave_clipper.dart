import 'package:flutter/material.dart';

class HeaderWaveClipper extends CustomClipper<Path> {
  final double curveDepth;

  const HeaderWaveClipper({this.curveDepth = 40.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - curveDepth);

    final firstControlPoint = Offset(size.width / 2, size.height + (curveDepth == 40.0 ? 15 : 0));
    final firstEndPoint = Offset(size.width, size.height - curveDepth);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
