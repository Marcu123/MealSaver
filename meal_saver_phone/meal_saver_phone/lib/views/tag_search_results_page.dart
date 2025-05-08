import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/video_player_page.dart';

class TagSearchResultsPage extends StatefulWidget {
  final String tag;

  const TagSearchResultsPage({super.key, required this.tag});

  @override
  State<TagSearchResultsPage> createState() => _TagSearchResultsPageState();
}

class _TagSearchResultsPageState extends State<TagSearchResultsPage> {
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final list = await ApiService().filterVideosByTags([widget.tag]);
      if (!mounted) return;
      setState(() {
        videos = list;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Results for #${widget.tag}"),
        backgroundColor: Colors.black,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : videos.isEmpty
              ? const Center(
                child: Text(
                  "No videos found",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final thumb = (video['videoUrl'] as String)
                      .replaceFirst("/upload/", "/upload/so_0/")
                      .replaceAll(".mp4", ".jpg");
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(videoData: video),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(thumb, fit: BoxFit.cover),
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white70,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
