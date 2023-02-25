import 'package:flutter/material.dart';
import 'package:image_filtering/filters.dart';
import 'package:provider/provider.dart';

import 'models/filters_model.dart';

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
                  filters.filters[i] is CompositeFilter
                      ? ExpansionTile(
                          key: ValueKey(i),
                          tilePadding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
                          title: Text(filters.filters[i].name),
                          leading: const Icon(Icons.pentagon_outlined),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              filters.remove(filters.filters[i]);
                            },
                          ),
                          children: [
                            for (var j = 0;
                                j <
                                    (filters.filters[i] as CompositeFilter)
                                        .filters
                                        .length;
                                j++)
                              buildListTile(j, filters)
                          ],
                        )
                      : buildListTile(i, filters)
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

  ListTile buildListTile(int i, FiltersModel filters) {
    return ListTile(
        key: ValueKey(i),
        // dense: true,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
        title: Text(filters.filters[i].name),
        leading: const Icon(Icons.pentagon_outlined),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            filters.remove(filters.filters[i]);
          },
        ));
  }
}
