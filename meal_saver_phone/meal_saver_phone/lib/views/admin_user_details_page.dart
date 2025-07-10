import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/admin_video_preview_page.dart';

class AdminUserDetailsPage extends StatefulWidget {
  final String username;

  const AdminUserDetailsPage({super.key, required this.username});

  @override
  State<AdminUserDetailsPage> createState() => _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState extends State<AdminUserDetailsPage> {
  final ApiService apiService = ApiService();

  Map<String, dynamic>? user;
  List<Map<String, dynamic>> foods = [];
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final fetchedUser = await apiService.getUserByUsername(widget.username);
      final fetchedFoods = await apiService.getFoodsByUser(widget.username);
      final fetchedVideos = await apiService.getVideosByUser(widget.username);

      setState(() {
        user = fetchedUser;
        foods = fetchedFoods;
        videos = fetchedVideos;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading user details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditFoodDialog(Map<String, dynamic> food) {
    final nameCtrl = TextEditingController(text: food['name']);
    final sizeCtrl = TextEditingController(text: food['size'].toString());
    final dateCtrl = TextEditingController(
      text: food['expirationDate']?.split('T').first ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Food"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: sizeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Size in g"),
                ),
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(
                    labelText: "Expiration Date (YYYY-MM-DD)",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await apiService.updateFoodByName(food['name'], {
                    "name": nameCtrl.text,
                    "size": int.tryParse(sizeCtrl.text) ?? food['size'],
                    "expirationDate": dateCtrl.text,
                  });
                  Navigator.pop(context);
                  _loadUserDetails();
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _showEditVideoDialog(Map<String, dynamic> video) {
    final descCtrl = TextEditingController(text: video['description']);
    final tagsCtrl = TextEditingController(
      text: (video['tags'] as List<dynamic>).join(', '),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Video"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Tags (comma-separated)",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await apiService.updateVideoById(video['id'], {
                    "description": descCtrl.text,
                    "tags":
                        tagsCtrl.text.split(',').map((e) => e.trim()).toList(),
                  });
                  Navigator.pop(context);
                  _loadUserDetails();
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _showEditUserDialog() {
    final firstNameCtrl = TextEditingController(text: user?['firstName']);
    final lastNameCtrl = TextEditingController(text: user?['lastName']);
    final emailCtrl = TextEditingController(text: user?['email']);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(labelText: "First Name"),
                ),
                TextField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(labelText: "Last Name"),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await apiService.updateUserInfo(
                    username: widget.username,
                    firstName: firstNameCtrl.text,
                    lastName: lastNameCtrl.text,
                    email: emailCtrl.text,
                  );
                  Navigator.pop(context);
                  _loadUserDetails();
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this user?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await apiService.deleteUser(widget.username);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User deleted.")));
      }
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: AppBar(
        title: Text('@${widget.username} - Admin View'),
        backgroundColor: Colors.black,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : user == null
              ? const Center(
                child: Text(
                  "User not found",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionTitle("Account Info"),
                      Text(
                        "Name: ${user!['firstName']} ${user!['lastName']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Email: ${user!['email']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Created At: ${user!['createdAt']?.split('T').first ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Is Admin: ${user!['admin'] == true ? 'Yes' : 'No'}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit User"),
                            onPressed: _showEditUserDialog,
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text("Delete User"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: _confirmDeleteUser,
                          ),
                        ],
                      ),

                      buildSectionTitle("Foods (${foods.length})"),
                      ...foods.map((food) {
                        final name = food['name'] ?? '';
                        final size = food['size']?.toString() ?? '';
                        final date =
                            food['expirationDate']?.split('T').first ?? '';
                        return Card(
                          color: const Color.fromARGB(255, 30, 30, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              "$name: $size g (exp. $date)",
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => _showEditFoodDialog(food),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    await apiService.deleteFoodById(food['id']);
                                    _loadUserDetails();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      buildSectionTitle("Recipe Videos (${videos.length})"),
                      ...videos.map((video) {
                        final description = video['description'] ?? '';
                        final tags = (video['tags'] as List<dynamic>).join(
                          ', ',
                        );
                        final likes = video['likes']?.toString() ?? '0';
                        final created =
                            video['createdAt']?.split('T').first ?? '';
                        final videoUrl = video['videoUrl'] ?? '';
                        final thumbnailUrl = videoUrl
                            .replaceFirst("/upload/", "/upload/so_0/")
                            .replaceAll(".mp4", ".jpg");

                        return Card(
                          color: const Color.fromARGB(255, 30, 30, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AdminVideoPreviewPage(
                                        videoUrl: videoUrl,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      thumbnailUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.black26,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white54,
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Description:",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          description,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Tags:",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          tags,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Likes:",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              likes,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              "Created:",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              created,
                                              style: TextStyle(
                                                color: Colors.white38,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white70,
                                        ),
                                        onPressed:
                                            () => _showEditVideoDialog(video),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          await apiService.deleteVideoById(
                                            video['id'],
                                          );

                                          _loadUserDetails();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
    );
  }
}
