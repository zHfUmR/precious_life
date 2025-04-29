import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/feed_repository.dart';

/// 提供文章数据的Provider
final articlesProvider = AsyncNotifierProvider<ArticlesNotifier, List<Article>>(() {
  return ArticlesNotifier();
});

/// 文章列表状态管理器
class ArticlesNotifier extends AsyncNotifier<List<Article>> {
  /// 信息流仓库
  late final FeedRepository _repository;
  
  @override
  Future<List<Article>> build() async {
    // 获取仓库实例
    _repository = ref.read(feedRepositoryProvider);
    
    // 获取所有文章，并按照置顶和发布时间排序
    final articles = await _repository.getAllArticles();
    
    return _sortArticles(articles);
  }
  
  /// 按置顶状态和发布时间排序文章列表
  List<Article> _sortArticles(List<Article> articles) {
    return articles
      ..sort((a, b) {
        // 首先按照置顶状态排序
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        
        // 然后按照发布时间排序（从新到旧）
        return b.publishedAt.compareTo(a.publishedAt);
      });
  }
  
  /// 点赞文章
  Future<void> likeArticle(String id) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      // 调用仓库方法点赞文章
      final updatedArticle = await _repository.likeArticle(id);
      
      // 更新当前状态中的文章
      final List<Article> currentArticles = [...state.value ?? <Article>[]];
      final index = currentArticles.indexWhere((article) => article.id == id);
      
      if (index >= 0) {
        currentArticles[index] = updatedArticle;
      }
      
      return currentArticles;
    });
  }
  
  /// 搜索文章
  Future<List<Article>> searchArticles(String query) async {
    return _repository.searchArticles(query);
  }
  
  /// 按分类获取文章
  Future<void> getArticlesByCategory(String category) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final articles = await _repository.getArticlesByCategory(category);
      return _sortArticles(articles);
    });
  }
  
  /// 按标签获取文章
  Future<void> getArticlesByTag(String tag) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final articles = await _repository.getArticlesByTag(tag);
      return _sortArticles(articles);
    });
  }
  
  /// 刷新文章列表
  Future<void> refreshArticles() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final articles = await _repository.getAllArticles();
      return _sortArticles(articles);
    });
  }
} 