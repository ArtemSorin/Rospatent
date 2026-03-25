import 'package:flutter/material.dart';
import 'package:rospatent/models/prefs.dart';
import 'package:rospatent/data/patent_api.dart';
import 'package:rospatent/screens/patent_screen.dart';

import '../models/search_page_model.dart';

import '../widgets/custom_app_bar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  void _removeFromFavorites(String id) {
    setState(() {
      Preferences.prefs.favoriteIds.remove(id);
    });
    Preferences.prefs.removeFavorite(id);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Preferences.prefs.favoriteIds;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Избранное",
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
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final id = favorites[index];
                return Dismissible(
                  key: Key(id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeFromFavorites(id),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        "Патент № $id",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        "Нажмите, чтобы открыть детали",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _removeFromFavorites(id),
                      ),
                      onTap: () {
                        var p = Patent.empty();
                        p.id = id;
                        SearchPageModel.onPatentClicked(p);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatentScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "У вас пока нет избранных патентов",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              "Добавляйте патенты в избранное, чтобы быстро находить их позже",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
