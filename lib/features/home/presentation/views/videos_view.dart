import 'package:body_part_selector/body_part_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/core/helpers/capetilize.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/features/body_part_selector/data/models/body_parts_model.dart';
import 'package:physio_app/features/home/data/models/video_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:hive/hive.dart';

class VideosView extends StatefulWidget {
  const VideosView({super.key});

  @override
  State<VideosView> createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosView> {
  bool isAdmin = false;
  List<VideoModel> allVideos = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';
  VideoModel? selectedVideo;
  YoutubePlayerController? _youtubeController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  /// Load selected body parts from Hive.
  Future<BodyPartsHiveWrapper> _loadBodyParts() async {
    final box = await Hive.openBox<BodyPartsHiveWrapper>('bodyPartsBox');
    // Provide a default empty map if none exists.
    return box.get('selectedParts', defaultValue: BodyPartsHiveWrapper({}))!;
  }

  /// Fetch videos from Firestore and filter based on selected body parts.
  Future<void> _fetchVideos() async {
    // Check if the user is an admin.
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    final role = userSnapshot.data()?['role'] as String?;
    isAdmin = role?.contains('admin') ?? false;

    try {
      // Fetch all videos.
      final videoSnapshot =
          await FirebaseFirestore.instance.collection('videos').get();
      final List<VideoModel> videos = videoSnapshot.docs.map((doc) {
        return VideoModel(
          link: doc['link'],
          category: doc['category'],
        );
      }).toList();

      // Load the user's selected body parts.
      final bodyParts = await _loadBodyParts();
      print(bodyParts);
      // Build a set of selected body parts (normalize keys to lowercase).
      final Set<String> selectedParts = bodyParts.selectedBodyParts.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.toLowerCase())
          .toSet();

      // Debug prints:
      // debugPrint("Selected body parts: $selectedParts");
      // debugPrint("Video categories: ${videos.map((v) => v.category.toLowerCase()).toSet()}");

      // If no body parts are selected, show all videos.
      final List<VideoModel> filteredByBodyParts = selectedParts.isNotEmpty
          ? videos.where((video) {
              return selectedParts.contains(video.category.toLowerCase());
            }).toList()
          : videos;

      // Build the category selector list: "All" plus the selected body parts.
      final List<String> bodyPartCategories =
          selectedParts.isNotEmpty ? selectedParts.toList() : [];

      setState(() {
        allVideos = filteredByBodyParts;
        categories = ['All', ...bodyPartCategories];
        if (filteredByBodyParts.isNotEmpty) {
          selectedVideo = filteredByBodyParts.first;
          _youtubeController = YoutubePlayerController(
            initialVideoId:
                YoutubePlayer.convertUrlToId(selectedVideo!.link) ?? '',
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: false,
            ),
          );
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching videos: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Returns the videos filtered by the selected category.
  List<VideoModel> get filteredVideos {
    if (selectedCategory.toLowerCase() == 'all') return allVideos;
    return allVideos
        .where((video) =>
            video.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  /// Change the selected video in the player.
  void _selectVideo(VideoModel video) {
    setState(() {
      selectedVideo = video;
      if (_youtubeController != null) {
        final videoId = YoutubePlayer.convertUrlToId(video.link) ?? '';
        _youtubeController!.load(videoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
        actions: [
          // Show add button only for admins.
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.push('/videos-admin');
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // YouTube Player on top.
                if (_youtubeController != null)
                  YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                  )
                else
                  const SizedBox(
                      height: 200,
                      child: Center(child: Text("No video selected"))),
                const SizedBox(height: 10),
                // Category selector (horizontal list) showing "All" + selected body parts.
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final bool isSelected =
                          cat.toLowerCase() == selectedCategory.toLowerCase();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              capetilize(cat),
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                // Video selector list.
                Expanded(
                  child: filteredVideos.isEmpty
                      ? Center(
                          child: Text("No videos available",
                              style: TextStyles.headline2
                                  .copyWith(color: Colors.white)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: filteredVideos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final video = filteredVideos[index];
                            final bool isSelected = video == selectedVideo;
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected
                                    ? BorderSide(color: Colors.blue, width: 2)
                                    : BorderSide.none,
                              ),
                              elevation: isSelected ? 4 : 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Icon(
                                  Icons.play_circle_filled,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  size: 32,
                                ),
                                title: Text(
                                  video.link,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  video.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                        size: 24,
                                      )
                                    : null,
                                onTap: () => _selectVideo(video),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }
}
