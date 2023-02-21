import 'package:flutter/material.dart';
import '../stream/catestreams.dart';

class CategoryBody extends StatefulWidget {
  const CategoryBody({super.key});

  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  get index => null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getCategoryStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data!;

        final userAddedCategories =
            categories.where((category) => category['name'] != null).toList();

        return SizedBox(
          height: 50.0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 300.0,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: getCategoryStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final categories = snapshot.data!;
                        final selectedCategory = categories.firstWhere(
                            (category) => category['index'] == index);

                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: getobjectStream(selectedCategory['index']),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final objects = snapshot.data!;

                            return ListView.builder(
                              itemCount: objects.length,
                              itemBuilder: (context, index) {
                                final obj = objects[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(obj['name'] ?? ''),
                                    subtitle: Text(obj['subjects'].join(', ')),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: userAddedCategories.length,
              itemBuilder: (context, index) {
                final category = userAddedCategories[index];
                return Card(
                  color: Colors.deepPurpleAccent,
                  child: SizedBox(
                    width: 100.0,
                    height: 50.0,
                    child: Center(
                      child: Text(category['name'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
