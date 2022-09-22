import 'package:flutter/material.dart';
import 'list_page.dart';
import 'models/search_page_model.dart' as model;

class ScreenA extends StatefulWidget {
  const ScreenA({Key? key}) : super(key: key);

  @override
  State<ScreenA> createState() => _ScreenA();
}

class _ScreenA extends State<ScreenA> {
  int sortValue = 1;
  bool isCheckedFirst = false;
  bool isCheckedSecond = false;
  TextEditingController searchTextController = TextEditingController();
  TextEditingController patenteeTextController = TextEditingController();
  TextEditingController authorsTextController = TextEditingController();

  DateTime selectedDateLess = DateTime(0);

  _selectDateLess(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateLess,
      firstDate: DateTime(0),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateLess) {
      setState(() {
        selectedDateLess = picked;
      });
    }
  }

  DateTime selectedDateGreater = DateTime(0);

  _selectDateGreater(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateGreater,
      firstDate: DateTime(0),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateGreater) {
      setState(() {
        selectedDateGreater = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Поиск')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: TextField(
                  controller: searchTextController,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    prefixIconColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Поиск по тексту',
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 1),
              child: Text(
                'Сортировать по',
              ),
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
                  child: DropdownButton<int>(
                    value: sortValue,
                    items: const [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(
                          "Релевантности",
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(
                          "Дате публикации↑",
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text(
                          "Дате публикации↓",
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 4,
                        child: Text(
                          "Дате регистрации↑",
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 5,
                        child: Text(
                          "Дате регистрации↓",
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortValue = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text('Дата публикации до: '),
                ElevatedButton(
                  //color: Colors.blue,
                  onPressed: () => _selectDateLess(context),
                  child: Text(
                    "${selectedDateLess.toLocal()}".split(' ')[0],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text('Дата публикации от: '),
                ElevatedButton(
                  //color: Colors.blue,
                  onPressed: () => _selectDateGreater(context),
                  child: Text(
                    "${selectedDateGreater.toLocal()}".split(' ')[0],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Номер заявки',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
              child: TextFormField(
                controller: authorsTextController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Авторы (ФИО через запятую)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              child: TextFormField(
                controller: patenteeTextController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Патентообладатели (ФИО через запятую)',
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  model.SearchPageModel.onSearchClicked(
                    searchTextController.text,
                    sortingTypes: sortValue - 1,
                    patentee: patenteeTextController.text,
                    authors: authorsTextController.text,
                  );

                  //Route route =
                  //MaterialPageRoute(builder: (context) => SecondHome());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecondHome()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    //backgroundColor: Colors.red,
                    ),
                child: const Text("Поиск"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
