import 'dart:ui' as ui;
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../drawing_canvas/domain/drawing_mode.dart';
import 'package:drawing/drawing_canvas/domain/sketch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drawing/drawing_canvas/presentation/components/icon_box.dart';
import 'package:drawing/drawing_canvas/presentation/components/undo_redo.dart';
import 'package:drawing/drawing_canvas/presentation/components/canvas_sidebar.dart';
import 'package:drawing/drawing_canvas/presentation/components/drawring_canvas.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);

    final canvasGlobalKey = GlobalKey();
    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    final undoRedoStack = useState(
      UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );

    Future<void> saveFile(String filename, Uint8List bytes) async {
      try {
        final result = await ImageGallerySaver.saveImage(
          bytes,
          name: filename,
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Your Drawing is Saved to Gallary")));
        } else {
          log('Failed to save file to gallery: ${result['errorMessage']}');
        }
      } catch (e) {
        log('Error saving file: $e');
      }
    }

    Future<Uint8List?> getBytes() async {
      RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    }

    return Scaffold(
      drawer: CanvasSideBar(
        selectedColor: selectedColor,
        strokeSize: strokeSize,
        eraserSize: eraserSize,
        drawingMode: drawingMode,
        currentSketch: currentSketch,
        allSketches: allSketches,
        canvasGlobalKey: canvasGlobalKey,
        filled: filled,
        polygonSides: polygonSides,
      ),
      appBar: AppBar(
        backgroundColor: selectedColor.value,
        leading: IconButton(
            onPressed: () async {
              var status = await Permission.manageExternalStorage.request();
              log(status.toString());
              if (status.isGranted) {
                log('Storage permission granted');
                Uint8List? pngBytes = await getBytes();
                if (pngBytes != null) {
                  saveFile("Test.png", pngBytes);
                }
              } else if (status == PermissionStatus.denied) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Permission is required")));
              }
            },
            icon: const Icon(Icons.download)),
        actions: [
          Wrap(
            children: [
              TextButton(
                onPressed: allSketches.value.isNotEmpty
                    ? () => undoRedoStack.value.undo()
                    : null,
                child: const Text('Undo'),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: undoRedoStack.value.canRedo,
                builder: (_, canRedo, __) {
                  return TextButton(
                    onPressed:
                        canRedo ? () => undoRedoStack.value.redo() : null,
                    child: const Text('Redo'),
                  );
                },
              ),
              TextButton(
                child: const Text('Clear'),
                onPressed: () => undoRedoStack.value.clear(),
              ),
            ],
          ),
        ],
      ),
      body: Builder(builder: (context) {
        return Stack(
          children: [
            Container(
              color: Colors.white,
              width: double.maxFinite,
              height: double.maxFinite,
              child: DrawingCanvas(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                sideBarController: animationController,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
              ),
            ),
            Padding(
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
            ),
          ],
        );
      }),
    );
  }
}
