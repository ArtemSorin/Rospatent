import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'list_page.dart';
import 'package:flutter_application1/patent_api.dart';
import 'models/search_page_model.dart' as model;

class PatentScreen extends StatefulWidget {
  const PatentScreen({Key? key}) : super(key: key);
  static PatentScreenState? state;
  @override
  State<PatentScreen> createState() => state = PatentScreenState();
}

class PatentScreenState extends State<PatentScreen> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text((model.SearchPageModel.selectedPatent ?? Patent.empty())
                    .title["ru"] ??
                "")),
        body: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  const Text('Авторы: '),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: ((model.SearchPageModel.selectedPatent ??
                                      Patent.empty())
                                  .inventor["ru"] ??
                              [])
                          .length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                    ((model.SearchPageModel.selectedPatent ??
                                                Patent.empty())
                                            .inventor["ru"] ??
                                        [])[index])));
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  const Text('Патентообладатели: '),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: ((model.SearchPageModel.selectedPatent ??
                                      Patent.empty())
                                  .inventor["ru"] ??
                              [])
                          .length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                    ((model.SearchPageModel.selectedPatent ??
                                                Patent.empty())
                                            .patentee["ru"] ??
                                        [])[index])));
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Заявитель: ${((model.SearchPageModel.selectedPatent ?? Patent.empty()).snippet ?? PatentSnippet.empty()).applicant}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Дата публикации: ${DateFormat('yyyy.MM.dd').format((model.SearchPageModel.selectedPatent ?? Patent.empty()).publicationDate ?? DateTime(0))}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Дата подачи заявки: ${DateFormat('yyyy.MM.dd').format((model.SearchPageModel.selectedPatent ?? Patent.empty()).filingDate ?? DateTime(0))}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'МПК: \n${((model.SearchPageModel.selectedPatent ?? Patent.empty()).snippet ?? PatentSnippet.empty()).ipc}\n${((model.SearchPageModel.selectedPatent ?? Patent.empty()).snippet ?? PatentSnippet.empty()).cpc}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Номер: ${(model.SearchPageModel.selectedPatent ?? Patent.empty()).number}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Реферат: ${(model.SearchPageModel.selectedPatent ?? Patent.empty()).abstract["ru"] ?? ""}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Формула: ${(model.SearchPageModel.selectedPatent ?? Patent.empty()).claims["ru"] ?? ""}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Описание: ${(model.SearchPageModel.selectedPatent ?? Patent.empty()).desc["ru"] ?? ""}',
              ),
            )
          ],
        ),
      ),
    );
  }
}
