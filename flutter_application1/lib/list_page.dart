import 'package:flutter/material.dart';

class SecondHome extends StatefulWidget {
  const SecondHome({Key? key}) : super(key: key);

  @override
  State<SecondHome> createState() => _SecondHomeState();
}

class _SecondHomeState extends State<SecondHome> {
  final List<String> _users = ["Tom", "Alice", "Sam", "Bob", "Kate"];
  int _selectedIndex = -1;
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            title: Text(_users[index], style: const TextStyle(fontSize: 24)),
            leading: const Icon(Icons.document_scanner),
            trailing: IconButton(
              icon: _selectedIndex == index
                  ? const Icon(Icons.star_border)
                  : const Icon(Icons.star),
              onPressed: () {
                _selectedIndex = index;
              },
            ),
            selected: index == _selectedIndex,
            selectedTileColor: Colors.black12,
          ),
        ))
      ]),
    ));
  }
}
