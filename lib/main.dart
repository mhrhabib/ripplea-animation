import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LockScreen(),
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  LockScreenState createState() => LockScreenState();
}

class LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  AnimationController? animationController;
  double rippleRadius = 0.0;
  Offset tapPosition = const Offset(0.0, 0.0);
  bool isLocked = true;
  double blackOverlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isLocked = false;
        });
      }
    });
  }

  void _onTap(BuildContext context, TapDownDetails details) {
    if (isLocked) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition =
          renderBox.globalToLocal(details.globalPosition);

      setState(() {
        tapPosition = localPosition;
        rippleRadius = MediaQuery.of(context).size.longestSide;
      });

      animationController!.reset();
      animationController!.forward();

      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          rippleRadius = 0.0;
        });
      });
    }
  }

  void _onClosingTap(BuildContext context, TapDownDetails details) {
    if (!isLocked) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition =
          renderBox.globalToLocal(details.globalPosition);

      setState(() {
        tapPosition = localPosition;
        rippleRadius = MediaQuery.of(context).size.longestSide;
        blackOverlayOpacity = 1.0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        animationController!.reset();
        animationController!.forward();
      });

      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          rippleRadius = 0.0;
          isLocked = true;
          blackOverlayOpacity = 0.0;
        });

        animationController!.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          if (isLocked) {
            _onTap(context, details);
          } else {
            _onClosingTap(context, details);
          }
        },
        child: Stack(
          children: [
            Container(
              color: isLocked ? Colors.black : Colors.white,
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: blackOverlayOpacity,
              child: Container(
                color: Colors.black,
              ),
            ),
            Center(
              child: Text(
                isLocked ? 'Locked' : 'Unlocked',
                style: TextStyle(
                  fontSize: 20,
                  color: isLocked ? Colors.white : Colors.black,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              width: rippleRadius,
              height: rippleRadius,
              child: AnimatedBuilder(
                animation: animationController!,
                builder: (context, child) {
                  return CustomPaint(
                    painter: isLocked
                        ? RipplePainter(
                            tapPosition: tapPosition,
                            rippleRadius:
                                rippleRadius * animationController!.value,
                          )
                        : RipplePainter2(
                            tapPosition: tapPosition,
                            rippleRadius: rippleRadius *
                                (1.0 - animationController!.value),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }
}

class RipplePainter extends CustomPainter {
  final Offset tapPosition;
  final double rippleRadius;

  RipplePainter({required this.tapPosition, required this.rippleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    if (rippleRadius > 0) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final blurRect =
          Rect.fromCircle(center: tapPosition, radius: rippleRadius);
      final clipRect =
          Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height))
              .intersect(blurRect);

      canvas.clipRect(clipRect);
      canvas.drawCircle(tapPosition, rippleRadius, paint);

      const blurSigma = 20.0;
      final blurFilter = ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);
      canvas.saveLayer(clipRect, Paint());
      canvas.drawCircle(tapPosition, rippleRadius, paint);
      canvas.restore();
      canvas.saveLayer(clipRect, Paint());
      canvas.drawCircle(
          tapPosition, rippleRadius, paint..imageFilter = blurFilter);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class RipplePainter2 extends CustomPainter {
  final Offset tapPosition;
  final double rippleRadius;

  RipplePainter2({required this.tapPosition, required this.rippleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    if (rippleRadius > 0) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final blurRect =
          Rect.fromCircle(center: tapPosition, radius: rippleRadius);
      final clipRect =
          Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height))
              .intersect(blurRect);

      canvas.clipRect(clipRect);
      canvas.drawCircle(tapPosition, rippleRadius, paint);

      const blurSigma = 20.0;
      final blurFilter = ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);
      canvas.saveLayer(clipRect, Paint());
      canvas.drawCircle(tapPosition, rippleRadius, paint);
      canvas.restore();
      canvas.saveLayer(clipRect, Paint());
      canvas.drawCircle(
          tapPosition, rippleRadius, paint..imageFilter = blurFilter);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
