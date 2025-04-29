import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

/// Feed仓库提供者
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// 信息流仓库
/// 负责获取和管理文章信息
class FeedRepository {
  // 模拟的文章数据
  final List<Article> _articles = [];
  
  /// 获取所有文章
  Future<List<Article>> getAllArticles() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    return _articles;
  }
  
  /// 根据ID获取文章
  Future<Article?> getArticleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// 按分类获取文章
  Future<List<Article>> getArticlesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _articles
        .where((article) => article.categories.contains(category))
        .toList();
  }
  
  /// 按标签获取文章
  Future<List<Article>> getArticlesByTag(String tag) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _articles
        .where((article) => article.tags.contains(tag))
        .toList();
  }
  
  /// 获取置顶文章
  Future<List<Article>> getPinnedArticles() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _articles
        .where((article) => article.isPinned)
        .toList();
  }
  
  /// 搜索文章
  Future<List<Article>> searchArticles(String query) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lowercaseQuery = query.toLowerCase();
    return _articles
        .where((article) => 
            article.title.toLowerCase().contains(lowercaseQuery) ||
            article.content.toLowerCase().contains(lowercaseQuery) ||
            article.summary?.toLowerCase().contains(lowercaseQuery) == true)
        .toList();
  }
  
  /// 点赞文章
  Future<Article> likeArticle(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _articles.indexWhere((article) => article.id == id);
    if (index >= 0) {
      final article = _articles[index];
      final updatedArticle = article.copyWith(likeCount: article.likeCount + 1);
      _articles[index] = updatedArticle;
      return updatedArticle;
    }
    throw Exception('找不到ID为 $id 的文章');
  }
} 