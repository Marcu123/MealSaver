import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/other_profile_page.dart';
import 'package:meal_saver_phone/widgets/custom_app_bar.dart';

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
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: CustomAppBar(title: "Users matching '$query'", showBack: true),
      body: SafeArea(
        child:
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        color: const Color.fromARGB(255, 34, 34, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                imgUrl.isNotEmpty
                                    ? NetworkImage(imgUrl)
                                    : const AssetImage("assets/images/logo.png")
                                        as ImageProvider,
                          ),
                          title: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "@${user['username']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white38,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => OtherProfilePage(
                                      username: user['username'],
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
