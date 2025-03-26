import 'dart:convert';
import 'package:offline_blog_app/models/post.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('social_blogger.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE posts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      imagePaths TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
    ''');
  }

  // Create post
  Future<Post> createPost(Post post) async {
    final db = await instance.database;
    final id = await db.insert('posts', post.toMap());
    return post.copyWith(id: id);
  }

  // Read all posts
  Future<List<Post>> readAllPosts() async {
    final db = await instance.database;
    final result = await db.query('posts', orderBy: 'createdAt DESC');
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // Read single post
  Future<Post?> readPost(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Post.fromMap(maps.first);
    }
    return null;
  }

  // Update post
  Future<int> updatePost(Post post) async {
    final db = await instance.database;
    return db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // Delete post
  Future<int> deletePost(int id) async {
    final db = await instance.database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete multiple posts
  Future<int> deleteMultiplePosts(List<int> ids) async {
    final db = await instance.database;
    return await db.delete(
      'posts',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }

  // Search posts
  Future<List<Post>> searchPosts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'posts',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
