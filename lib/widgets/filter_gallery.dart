import 'package:flutter/material.dart';
import 'package:image_filtering/filters/filters.dart';
import 'package:image_filtering/filters/predefined_filters.dart';
import 'package:image_filtering/models/filter_gallery_model.dart';
import 'package:provider/provider.dart';

import '../models/active_filters_model.dart';

class FilterGallery extends StatelessWidget {
  const FilterGallery({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var filterGallery = context.watch<FilterGalleryModel>();
    var activeFilters = context.watch<ActiveFiltersModel>();
    var scrollController = ScrollController();
    return SizedBox(
      height: 73,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Scrollbar(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
            child: ListView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              children: filterGallery.list
                  .map((e) => Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                        child: ElevatedButton(
                            onLongPress: () {
                              if (!predefinedFilters.contains(e)) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('Remove ${e.name}?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel')),
                                            TextButton(
                                                onPressed: () {
                                                  filterGallery.remove(e);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Remove')),
                                          ],
                                        ));
                              }
                            },
                            onPressed: () {
                              activeFilters.add(e);
                            },
                            child: Row(
                              children: [
                                Icon(e.icon),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(e.name),
                              ],
                            )),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  AspectRatio buildFilterCard(ImageFilter e) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.name,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Icon(e.icon),
                ),
              ],
            )),
      ),
    );
  }
}
