import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

/// 文章模型
@freezed
class Article with _$Article {
  const factory Article({
    /// 文章唯一ID
    required String id,
    
    /// 标题
    required String title,
    
    /// 内容
    required String content,
    
    /// 摘要
    String? summary,
    
    /// 封面图片URL
    String? coverImageUrl,
    
    /// 作者ID
    required String authorId,
    
    /// 作者名称
    required String authorName,
    
    /// 发布时间
    required DateTime publishedAt,
    
    /// 阅读时长（分钟）
    int? readingTimeMinutes,
    
    /// 分类
    @Default([]) List<String> categories,
    
    /// 标签
    @Default([]) List<String> tags,
    
    /// 阅读数
    @Default(0) int viewCount,
    
    /// 点赞数
    @Default(0) int likeCount,
    
    /// 评论数
    @Default(0) int commentCount,
    
    /// 是否置顶
    @Default(false) bool isPinned,
  }) = _Article;

  /// 从JSON创建文章
  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
} 