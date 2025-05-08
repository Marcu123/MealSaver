import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/other_profile_page.dart';
import 'package:meal_saver_phone/views/user_search_result_page.dart';
import 'package:meal_saver_phone/views/video_player_page.dart';
import 'package:meal_saver_phone/views/tag_search_results_page.dart'; // asigură-te că ai această pagină

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  String searchType = 'users';
  String query = '';
  List results = [];
  bool isLoading = false;

  void _performSearch() async {
    if (searchType == 'tags') {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TagSearchResultsPage(tag: query)),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final users = await ApiService().searchUsers(query);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserSearchResultsPage(users: users, query: query),
        ),
      );
    } catch (e) {
      print("❌ Error searching users: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      title: const Text("Search", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: searchType,
            dropdownColor: Colors.black,
            items: const [
              DropdownMenuItem(
                value: 'users',
                child: Text("Users", style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'tags',
                child: Text("Tags", style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (val) => setState(() => searchType = val!),
          ),
          TextField(
            onChanged: (val) => query = val,
            decoration: const InputDecoration(
              hintText: 'Enter search...',
              hintStyle: TextStyle(color: Colors.white38),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text("Search"),
          ),
          if (isLoading) const CircularProgressIndicator(),
          if (searchType == 'users' && results.isNotEmpty)
            ...results.map(
              (r) => ListTile(
                title: Text(
                  '@${r['username']}',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtherProfilePage(username: r['username']),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
