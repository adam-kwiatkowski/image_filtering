import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';

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
      themeMode: ThemeMode.system,
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
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ImageInput(
              onImageSelected: (image) => {
                image.readAsBytes().then((value) => {
                  setState(() {
                    _image = value;
                  })
                })
              },
            ),
            SizedBox(
              width: 350,
              height: 350,
              child: Card(
                child: _image == null ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.auto_awesome),
                    SizedBox(
                      height: 15,
                    ),
                    Text('Filter results will appear here'),
                  ],
                ) : Image.memory(_image!),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          setState(() {
            _image = null;
          })
        },
        tooltip: 'Restart',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods
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
          widget.onImageSelected(_image!);
        })
      },
      child: SizedBox(
        width: 350,
        height: 350,
        child: Card(
          shape: _isDragging ? RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ) : null,
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
