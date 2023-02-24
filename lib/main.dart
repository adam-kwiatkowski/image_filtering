import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/filtering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  ui.Image? _image;
  List<ImageSubFilter> _filters = [GrayscaleFilter(), NoFilter()];

  void _handleImageSelected(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    decodeImageFromList(bytes).then((value) => {
          setState(() {
            _image = value;
          })
        });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ImageSubFilter item = _filters.removeAt(oldIndex);
      _filters.insert(newIndex, item);
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
            Expanded(
                flex: 2,
                child: Container(
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
                          onReorder: _handleReorder,
                          children: [
                            for (var i = 0; i < _filters.length; i++)
                              ListTile(
                                key: ValueKey(i),
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 8, 24, 8),
                                title: Text(_filters[i].toString()),
                                leading: const Icon(Icons.pentagon_outlined),
                              ),
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
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ).copyWith(
                                        elevation:
                                            ButtonStyleButton.allOrNull(0.0)),
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
                )),
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
                          ImagePreview(image: _image)
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
        onPressed: () => {
          setState(() {
            _image = null;
          })
        },
        tooltip: 'To grayscale',
        child: const Icon(Icons.auto_awesome),
      ), // This trailing comma makes auto-formatting nicer for build methods
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
            : RawImage(
                image: _image!,
              ),
      ),
    );
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
