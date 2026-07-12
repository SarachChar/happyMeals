import 'package:flutter/material.dart';
import 'package:happymeal_application/controllers/example_post_controller.dart';
import 'package:happymeal_application/models/example_post_model.dart';
import 'package:happymeal_application/services/example_post_service.dart';
import 'dart:math';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Post> posts = List.empty();
  bool isLoading = false;
  PostController controller = PostController(PostFirebaseService());
  
  final random = Random();

  Map<String, dynamic> get mockData => {
    "post_id": random.nextInt(1000).toString(),
    "title": "Post ${random.nextInt(100)}",
    "views": random.nextInt(1000),
    "isRead": random.nextBool(),
  };

  initState() {
    super.initState();
    controller.onSync.listen((bool syncState) {
      setState(() {
        isLoading = syncState;
      });
    });
  }

  void _getPosts() async {
    var newPosts = await controller.fetchPosts();
    setState(() {
      posts = newPosts;
    });
  }

  void _uploadMockData() async {
    Post post = Post(
      mockData['post_id'] as String,
      mockData['title'] as String,
      mockData['views'] as int,
      mockData['isRead'] as bool,
    );
    await controller.addPost(post);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock data uploaded to Firebase')),
    );
  }

  Widget get body => isLoading
    ? CircularProgressIndicator()
    : ListView.builder(
      itemCount: posts.isNotEmpty ? posts.length : 1,
      itemBuilder: (context, index) {
        if (posts.isNotEmpty) {
          return CheckboxListTile(
            title: Text(posts[index].title),
            value: posts[index].isRead,
            onChanged: (value) {
              setState(() => posts[index].isRead = value!);
              controller.markAsRead(posts[index]);
            }
          );
        }

        return Center(
          child: Text('Press to fetch posts'),
        );
      }
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Post Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Upload mock data',
            onPressed: _uploadMockData,
          ),
        ],
      ),
      body:  Center(
        child: body,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _getPosts,
      )
    );
  }
}
