import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/user_search_result_page.dart';
import 'package:meal_saver_phone/views/tag_search_results_page.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog>
    with SingleTickerProviderStateMixin {
  String searchType = 'users';
  String query = '';
  List results = [];
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      print("Error searching users: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fade,
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 22, 22, 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Search", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: searchType,
                dropdownColor: const Color.fromARGB(255, 34, 34, 34),
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(color: Colors.white),
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
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) => query = val,
                decoration: InputDecoration(
                  hintText: 'Enter search...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 40, 40, 40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 130, 24, 230),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text("Search"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
