import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/models/example_post_model.dart';
import 'package:http/http.dart';
import 'dart:convert';

abstract class PostService {
  Future<List<Post>> getPosts();
  Future<void> updatePost(Post post);
  Future<Post> addPost(Post post);
}

class PostFirebaseService implements PostService {
  Future<List<Post>> getPosts() async {
    QuerySnapshot qs = await FirebaseFirestore.instance.collection('posts').get();
    AllPosts all = AllPosts.fromSnapshot(qs);
    return all.posts;
  }

  @override
  Future<void> updatePost(Post post) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.dbId);
    await postRef.update({
      'isRead': post.isRead,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Post> addPost(Post post) async {
    final postRef = await FirebaseFirestore.instance.collection('posts').add({
      'post_id': post.id,
      'title': post.title,
      'views': post.views,
      'isRead': post.isRead,
      'timestamp': FieldValue.serverTimestamp(),
    });
    post.dbId = postRef.id;
    return post;
  }
}


class PostHttpService implements PostService {
  Client client = Client();

  @override
  Future<List<Post>> getPosts() async {
    final response = await client.get(
      Uri.parse('http://10.104.5.177:3000/posts'),
    );

    if (response.statusCode == 200) {
       var all = AllPosts.fromJson(json.decode(response.body));
      return all.posts;
    }
    throw Exception('Failed to load posts');
    
  }

  @override
  Future<Post> addPost(Post post) {
    // TODO: implement addPost
    throw UnimplementedError();
  }

  @override
  Future<void> updatePost(Post post) {
    // TODO: implement updatePost
    throw UnimplementedError();
  }
}