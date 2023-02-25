import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/filters.dart';
import 'package:provider/provider.dart';

import 'functional_filters.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FiltersModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: const MyHomePage(title: 'Image filtering'),
      ),
    );
  }
}

class FiltersModel extends ChangeNotifier {
  final List<ImageFilter> _filters = [
    NoFilter(),
    InvertFilter(),
    GrayscaleFilter()
  ];

  List<ImageFilter> get filters => _filters;

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ImageFilter item = _filters.removeAt(oldIndex);
    _filters.insert(newIndex, item);
    notifyListeners();
  }

  void add(ImageFilter filter) {
    _filters.add(filter);
    notifyListeners();
  }

  void remove(ImageFilter filter) {
    _filters.remove(filter);
    notifyListeners();
  }

  void clear() {
    _filters.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? _originalImage;

  void _handleImageSelected(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    decodeImageFromList(bytes).then((value) => {
          setState(() {
            _originalImage = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
//   title: Text(widget.title),
// ),
      body: Center(
        child: Row(
          children: [
            const Expanded(flex: 2, child: FiltersSidebar()),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ImageInput(
                            onImageSelected: _handleImageSelected,
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          ImagePreview(image: _originalImage),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Apply filters',
        child: const Icon(Icons.auto_awesome),
      ), // This trailing comma makes auto-formatting nicer for build methods
    );
  }
}

class FiltersSidebar extends StatelessWidget {
  const FiltersSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var filters = context.watch<FiltersModel>();
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 12, 16),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
                child: ReorderableListView(
              onReorder: filters.reorder,
              children: [
                for (var i = 0; i < filters.filters.length; i++)
                  ListTile(
                      key: ValueKey(i),
                      dense: true,
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
                      title: Text(filters.filters[i].name),
                      leading: const Icon(Icons.pentagon_outlined),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          filters.remove(filters.filters[i]);
                        },
                      )),
              ],
            )),
            Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // Foreground color
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                        onPressed: () {},
                        child: const Text('Save filter'),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Clear all"),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required ui.Image? image,
  }) : _image = image;

  final ui.Image? _image;

  @override
  Widget build(BuildContext context) {
    var filters = context.watch<FiltersModel>();
    return SizedBox(
      width: 350,
      height: 350,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Filter results will appear here'),
                ],
              )
            : FutureBuilder<ui.Image>(
                future: buildImage(filters),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RawImage(
                      image: snapshot.data!,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
      ),
    );
  }

  // Future<ui.Image> buildImage(FiltersModel filters) async {
  //   final pixels = await _image!.toByteData();
  //   final result = await compute(applyFilters, {
  //     'pixels': pixels!.buffer.asUint8List(),
  //     'width': _image!.width,
  //     'height': _image!.height,
  //     'filters': filters.filters,
  //   });
  //   final completer = Completer<ui.Image>();
  //   ui.decodeImageFromPixels(result, _image!.width, _image!.height,
  //       ui.PixelFormat.rgba8888, completer.complete);
  //   return completer.future;
  // }
  Future<ui.Image> buildImage(FiltersModel filters) {
    return _image!.toByteData().then((pixels) {
      return compute(applyFilters, {
        'pixels': pixels!.buffer.asUint8List(),
        'width': _image!.width,
        'height': _image!.height,
        'filters': filters.filters,
      }).then((result) {
        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(result, _image!.width, _image!.height,
            ui.PixelFormat.rgba8888, completer.complete);
        return completer.future;
      });
    });
  }
}

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onImageSelected,
  });

  final Function(XFile) onImageSelected;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  XFile? _image;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) => {
        setState(() {
          _isDragging = true;
        })
      },
      onDragExited: (details) => {
        setState(() {
          _isDragging = false;
        })
      },
      onDragDone: (details) => {
        setState(() {
          _image = details.files.first;
          if (_image!.path.endsWith('.png') || _image!.path.endsWith('.jpg')) {
            widget.onImageSelected(_image!);
          } else {
            _image = null;
          }
        })
      },
      child: SizedBox(
        width: 350,
        height: 350,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: _isDragging
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                )
              : null,
          child: _image == null
              ? Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined),
                      SizedBox(
                        height: 15,
                      ),
                      Text("Drag and drop an image here"),
                    ],
                  ),
                )
              : Image.file(File(_image!.path)),
        ),
      ),
    );
  }
}
