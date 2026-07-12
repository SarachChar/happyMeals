import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String title;
  int views;
  bool isRead;
  String dbId = '';

  Post(this.id, this.title, this.views, this.isRead);

  factory Post.fromSnapshot(Map<String, dynamic> snapshot) {
    return Post(
      snapshot['post_id'] as String,
      snapshot['title'] as String,
      snapshot['views'] as int? ?? 0,
      snapshot['isRead'] as bool? ?? false,
    );
  }

  factory Post.formJson(Map<String, dynamic> json) {
    return Post(
      json['id'] as String,
      json['title'] as String,
      json['views'] as int? ?? 0,
      json['isRead'] as bool? ?? false,
    );
  }
}

class AllPosts {
  final List<Post> posts;
  AllPosts(this.posts);

  factory AllPosts.fromSnapshot(QuerySnapshot qs) {
    List<Post> posts;

    posts = qs.docs.map((DocumentSnapshot ds) {
      Post post = Post.fromSnapshot(ds.data() as Map<String, dynamic>);
      post.dbId = ds.id;
      return post;
    }) .toList();

    return AllPosts(posts);
  }

  factory AllPosts.fromJson(List<dynamic> json) {
    List<Post> posts;
    posts = json.map((item) => Post.formJson(item)).toList();
    return AllPosts(posts);
  }
}