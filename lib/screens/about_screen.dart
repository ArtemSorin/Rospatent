import 'package:flutter/material.dart';

import '../widgets/custom_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "О приложении",
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          color: Colors.blueAccent,
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Colors.blueAccent,
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color.fromARGB(26, 33, 150, 243),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 40,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Роспатент",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Поиск патентов в базе данных Роспатента",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                "Это приложение помогает вам в поиске патентов в базе данных Роспатента, "
                "а также сохранять нужные патенты в избранное",
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Основные возможности",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _featureTile(
            Icons.search_outlined,
            "Поиск патентов",
            "Запросы в базу патентов с заданными параметрами",
          ),
          _featureTile(
            Icons.star_outline,
            "Сохранение в избранное",
            "Возможность добавлять нужные патенты в раздел избранного",
          ),
          _featureTile(
            Icons.description_outlined,
            "Детальное описание патента",
            "Полная информация о патенте, включая его статус, правообладателей и т.д.",
          ),
          _featureTile(
            Icons.notifications_active_outlined,
            "Уведомления",
            "Оповещения об изменениях в избранных патентах",
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            color: Colors.grey.shade100,
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
              title: const Text("Версия приложения"),
              subtitle: const Text("1.0.0"),
              trailing: const Text("© 2025"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }
}
