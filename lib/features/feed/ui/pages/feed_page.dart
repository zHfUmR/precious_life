import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/article.dart';
import '../../../../data/repositories/feed_repository.dart';

/// 信息流页面
/// 显示用户的信息流内容，包括文章、动态等
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

/// FeedPage的状态类，混入AutomaticKeepAliveClientMixin以保持页面状态
class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 告诉Flutter我们希望保持这个页面的状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build
    return Scaffold(
      body: Container(
        color: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 文章搜索代理
class ArticleSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;
  
  ArticleSearchDelegate(this.ref);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('请输入搜索关键词'),
      );
    }
    
    return FutureBuilder(
      future: ref.read(feedRepositoryProvider).searchArticles(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('搜索失败: ${snapshot.error}'),
          );
        }
        
        final results = snapshot.data!;
        
        if (results.isEmpty) {
          return Center(
            child: Text('没有找到与"$query"相关的文章'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final article = results[index];
            return ArticleCard(article: article);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('输入关键词搜索文章'),
      );
    }
    
    return FutureBuilder(
      future: ref.read(feedRepositoryProvider).searchArticles(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox();
        }
        
        final results = snapshot.data!;
        
        if (results.isEmpty) {
          return const SizedBox();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final article = results[index];
            return ListTile(
              title: Text(article.title),
              onTap: () {
                // 直接展示搜索结果
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}

/// 文章卡片组件
class ArticleCard extends ConsumerWidget {
  final Article article;
  
  const ArticleCard({
    super.key,
    required this.article,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.coverImageUrl != null)
            Image.network(
              article.coverImageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '置顶',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (article.summary != null) ...[
                  Text(
                    article.summary!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      article.authorName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(article.publishedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatIcon(Icons.remove_red_eye, article.viewCount),
                    const SizedBox(width: 16),
                    _buildStatIcon(Icons.favorite, article.likeCount),
                    const SizedBox(width: 16),
                    _buildStatIcon(Icons.comment, article.commentCount),
                  ],
                ),
                if (article.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: article.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 构建统计图标
  Widget _buildStatIcon(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 