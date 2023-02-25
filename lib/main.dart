import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_filtering/models/filter_gallery_model.dart';
import 'package:provider/provider.dart';

import 'filters_sidebar.dart';
import 'image_input.dart';
import 'image_preview.dart';
import 'models/active_filters_model.dart';

void main() {
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
    var filterGallery = context.watch<FilterGalleryModel>();
    return Scaffold(
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
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.45),
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
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Row(
                            children: [
                              for (var filter in filterGallery.list)
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () => {
                                        context
                                            .read<ActiveFiltersModel>()
                                            .add(filter)
                                      },
                                      child: Text(filter.name),
                                    )),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
