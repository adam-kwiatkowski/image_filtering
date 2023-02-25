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
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
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
              buildDefaultDragHandles: false,
              onReorder: filters.reorder,
              children: [
                for (var filter in filters.filters)
                  filter is CompositeFilter
                      ? ListTileTheme(
                          dense: true,
                          key: ValueKey(filter),
                          child: ExpansionTile(
                            title: Text(filter.name),
                            controlAffinity: ListTileControlAffinity.leading,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PopupMenuButton(itemBuilder: (context) {
                                  return [
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove'),
                                    ),
                                  ];
                                }, onSelected: (value) {
                                  if (value == 'remove') {
                                    filters.remove(filter);
                                  }
                                }),
                                ReorderableDragStartListener(
                                    index: filters.filters.indexOf(filter),
                                    child: const Icon(Icons.drag_handle))
                              ],
                            ),
                            children: [
                              for (var subFilter in filter.filters)
                                buildSubListTile(subFilter)
                            ],
                          ),
                        )
                      : ListTileTheme(
                          iconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          key: ValueKey(filter),
                          child: buildListTile(filter, filters)),
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

  ListTile buildSubListTile(ImageFilter filter) {
    return ListTile(
      key: ValueKey(filter),
      dense: true,
      // contentPadding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
      title: Text(filter.name),
      leading: Icon(filter.icon),
    );
  }

  ListTile buildListTile(ImageFilter filter, FiltersModel filters) {
    return ListTile(
      key: ValueKey(filter),
      dense: true,
      // contentPadding: const EdgeInsets.fromLTRB(16, 0, 24, 0),
      title: Text(filter.name),
      leading: Icon(filter.icon),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove'),
              ),
            ];
          }, onSelected: (value) {
            if (value == 'remove') {
              filters.remove(filter);
            }
          }),
          ReorderableDragStartListener(
              index: filters.filters.indexOf(filter),
              child: const Icon(Icons.drag_handle)),
        ],
      ),
    );
  }
}
