import 'package:flutter/material.dart';
import 'list_page.dart';

class ScreenA extends StatefulWidget {
  const ScreenA({Key? key}) : super(key: key);

  @override
  State<ScreenA> createState() => _ScreenA();
}

class _ScreenA extends State<ScreenA> {
  int _value = 1;
  bool isCheckedFirst = false;
  bool isCheckedSecond = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Поиск по названию',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Сначала показывать',
              ),
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: DropdownButton<int>(
                    value: _value,
                    items: const [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(
                          "Second",
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(
                          "First",
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text(
                          "Th",
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _value = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              child: Text(
                'Тип',
              ),
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  value: isCheckedFirst,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedFirst = value!;
                    });
                  },
                ),
                const Text("Заявка"),
                Checkbox(
                  checkColor: Colors.white,
                  value: isCheckedSecond,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedSecond = value!;
                    });
                  },
                ),
                const Text("Патент"),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Номер заявки',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Заявитель',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Патентообладатель',
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  //api.FindParams params = new api.FindParams();
                  //params.formal = "патент";
                  //params.informal = "патент";

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
