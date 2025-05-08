import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/other_profile_page.dart';

class UserSearchResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final String query;

  const UserSearchResultsPage({
    super.key,
    required this.users,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Users matching '$query'"),
        backgroundColor: Colors.black,
      ),
      body:
          users.isEmpty
              ? const Center(
                child: Text(
                  "No users found",
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final imgUrl = user['profileImageUrl'] ?? '';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          imgUrl.isNotEmpty
                              ? NetworkImage(imgUrl)
                              : const AssetImage("assets/images/logo.png")
                                  as ImageProvider,
                    ),
                    title: Text(
                      "@${user['username']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  OtherProfilePage(username: user['username']),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
