import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drawing/drawing_canvas/domain/drawing_mode.dart';
import 'package:drawing/drawing_canvas/domain/sketch.dart';
import 'package:drawing/drawing_canvas/presentation/components/canvas_sidebar.dart';
import 'package:drawing/drawing_canvas/presentation/components/drawring_canvas.dart';
import 'package:drawing/drawing_canvas/presentation/components/pen_widgets.dart';
import 'package:drawing/drawing_canvas/presentation/components/undo_redo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({Key? key}) : super(key: key);

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

    Future<void> saveFile(Uint8List bytes) async {
      try {
        final result = await ImageGallerySaver.saveImage(bytes,
            name: DateTime.now().toIso8601String(), quality: 80);

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
                  saveFile(pngBytes);
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
            PenWidgets(drawingMode: drawingMode, polygonSides: polygonSides),
          ],
        );
      }),
    );
  }
}
