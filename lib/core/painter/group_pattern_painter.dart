import 'package:flutter/material.dart';
import 'package:elements_app/core/painter/base_pattern_painter.dart';

class GroupPatternPainter extends BasePatternPainter {
  GroupPatternPainter(Color color)
      : super(
          color: color,
          opacity: 0.05,
          gridSpacing: 40,
        );
}
