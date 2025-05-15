import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/video_player_page.dart';

class TagSearchResultsPage extends StatefulWidget {
  final String tag;

  const TagSearchResultsPage({super.key, required this.tag});

  @override
  State<TagSearchResultsPage> createState() => _TagSearchResultsPageState();
}

class _TagSearchResultsPageState extends State<TagSearchResultsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
      _controller.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "#${widget.tag}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : videos.isEmpty
              ? const Center(
                child: Text(
                  "No videos found",
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
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
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                thumb,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stack) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                    ),
                              ),
                              Container(color: Colors.black26),
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white70,
                                  size: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
