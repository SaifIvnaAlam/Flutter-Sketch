import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:drawing/drawing_canvas/domain/sketch.dart';
import 'package:drawing/drawing_canvas/domain/drawing_mode.dart';
import 'package:drawing/drawing_canvas/presentation/components/color_palette.dart';

class CanvasSideBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;

  const CanvasSideBar({
    super.key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(10.0),
        controller: scrollController,
        children: [
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stroke Size: ',
                style: TextStyle(fontSize: 12),
              ),
              Slider(
                value: strokeSize.value,
                min: 0,
                max: 50,
                onChanged: (val) {
                  strokeSize.value = val;
                },
              ),
            ],
          ),
          const Text(
            'Eraser Size ',
            style: TextStyle(fontSize: 12),
          ),
          Slider(
            value: eraserSize.value,
            min: 0,
            max: 80,
            onChanged: (val) {
              eraserSize.value = val;
            },
          ),
          Row(
            children: [
              const Text(
                'Fill Shape: ',
                style: TextStyle(fontSize: 12),
              ),
              Checkbox(
                value: filled.value,
                onChanged: (val) {
                  filled.value = val ?? false;
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Export',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(),

          // add about me button or follow buttons
          const Divider(),
          ColorPalette(
            selectedColor: selectedColor,
          ),
        ],
      ),
    );
  }
}
