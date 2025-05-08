import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatelessWidget {
  final Map<String, dynamic> videoData;

  const RecipeDetailsPage({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    final description = videoData['description'] ?? '';
    final tags = List<String>.from(videoData['tags'] ?? []);
    final username = videoData['username'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Details"),
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      ),
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "@${username}'s Recipe",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Description:",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(description, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            if (tags.isNotEmpty) ...[
              const Text(
                "Tags:",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8,
                children:
                    tags
                        .map(
                          (tag) => Chip(
                            label: Text('#$tag'),
                            backgroundColor: Colors.white12,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
