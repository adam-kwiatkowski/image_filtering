import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/models/filter_gallery_model.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import 'widgets/filter_gallery.dart';
import 'widgets/filters_sidebar.dart';
import 'widgets/image_input.dart';
import 'widgets/image_preview.dart';
import 'models/active_filters_model.dart';

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
                        padding: const EdgeInsets.all(32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: ImageInput(
                                onImageSelected: _handleImageSelected,
                              ),
                            ),
                            const SizedBox(
                              width: 32,
                            ),
                            Expanded(
                                child: ImagePreview(image: _originalImage)),
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
}
