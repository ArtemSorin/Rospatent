import 'package:flutter/material.dart';

class SecondHome extends StatelessWidget {
  const SecondHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Найденные патенты"),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            tooltip: 'Go to the previous page',
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, position) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  position.toString(),
                  style: const TextStyle(fontSize: 22.0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
