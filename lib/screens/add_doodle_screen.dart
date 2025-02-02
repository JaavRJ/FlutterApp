import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'dart:ui' as ui;

import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddDoodleScreen extends StatefulWidget {
  const AddDoodleScreen({Key? key}) : super(key: key);

  @override
  _AddDoodleScreen createState() => _AddDoodleScreen();
}

class _AddDoodleScreen extends State<AddDoodleScreen> {
  static const Color red = Color.fromARGB(255, 0, 0, 0);
      final ImagePicker _picker = ImagePicker(); // Inicializa el picker

  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;


  @override
  void initState() {
    super.initState();
    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: const FreeStyleSettings(
              color: red,
              strokeWidth: 5,
            ),
            shape: ShapeSettings(
              paint: shapePaint,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 1,
              maxScale: 5,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    //initBackground();
  }

  /// Fetches image from an [ImageProvider] (in this example, [NetworkImage])
  /// to use it as a background
  void initBackground() async {
    // Extension getter (.image) to get [ui.Image] from [ImageProvider]
    final image =
        await const NetworkImage('https://res.cloudinary.com/dgrhyyuef/image/upload/v1724303978/17580_1_tmntet.jpg').image;

    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  Widget buildDefault(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          // Listen to the controller and update the UI when it updates.
          child: ValueListenableBuilder<PainterControllerValue>(
              valueListenable: controller,
              child: const Text("Doodle vv"),
              builder: (context, _, child) {
                return AppBar(
                  title: child,
                  actions: [
                    // Delete the selected drawable
                    IconButton(
                      icon: const Icon(
                        FontAwesome.trash,
                      ),
                      onPressed: controller.selectedObjectDrawable == null
                          ? null
                          : removeSelectedDrawable,
                    ),
                    // Delete the selected drawable
                    IconButton(
                      icon: const Icon(
                        Icons.flip,
                      ),
                      onPressed: controller.selectedObjectDrawable != null &&
                              controller.selectedObjectDrawable is ImageDrawable
                          ? flipSelectedImageDrawable
                          : null,
                    ),
                    // Redo action
                    IconButton(
                      icon: const Icon(
                        Ionicons.arrow_redo_outline,
                      ),
                      onPressed: controller.canRedo ? redo : null,
                    ),
                    // Undo action
                    IconButton(
                      icon: const Icon(
                        Ionicons.arrow_undo_outline,
                      ),
                      onPressed: controller.canUndo ? undo : null,
                    ),
                  ],
                );
              }),
        ),
        // Generate image
        floatingActionButton: FloatingActionButton(
          onPressed: renderAndDisplayImage,
          child: const Icon(
            Ionicons.image_outline,
          ),
        ),
        body: Stack(
        children: [
          // Enforces constraints
          Positioned.fill(
            child: Center(
              child: FlutterPainter(
                controller: controller,
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, _, __) => Container(
                width: 250,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(right: 10, top: 40, bottom: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.8),
                ),
                child: ListView(
                  children: [
                    if (controller.freeStyleMode != FreeStyleMode.none) ...[
                      const Text("Pintaditas", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      Row(
                        children: [
                          const Text("Grosor"),
                          Expanded(
                            child: Slider.adaptive(
                              min: 2,
                              max: 25,
                              value: controller.freeStyleStrokeWidth,
                              onChanged: setFreeStyleStrokeWidth,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (controller.freeStyleMode == FreeStyleMode.draw)
                        Row(
                          children: [
                            const Text("Color"),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(" "),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: controller.freeStyleColor,
                                      onColorChanged: (color) {
                                        setState(() {
                                          controller.freeStyleColor = color;
                                        });
                                      },
                                      showLabel: false,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: const Text('Select'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.freeStyleColor,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(' '),
                            ),
                          ],
                        ),
                    ],
                    if (textFocusNode.hasFocus) ...[
                      const Divider(),
                      const Text(" Estilos Texto", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      Row(
                        children: [
                          const Text("Fuente Size"),
                          Expanded(
                            child: Slider.adaptive(
                              min: 8,
                              max: 96,
                              value: controller.textStyle.fontSize ?? 14,
                              onChanged: setTextFontSize,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Color"),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(" "),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: controller.textStyle.color ?? Colors.black,
                                    onColorChanged: (color) {
                                      setState(() {
                                        controller.textStyle = controller.textStyle.copyWith(color: color);
                                      });
                                    },
                                    showLabel: false,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text('Selecciona'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.textStyle.color ?? Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(' '),
                          ),
                        ],
                      ),
                    ],
                    if (controller.shapeFactory != null) ...[
                      const Divider(),
                      const Text("Estilos Formas", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      Row(
                        children: [
                          const Text("Grosor"),
                          Expanded(
                            child: Slider.adaptive(
                              min: 2,
                              max: 25,
                              value: controller.shapePaint?.strokeWidth ?? shapePaint.strokeWidth,
                              onChanged: (value) =>
                                  setShapeFactoryPaint((controller.shapePaint ?? shapePaint).copyWith(strokeWidth: value)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Color"),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(" "),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: controller.shapePaint?.color ?? Colors.black,
                                    onColorChanged: changeShapeColor,
                                    showLabel: false,
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text('Select'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.shapePaint?.color ?? Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(' '),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Fill"),
                          const SizedBox(width: 10),
                          Switch(
                            value: (controller.shapePaint ?? shapePaint).style == PaintingStyle.fill,
                            onChanged: (value) => setShapeFactoryPaint(
                              (controller.shapePaint ?? shapePaint).copyWith(
                                style: value ? PaintingStyle.fill : PaintingStyle.stroke,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
  
 
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, _, __) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Free-style eraser
              IconButton(
                icon: Icon(
                  PhosphorIcons.eraser(),
                  color: controller.freeStyleMode == FreeStyleMode.erase
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                onPressed: toggleFreeStyleErase,
              ),
              // Free-style drawing
              IconButton(
                icon: Icon(
                  PhosphorIcons.scribbleLoop(),
                  color: controller.freeStyleMode == FreeStyleMode.draw
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                onPressed: toggleFreeStyleDraw,
              ),
              // Add text
              IconButton(
                icon: Icon(
                  PhosphorIcons.textT(),
                  color: textFocusNode.hasFocus
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                onPressed: addText,
              ),
              // Add sticker image
              IconButton(
                icon: const Icon(
                  FontAwesome.image,
                ),
                onPressed: selectImageFromGallery,
              ),
              // Add shapes
              if (controller.shapeFactory == null)
                PopupMenuButton<ShapeFactory?>(
                  tooltip: "Add shape",
                  itemBuilder: (context) => <ShapeFactory, String>{
                    LineFactory(): "Line",
                    ArrowFactory(): "Arrow",
                    DoubleArrowFactory(): "Double Arrow",
                    RectangleFactory(): "Rectangle",
                    OvalFactory(): "Oval",
                  }
                      .entries
                      .map((e) => PopupMenuItem(
                          value: e.key,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                getShapeIcon(e.key),
                                color: Colors.black,
                              ),
                              Text(" ${e.value}")
                            ],
                          )))
                      .toList(),
                  onSelected: selectShape,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      getShapeIcon(controller.shapeFactory),
                      color: controller.shapeFactory != null
                          ? Theme.of(context).colorScheme.secondary
                          : null,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    getShapeIcon(controller.shapeFactory),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => selectShape(null),
                ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildDefault(context);
  }

  static IconData getShapeIcon(ShapeFactory? shapeFactory) {
    if (shapeFactory is LineFactory) return PhosphorIcons.lineSegment();
    if (shapeFactory is ArrowFactory) return PhosphorIcons.arrowUpRight();
    if (shapeFactory is DoubleArrowFactory) {
      return PhosphorIcons.arrowsHorizontal();
    }
    if (shapeFactory is RectangleFactory) return PhosphorIcons.rectangle();
    if (shapeFactory is OvalFactory) return PhosphorIcons.circle();
    return PhosphorIcons.polygon();
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw
        ? FreeStyleMode.draw
        : FreeStyleMode.none;
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase
        ? FreeStyleMode.erase
        : FreeStyleMode.none;
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

 Future<void> selectImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final image = await decodeImageFromList(bytes);
      setState(() {
        controller.addImage(image);
        
      });
    }
  }
  void setFreeStyleStrokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setFreeStyleColor(double hue) {
    controller.freeStyleColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
      controller.textSettings = controller.textSettings.copyWith(
          textStyle:
              controller.textSettings.textStyle.copyWith(fontSize: size));
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void setTextColor(double hue) {
    controller.textStyle = controller.textStyle
        .copyWith(color: HSVColor.fromAHSV(1, hue, 1, 1).toColor());
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

   void changeShapeColor(Color color) {
    setState(() {
      controller.shapePaint = (controller.shapePaint ?? Paint()).copyWith(color: color);
    });
  }

  void renderAndDisplayImage() {
    if (backgroundImage == null) return;
    final backgroundImageSize = Size(
        backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());

    // Render the image
    // Returns a [ui.Image] object, convert to to byte data and then to Uint8List
    final imageFuture = controller
        .renderImage(backgroundImageSize)
        .then<Uint8List?>((ui.Image image) => image.pngBytes);

    // From here, you can write the PNG image data a file or do whatever you want with it
    // For example:
    // ```dart
    // final file = File('${(await getTemporaryDirectory()).path}/img.png');
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    // ```
    // I am going to display it using Image.memory

    // Show a dialog with the image
    showDialog(
        context: context,
        builder: (context) => RenderedImageDialog(imageFuture: imageFuture));
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(
        imageDrawable, imageDrawable.copyWith(flipped: !imageDrawable.flipped));
  }
}

class RenderedImageDialog extends StatelessWidget {
  final Future<Uint8List?> imageFuture;

  const RenderedImageDialog({Key? key, required this.imageFuture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rendered Image"),
      content: FutureBuilder<Uint8List?>(
        future: imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox();
          }
          return InteractiveViewer(
              maxScale: 10, child: Image.memory(snapshot.data!));
        },
      ),
    );
  }
}

class SelectStickerImageDialog extends StatelessWidget {
  final List<String> imagesLinks;

  const SelectStickerImageDialog({Key? key, this.imagesLinks = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select sticker"),
      content: imagesLinks.isEmpty
          ? const Text("No images")
          : FractionallySizedBox(
              heightFactor: 0.5,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    for (final imageLink in imagesLinks)
                      InkWell(
                        onTap: () => Navigator.pop(context, imageLink),
                        child: FractionallySizedBox(
                          widthFactor: 1 / 4,
                          child: Image.network(imageLink),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}