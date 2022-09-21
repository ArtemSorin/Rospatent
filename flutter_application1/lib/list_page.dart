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
  //final List<String> _users = ["Tom", "Alice", "Sam", "Bob", "Kate"];
  List<Patent> patents = [];

  void addItemsToPatents(SearchResult res) {
    setState(() {
      patents.addAll((SearchPageModel.patents ?? SearchResult()).patents);
    });
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
