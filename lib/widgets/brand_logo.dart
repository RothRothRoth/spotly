import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;
  const BrandLogo({super.key, this.fontSize = 44});

  @override
  Widget build(BuildContext context) {
    // Prefer to show provided logo asset; fallback to styled text if asset missing at runtime
    return Center(
      child: SizedBox(
        height: fontSize * 1.4,
        child: Image.asset(
          'assets/spotly_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'sp',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -1.5,
                  ),
                ),
                Icon(
                  Icons.location_on_rounded,
                  size: fontSize * 1.05,
                  color: const Color(0xFFBCAAA4),
                ),
                Text(
                  'tly',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
