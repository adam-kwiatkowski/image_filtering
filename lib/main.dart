import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/models/filter_gallery_model.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import 'filters/filters.dart';
import 'models/active_filters_model.dart';
import 'widgets/filter_gallery.dart';
import 'widgets/filters_sidebar.dart';
import 'widgets/image_input.dart';
import 'widgets/image_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(910, 600));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActiveFiltersModel()),
        ChangeNotifierProvider(create: (_) => FilterGalleryModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Image filtering',
        theme: ThemeData(
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const MyHomePage(title: 'Image filtering'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _imageFile;
  ui.Image? _originalImage;
  ui.Image? _filteredImage;

  void _handleImageSelected(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    decodeImageFromList(bytes).then((value) => {
          setState(() {
            _originalImage = value;
            _filteredImage = value;
            _imageFile = imageFile;
          }),
          _handleFiltersChanged()
        });
  }

  void _handleFiltersChanged() async {
    if (_originalImage == null) {
      return;
    }
    var filters = Provider.of<ActiveFiltersModel>(context, listen: false);
    buildImage(filters).then((value) => {
          setState(() {
            _filteredImage = value;
          })
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveFiltersModel>(context, listen: false)
          .addListener(_handleFiltersChanged);
    });
  }

  @override
  void dispose() {
    Provider.of<ActiveFiltersModel>(context, listen: false)
        .removeListener(_handleFiltersChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: const Icon(Icons.file_open),
              tooltip: 'Open file',
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);

                if (result != null) {
                  var file = XFile(result.files.single.path!);
                  _handleImageSelected(file);
                }
              }),
          IconButton(
            icon: const Icon(Icons.save_as),
            tooltip: 'Save as',
            onPressed: _imageFile != null
                ? () async {
                    var extension = _imageFile!.name.split('.').last;
                    String? path = await FilePicker.platform.saveFile(
                        dialogTitle: 'Save image as',
                        fileName: 'filtered.$extension',
                        type: FileType.image);
                    if (path != null) {
                      var file = File(path);
                      var bytes = await _filteredImage!
                          .toByteData(format: ui.ImageByteFormat.png);
                      await file.writeAsBytes(bytes!.buffer.asUint8List());
                    }
                  }
                : null,
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'Clear',
                  child: Text('Clear images'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'Clear') {
                setState(() {
                  _originalImage = null;
                  _filteredImage = null;
                  _imageFile = null;
                });
              }
            },
          )
        ],
      ),
      body: Center(
        child: Row(
          children: [
            const Expanded(flex: 3, child: FiltersSidebar()),
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.45),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: ImageInput(
                                image: _originalImage,
                                onImageSelected: _handleImageSelected,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: ImagePreview(image: _filteredImage)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const FilterGallery()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ui.Image> buildImage(ActiveFiltersModel filters) {
    return _originalImage!.toByteData().then((pixels) {
      return compute(applyFilters, {
        'pixels': pixels!.buffer.asUint8List(),
        'width': _originalImage!.width,
        'height': _originalImage!.height,
        'filters': filters.list,
      }).then((result) {
        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
            result,
            _originalImage!.width,
            _originalImage!.height,
            ui.PixelFormat.rgba8888,
            completer.complete);
        return completer.future;
      });
    });
  }
}

Uint8List applyFilters(Map<String, dynamic> args) {
  Uint8List pixels = args['pixels'];
  int width = args['width'];
  int height = args['height'];
  List<ImageFilter> filters = args['filters'];

  for (var i = 0; i < filters.length; i++) {
    filters[i].apply(pixels, width, height);
  }

  return pixels;
}
