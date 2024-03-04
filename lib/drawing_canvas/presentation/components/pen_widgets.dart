import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drawing/drawing_canvas/domain/drawing_mode.dart';
import 'package:drawing/drawing_canvas/presentation/components/icon_box.dart';

class PenWidgets extends StatelessWidget {
  const PenWidgets({
    super.key,
    required this.drawingMode,
    required this.polygonSides,
  });

  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<int> polygonSides;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: drawingMode.value == DrawingMode.polygon
                ? Row(
                    children: [
                      const Text(
                        'Polygon Sides: ',
                        style: TextStyle(fontSize: 12),
                      ),
                      Slider(
                        value: polygonSides.value.toDouble(),
                        min: 3,
                        max: 8,
                        onChanged: (val) {
                          polygonSides.value = val.toInt();
                        },
                        label: '${polygonSides.value}',
                        divisions: 5,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 5,
            runSpacing: 5,
            children: [
              IconBox(
                iconData: FontAwesomeIcons.pencil,
                selected: drawingMode.value == DrawingMode.pencil,
                onTap: () => drawingMode.value = DrawingMode.pencil,
                tooltip: 'Pencil',
              ),
              IconBox(
                selected: drawingMode.value == DrawingMode.line,
                onTap: () => drawingMode.value = DrawingMode.line,
                tooltip: 'Line',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 2,
                      color: drawingMode.value == DrawingMode.line
                          ? Colors.grey[900]
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
              IconBox(
                iconData: Icons.hexagon_outlined,
                selected: drawingMode.value == DrawingMode.polygon,
                onTap: () => drawingMode.value = DrawingMode.polygon,
                tooltip: 'Polygon',
              ),
              IconBox(
                iconData: FontAwesomeIcons.eraser,
                selected: drawingMode.value == DrawingMode.eraser,
                onTap: () => drawingMode.value = DrawingMode.eraser,
                tooltip: 'Eraser',
              ),
              IconBox(
                iconData: FontAwesomeIcons.square,
                selected: drawingMode.value == DrawingMode.square,
                onTap: () => drawingMode.value = DrawingMode.square,
                tooltip: 'Square',
              ),
              IconBox(
                iconData: FontAwesomeIcons.circle,
                selected: drawingMode.value == DrawingMode.circle,
                onTap: () => drawingMode.value = DrawingMode.circle,
                tooltip: 'Circle',
              ),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(100)),
                child: TextButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
