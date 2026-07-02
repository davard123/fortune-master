// lib/core/mystic_theme.dart
// 玄学主题: 宣纸土黄 + 鎏金配色, 移植自 web-prototype/index.html
// 色板与字体选择详见 docs/plans 里的设计讨论; 此文件是唯一的样式事实来源.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 色板 (对齐 web-prototype 的 CSS 变量命名)
class MysticColors {
  MysticColors._();

  static const ink = Color(0xFFEFE4CB); // 页面底色 · 宣纸米黄
  static const ink2 = Color(0xFFF6EEDA); // 卡片底色
  static const ink3 = Color(0xFFFBF5E6); // 卡片 hover/浅层
  static const gold = Color(0xFF9A742E); // 主金色
  static const goldBright = Color(0xFF7D5A1C); // 深金 (文字用, 对比度更高)
  static const goldDim = Color(0xFFB3924F); // 浅金 (描边/次要)
  static const cinnabar = Color(0xFFB43A3A); // 朱砂红 (热门/强调)
  static const jade = Color(0xFF4A7A64); // 玉青 (状态徽章)
  static const moon = Color(0xFF3D3122); // 主文字 · 墨棕
  static const moonDim = Color(0xFF6F5F45); // 次要文字
  static const moonFaint = Color(0xFF98876A); // 弱化文字
  static const hairline = Color(0x619A742E); // 描边 (38% alpha)
  static const hairlineSoft = Color(0x339A742E); // 淡描边 (20% alpha)
}

/// 字体 (与 web-prototype 的 Google Fonts 选择一致)
class MysticFonts {
  MysticFonts._();

  /// 主标题: 毛笔楷书, 笔画厚重
  static TextStyle heading(double size, {Color? color}) => GoogleFonts.maShanZheng(
        fontSize: size,
        color: color ?? MysticColors.moon,
        height: 1.2,
      );

  /// 段落标题 / 卡名: 碑刻感中文书法体
  static TextStyle title(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.zcoolXiaoWei(
        fontSize: size,
        color: color ?? MysticColors.moon,
        fontWeight: weight ?? FontWeight.w400,
      );

  /// 正文: 宋体
  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.notoSerifSc(
        fontSize: size,
        color: color ?? MysticColors.moonDim,
        fontWeight: weight ?? FontWeight.w300,
        height: 1.7,
      );

  /// 英文小标签: 塔罗牌经典衬线体
  static TextStyle en(double size, {Color? color}) => GoogleFonts.cinzel(
        fontSize: size,
        color: color ?? MysticColors.gold,
        letterSpacing: 1.4,
      );
}

ThemeData buildMysticTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  return base.copyWith(
    scaffoldBackgroundColor: MysticColors.ink,
    colorScheme: base.colorScheme.copyWith(
      primary: MysticColors.gold,
      onPrimary: MysticColors.ink3,
      secondary: MysticColors.cinnabar,
      surface: MysticColors.ink2,
      onSurface: MysticColors.moon,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: MysticColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: MysticColors.moon,
      titleTextStyle: MysticFonts.title(19, color: MysticColors.moon),
      iconTheme: const IconThemeData(color: MysticColors.gold),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: MysticColors.moon,
      displayColor: MysticColors.moon,
    ),
    dividerColor: MysticColors.hairlineSoft,
    bottomAppBarTheme: const BottomAppBarTheme(color: MysticColors.ink2),
  );
}
