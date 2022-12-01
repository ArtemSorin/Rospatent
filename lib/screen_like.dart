import 'package:flutter/material.dart';
import 'package:flutter_application1/models/prefs.dart';
import 'package:flutter_application1/patent_api.dart';
import 'package:flutter_application1/patent_page.dart';

import 'models/search_page_model.dart';

class ScreenB extends StatelessWidget {
  const ScreenB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: Center(
        child: Column(
          children: [
            ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: Preferences.prefs.favoriteIds.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            var p = Patent.empty();
                            p.id = Preferences.prefs.favoriteIds[index];
                            SearchPageModel.onPatentClicked(p);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PatentScreen()),
                            );
                          },
                          child: Column(
                            children: [
                              Text(Preferences.prefs.favoriteIds[index])
                            ],
                          ),
                        )),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
