import 'dart:async';
import 'package:happymeal_application/models/example_post_model.dart';
import 'package:happymeal_application/services/example_post_service.dart';

class PostController {
  List<Post> posts = List.empty();
  final PostService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  PostController(this.service);

  Future<void> markAsRead(Post post) async{
    onSyncController.add(true);
    await service.updatePost(post);
    onSyncController.add(false);
  }

  Future<Post> addPost(Post post) async {
    onSyncController.add(true);
    Post newPost = await service.addPost(post);
    onSyncController.add(false);
    return newPost;
  }

  Future<List<Post>> fetchPosts() async {
    onSyncController.add(true);
    posts = await service.getPosts();
    onSyncController.add(false);
    return posts;
  }
}