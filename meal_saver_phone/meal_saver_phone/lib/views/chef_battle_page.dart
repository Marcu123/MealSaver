import 'package:flutter/material.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:meal_saver_phone/views/other_profile_page.dart';
import 'package:meal_saver_phone/views/recipe_details_page.dart';
import 'package:meal_saver_phone/widgets/custom_bottom_bar.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class RecipeVideoDTO {
  final int id;
  final String videoUrl;
  final List<String> tags;
  final String description;
  final String thumbnailUrl;
  final int likes;
  final String username;
  final bool likedByUser;

  RecipeVideoDTO({
    required this.id,
    required this.videoUrl,
    required this.tags,
    required this.description,
    required this.thumbnailUrl,
    required this.likes,
    required this.username,
    required this.likedByUser,
  });

  factory RecipeVideoDTO.fromJson(Map<String, dynamic> json) {
    return RecipeVideoDTO(
      id: json['id'] as int,
      videoUrl: json['videoUrl'] as String? ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      likedByUser: json['likedByUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoUrl': videoUrl,
    'tags': tags,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'likes': likes,
    'username': username,
    'likedByUser': likedByUser,
  };
}

class ChefBattlePage extends StatefulWidget {
  const ChefBattlePage({super.key});

  @override
  State<ChefBattlePage> createState() => _ChefBattlePageState();
}

class _ChefBattlePageState extends State<ChefBattlePage>
    with SingleTickerProviderStateMixin {
  List<RecipeVideoDTO> videos = [];
  late PageController _pageController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  bool _isLoading = true;
  Set<int> likedVideoIds = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      final results = await Future.wait([
        ApiService().getRandomRecipeVideos(),
        ApiService().getLikedVideos(),
      ]);

      final response = results[0];
      final liked = results[1];
      final likedIds = liked.map((v) => v['id'] as int).toSet();

      if (mounted) {
        setState(() {
          videos =
              response.map((json) {
                json['likedByUser'] = likedIds.contains(json['id']);
                return RecipeVideoDTO.fromJson(json);
              }).toList();
          _isLoading = false;
        });

        if (videos.isNotEmpty) {
          _loadVideo(videos[0].videoUrl);
        }
      }
    } catch (e) {
      print("Error fetching videos: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadVideo(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController!.play();
          _videoController!.setLooping(true);
        }
      });
  }

  void _onPageChanged(int index) {
    if (index >= videos.length) return;
    setState(() => _currentIndex = index);
    _loadVideo(videos[index].videoUrl);
  }

  Future<void> _toggleLike(int videoId) async {
    try {
      if (likedVideoIds.contains(videoId)) {
        await ApiService().unlikeRecipeVideo(videoId);
        setState(() {
          likedVideoIds.remove(videoId);
          videos[_currentIndex] = RecipeVideoDTO(
            id: videos[_currentIndex].id,
            videoUrl: videos[_currentIndex].videoUrl,
            tags: videos[_currentIndex].tags,
            description: videos[_currentIndex].description,
            thumbnailUrl: videos[_currentIndex].thumbnailUrl,
            likes: videos[_currentIndex].likes - 1,
            username: videos[_currentIndex].username,
            likedByUser: false,
          );
        });
      } else {
        final updatedVideo = await ApiService().likeRecipeVideo(videoId);
        setState(() {
          videos[_currentIndex] = RecipeVideoDTO.fromJson(updatedVideo);
          likedVideoIds.add(videoId);
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: _onPageChanged,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final isLiked = video.likedByUser;
                  return Stack(
                    children: [
                      Center(
                        child:
                            _videoController != null &&
                                    _videoController!.value.isInitialized
                                ? AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                )
                                : const CircularProgressIndicator(),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => OtherProfilePage(
                                            username: video.username,
                                          ),
                                    ),
                                  ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '@${video.username}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              video.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children:
                                  video.tags
                                      .map(
                                        (tag) => Chip(
                                          label: Text('#$tag'),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            103,
                                            55,
                                            192,
                                          ),
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color:
                                        isLiked ? Colors.red : Colors.white38,
                                  ),
                                  onPressed: () => _toggleLike(video.id),
                                ),
                                Text(
                                  '${video.likes}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => RecipeDetailsPage(
                                              videoData: video.toJson(),
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.receipt_long),
                                  label: const Text("See Recipe"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      130,
                                      24,
                                      230,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 3),
    );
  }
}
