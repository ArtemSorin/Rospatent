import 'package:flutter/material.dart';
import 'package:flutter_application1/models/search_page_model.dart';
import 'package:flutter_application1/patent_api.dart';
import 'package:flutter_application1/patent_page.dart';
import 'package:tag_highlight_text/tag_highlight_text.dart';

import 'screen_analyze.dart';

class SecondHome extends StatefulWidget {
  const SecondHome({Key? key}) : super(key: key);
  static SecondHomeState? state;
  @override
  State<SecondHome> createState() => state = SecondHomeState();
}

class SecondHomeState extends State<SecondHome> {
  List<Patent> patents = [];
  int _selectedScreenIndex = 1;
  List<BottomNavigationBarItem> pageButtons = [
    const BottomNavigationBarItem(icon: Text(''), label: '0'),
    const BottomNavigationBarItem(icon: Text(''), label: '1'),
    const BottomNavigationBarItem(icon: Text(''), label: '2'),
  ];
  void addItemsToPatents(SearchResult res) {
    setState(() {
      patents.addAll(res.patents);

      if (res.currenPage > 0) {
        pageButtons[0] = BottomNavigationBarItem(
            icon: const Text(''), label: (res.currenPage - 1).toString());
      } else {
        pageButtons[0] = BottomNavigationBarItem(
            icon: const Text(''), label: (res.pagesCount - 1).toString());
      }
      pageButtons[1] = BottomNavigationBarItem(
          icon: const Text(''), label: (res.currenPage).toString());
      if (res.currenPage < res.pagesCount - 1) {
        pageButtons[2] = BottomNavigationBarItem(
            icon: const Text(''), label: (res.currenPage + 1).toString());
      } else {
        pageButtons[2] =
            const BottomNavigationBarItem(icon: Text(''), label: '0');
      }
    });
  }

  void _selectScreen(int index) async {
    _selectedScreenIndex = index;
    patents.clear();
    int i = int.parse(pageButtons[index].label ?? '0');
    addItemsToPatents(
        (await api.switchPage(SearchPageModel.patents!, i)) ?? SearchResult());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Найденные патенты"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalyzePage()),
                );
              },
              icon: const Icon(Icons.analytics)),
        ],
        leading: IconButton(
          icon: const Icon(Icons.navigate_before),
          tooltip: 'Go to the previous page',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedScreenIndex,
        onTap: _selectScreen,
        items: pageButtons,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ListView.builder(
              itemCount: patents.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          SearchPageModel.onPatentClicked(patents[index]);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PatentScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            TagHighlightText(
                              text: patents[index].snippet!.title,
                              highlightBuilder: (tagName) {
                                switch (tagName) {
                                  case 'em':
                                    return HighlightData(
                                        style: const TextStyle(
                                            backgroundColor:
                                                Colors.yellowAccent));
                                }
                                return null;
                              },
                              textStyle: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            TagHighlightText(
                                text: patents[index].snippet!.desc,
                                highlightBuilder: (tagName) {
                                  switch (tagName) {
                                    case 'em':
                                      return HighlightData(
                                          style: const TextStyle(
                                              backgroundColor:
                                                  Colors.yellowAccent));
                                  }
                                  return null;
                                },
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                )),
                          ],
                        ),
                      )),
                );
              }),
        )
      ]),
    ));
  }
}
