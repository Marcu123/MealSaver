import 'package:flutter/material.dart';
import 'package:meal_saver_phone/views/other_profile_page.dart';
import 'package:video_player/video_player.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _showEditModal() {
    final descriptionController = TextEditingController(
      text: widget.videoData['description'],
    );
    final tagsController = TextEditingController(
      text: (widget.videoData['tags'] as List).join(', '),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                "Edit Video",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                maxLines: null,
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
                  final newDescription = descriptionController.text.trim();
                  final newTags =
                      tagsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  final id = widget.videoData['id'] as int;
                  final result = await ApiService().updateRecipeVideo(
                    id: id,
                    description: newDescription,
                    tags: newTags,
                  );

                  setState(() {
                    widget.videoData['description'] = newDescription;
                    widget.videoData['tags'] = newTags;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result)));
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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
                    onPressed: _showEditModal,
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
                        const SizedBox(height: 5),
                        Text(
                          widget.videoData['description'] ?? '',
                          style: const TextStyle(color: Colors.white70),
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
                          ],
                        ),
                        if (widget.videoData['tags'] != null)
                          Wrap(
                            spacing: 8,
                            children: List<Widget>.from(
                              (widget.videoData['tags'] as List).map(
                                (tag) => Chip(
                                  label: Text('#$tag'),
                                  backgroundColor: Colors.white10,
                                  labelStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
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
