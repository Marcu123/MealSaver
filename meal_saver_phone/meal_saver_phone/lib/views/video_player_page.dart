// importuri neschimbate
import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/other_profile_page.dart';
import 'package:meal_saver_phone/views/recipe_details_page.dart';
import 'package:video_player/video_player.dart';
import 'package:meal_saver_phone/services/api_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoPlayerPage({super.key, required this.videoData});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  late int _likes;
  bool _hasLiked = false;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _likes = widget.videoData['likes'] ?? 0;
    _loadUser();
    _controller = VideoPlayerController.network(widget.videoData['videoUrl'])
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  Future<void> _loadUser() async {
    final user = await ApiService().getCurrentUser();
    if (!mounted) return;
    setState(() {
      currentUsername = user?['username'];
      _hasLiked = (widget.videoData['likedByUser'] ?? false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() async {
    final id = widget.videoData['id'];
    try {
      if (_hasLiked) {
        await ApiService().unlikeRecipeVideo(id);
        setState(() {
          _likes = (_likes - 1).clamp(0, _likes);
          _hasLiked = false;
        });
      } else {
        final updated = await ApiService().likeRecipeVideo(id);
        setState(() {
          _likes = updated['likes'];
          _hasLiked = true;
        });
      }
    } catch (e) {
      print("❌ Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.videoData['username'] == currentUsername;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions:
            isOwner
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final id = widget.videoData['id'];
                      final result = await ApiService().deleteRecipeVideo(id);
                      Navigator.pop(context, 'deleted');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result)));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // opțional: adaugi modal de editare
                    },
                  ),
                ]
                : null,
      ),
      body:
          _controller.value.isInitialized
              ? Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => OtherProfilePage(
                                        username: widget.videoData['username'],
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                '@${widget.videoData['username']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.videoData['description'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children:
                              (widget.videoData['tags'] as List)
                                  .map<Widget>(
                                    (tag) => Chip(
                                      label: Text('#$tag'),
                                      backgroundColor: Colors.white10,
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _toggleLike,
                              icon: Icon(
                                Icons.favorite,
                                color: _hasLiked ? Colors.red : Colors.white38,
                              ),
                            ),
                            Text(
                              '$_likes',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => RecipeDetailsPage(
                                          videoData: widget.videoData,
                                        ),
                                  ),
                                );
                              },
                              child: const Text("See Recipe"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
