import 'package:flutter/material.dart';

/// NEAREST 스케일링 픽셀아트 아이콘 래퍼.
class PixelArtIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  const PixelArtIcon(this.assetPath, {super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
    );
  }
}
