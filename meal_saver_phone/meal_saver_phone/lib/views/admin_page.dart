import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/admin_user_details_page.dart';
import 'package:meal_saver_phone/widgets/custom_admin_appbar.dart';
import 'package:meal_saver_phone/services/api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      final fetchedUsers = await apiService.getAllUsers();
      if (mounted) {
        setState(() {
          users = fetchedUsers;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading users")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: const CustomAdminAppBar(title: "All Users", showBack: false),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : users.isEmpty
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AdminUserDetailsPage(
                                      username: user['username'],
                                    ),
                              ),
                            );

                            fetchAllUsers();
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
