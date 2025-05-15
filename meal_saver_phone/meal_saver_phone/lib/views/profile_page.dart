import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/services/stomp_service.dart';
import 'package:meal_saver_phone/views/login_page.dart';
import 'package:meal_saver_phone/views/update_profile_page.dart';
import 'package:meal_saver_phone/views/video_player_page.dart';
import 'package:meal_saver_phone/widgets/custom_app_bar.dart';
import 'package:meal_saver_phone/widgets/custom_button1.dart';
import 'package:meal_saver_phone/widgets/custom_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String email = "";
  String fullName = "";
  String? profileImageUrl;
  List<Map<String, dynamic>> myVideos = [];
  List<Map<String, dynamic>> likedVideos = [];
  bool showLiked = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMyVideos();
    _loadLikedVideos();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await ApiService().getCurrentUser();
      if (!mounted) return;
      if (data == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }
      setState(() {
        username = data['username'] ?? "";
        email = data['email'] ?? "";
        fullName =
            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        profileImageUrl = data['profileImageUrl'];
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _loadMyVideos() async {
    try {
      final videos = await ApiService().getMyRecipeVideos();
      if (!mounted) return;
      setState(() {
        myVideos = videos;
      });
    } catch (e) {
      print("Error loading videos: $e");
    }
  }

  Future<void> _loadLikedVideos() async {
    try {
      final videos = await ApiService().getLikedVideos();
      if (!mounted) return;
      setState(() {
        likedVideos = videos;
      });
    } catch (e) {
      print("Error loading liked videos: $e");
    }
  }

  void _toggleGrid() {
    setState(() {
      showLiked = !showLiked;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    StompService().disconnect();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showUploadModal() {
    final videoUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Upload Recipe Video",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: videoUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Video URL",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await picker.pickVideo(
                        source: ImageSource.gallery,
                      );
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        final url = await ApiService().uploadVideoToCloudinary(
                          bytes,
                        );
                        if (url != null && mounted) {
                          setModalState(() {
                            videoUrlController.text = url;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upload complete!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upload failed')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No video selected')),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text(
                      "Pick & Upload Video",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextField(
                    controller: tagsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Tags (comma separated)",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final tags =
                          tagsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList();
                      final result = await ApiService().uploadRecipeVideo(
                        videoUrl: videoUrlController.text,
                        description: descriptionController.text,
                        tags: tags,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result)));
                      await _loadMyVideos();
                    },
                    child: const Text("Upload"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedVideos = showLiked ? likedVideos : myVideos;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: const CustomAppBar(title: "Profile", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage("assets/images/logo.png")
                          as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              fullName,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              "@$username",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 30, 30, 30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CustomButton2(
                    text: "Update Information",
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdateProfilePage(),
                        ),
                      );
                      if (updated == true) {
                        _logout();
                      } else {
                        await _loadUserData();
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  CustomButton1(
                    text: "Change Password",
                    onPressed: _showUploadModal,
                  ),
                  const SizedBox(height: 15),
                  CustomButton1(text: "Log Out", onPressed: _logout),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _toggleGrid,
                        icon: Icon(
                          showLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.pinkAccent,
                        ),
                        tooltip: "Toggle Liked Videos",
                      ),
                      Text(
                        showLiked
                            ? "Liked Videos (${likedVideos.length})"
                            : "My Videos (${myVideos.length})",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: displayedVideos.length + (showLiked ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == 0 && !showLiked) {
                  return GestureDetector(
                    onTap: _showUploadModal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 40),
                      ),
                    ),
                  );
                }
                final video = displayedVideos[showLiked ? index : index - 1];
                final videoUrl = video['videoUrl'] as String;
                final thumbnailUrl = videoUrl
                    .replaceFirst("/upload/", "/upload/so_0/")
                    .replaceAll(".mp4", ".jpg");
                return GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(videoData: video),
                        ),
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(thumbnailUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
