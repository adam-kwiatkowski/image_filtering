import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'filters_sidebar.dart';
import 'image_input.dart';
import 'image_preview.dart';
import 'models/filters_model.dart';

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
