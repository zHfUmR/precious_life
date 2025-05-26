import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';

/// 字体样式，最后一项有设置Color不用调build()
///
/// 调用示例：
///
/// 默认样式：CPTextStyles.build();
///
/// 常规调用：CPTextStyles.s12.bold.c(Colors.white)、 CPTextStyles.s14.c(Colors.white)、CPTextStyles.c(Colors.white)
///
/// 其它调用：TextStyleBuilder(fontSize: 14, color: Colors.red).build()、TextStyleBuilder(fontSize: 16).bold.build();
class CPTextStyles {
  /// 字体大小8，默认黑色，普通粗细
  static final TextStyleBuilder s8 =
      TextStyleBuilder(fontSize: 8, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小9，默认黑色，普通粗细
  static final TextStyleBuilder s9 =
      TextStyleBuilder(fontSize: 9, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小10，默认黑色，普通粗细
  static final TextStyleBuilder s10 =
      TextStyleBuilder(fontSize: 10, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小11，默认黑色，普通粗细
  static final TextStyleBuilder s11 =
      TextStyleBuilder(fontSize: 11, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小12，默认黑色，普通粗细
  static final TextStyleBuilder s12 =
      TextStyleBuilder(fontSize: 12, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小13，默认黑色，普通粗细
  static final TextStyleBuilder s13 =
      TextStyleBuilder(fontSize: 13, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小14，默认黑色，普通粗细
  static final TextStyleBuilder s14 =
      TextStyleBuilder(fontSize: 14, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小15，默认黑色，普通粗细
  static final TextStyleBuilder s15 =
      TextStyleBuilder(fontSize: 15, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小16，默认黑色，普通粗细
  static final TextStyleBuilder s16 =
      TextStyleBuilder(fontSize: 16, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小17，默认黑色，普通粗细
  static final TextStyleBuilder s17 =
      TextStyleBuilder(fontSize: 17, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小18，默认黑色，普通粗细
  static final TextStyleBuilder s18 =
      TextStyleBuilder(fontSize: 18, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小19，默认黑色，普通粗细
  static final TextStyleBuilder s19 =
      TextStyleBuilder(fontSize: 19, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小20，默认黑色，普通粗细
  static final TextStyleBuilder s20 =
      TextStyleBuilder(fontSize: 20, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小21，默认黑色，普通粗细
  static final TextStyleBuilder s21 =
      TextStyleBuilder(fontSize: 21, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小22，默认黑色，普通粗细
  static final TextStyleBuilder s22 =
      TextStyleBuilder(fontSize: 22, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小23，默认黑色，普通粗细
  static final TextStyleBuilder s23 =
      TextStyleBuilder(fontSize: 23, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小24，默认黑色，普通粗细
  static final TextStyleBuilder s24 =
      TextStyleBuilder(fontSize: 24, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小25，默认黑色，普通粗细
  static final TextStyleBuilder s25 =
      TextStyleBuilder(fontSize: 25, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小26，默认黑色，普通粗细
  static final TextStyleBuilder s26 =
      TextStyleBuilder(fontSize: 26, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小27，默认黑色，普通粗细
  static final TextStyleBuilder s27 =
      TextStyleBuilder(fontSize: 27, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小28，默认黑色，普通粗细
  static final TextStyleBuilder s28 =
      TextStyleBuilder(fontSize: 28, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小29，默认黑色，普通粗细
  static final TextStyleBuilder s29 =
      TextStyleBuilder(fontSize: 29, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小30，默认黑色，普通粗细
  static final TextStyleBuilder s30 =
      TextStyleBuilder(fontSize: 30, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小32，默认黑色，普通粗细
  static final TextStyleBuilder s32 =
      TextStyleBuilder(fontSize: 32, color: CPColors.black, fontWeight: FontWeight.normal);

  /// 字体大小36，默认黑色，普通粗细
  static final TextStyleBuilder s36 =
      TextStyleBuilder(fontSize: 36, color: CPColors.black, fontWeight: FontWeight.normal);
  
  /// 字体大小40，默认黑色，普通粗细
  static final TextStyleBuilder s40 =
      TextStyleBuilder(fontSize: 40, color: CPColors.black, fontWeight: FontWeight.normal);


  /// 字体大小48，默认黑色，普通粗细
  static final TextStyleBuilder s48 =
      TextStyleBuilder(fontSize: 48, color: CPColors.black, fontWeight: FontWeight.normal);

  /// 创建自定义文本样式
  static build({double? fontSize, Color? color, FontWeight? fontWeight, FontStyle? fontStyle}) =>
      TextStyleBuilder(fontSize: fontSize, color: color, fontWeight: fontWeight, fontStyle: fontStyle);
}

/// 文本样式构建器类
/// 用于链式调用创建文本样式
class TextStyleBuilder {
  /// 文本颜色
  Color? color;
  
  /// 字体大小
  double? fontSize;
  
  /// 字体粗细
  FontWeight? fontWeight;
  
  /// 字体样式（斜体等）
  FontStyle? fontStyle;

  /// 构造函数
  TextStyleBuilder({this.fontSize, this.color, this.fontWeight, this.fontStyle});

  /// 设置颜色并返回构建好的TextStyle
  TextStyle c(Color color) =>
      TextStyleBuilder(fontSize: fontSize, color: color, fontWeight: fontWeight, fontStyle: fontStyle).build();

  /// 返回粗体样式的构建器
  TextStyleBuilder get bold => TextStyleBuilder(fontSize: fontSize, color: color, fontWeight: FontWeight.bold, fontStyle: fontStyle);

  /// 返回普通粗细样式的构建器
  TextStyleBuilder get normal => TextStyleBuilder(fontSize: fontSize, color: color, fontWeight: FontWeight.normal, fontStyle: fontStyle);

  /// 返回斜体样式的构建器
  TextStyleBuilder get italic =>
      TextStyleBuilder(fontSize: fontSize, color: color, fontWeight: fontWeight, fontStyle: FontStyle.italic);

  /// 设置颜色并返回新的构建器
  TextStyleBuilder withColor(Color newColor) =>
      TextStyleBuilder(fontSize: fontSize, color: newColor, fontWeight: fontWeight, fontStyle: fontStyle);

  /// 构建最终的TextStyle
  /// 不传参返回默认样式
  TextStyle build() => TextStyle(
        color: color ?? CPColors.black,
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
        decoration: TextDecoration.none,
      );
} 