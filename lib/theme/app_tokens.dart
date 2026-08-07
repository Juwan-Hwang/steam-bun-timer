/// Zephyr Design Tokens → Flutter
/// 移植自 Zephyr 项目的 packages/tokens/src/{primitive,semantic,component}.json
library;

/// 所有值严格对应 Zephyr 设计系统的 token 定义。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Primitive Tokens — 原始值（对应 primitive.json）
// ═══════════════════════════════════════════════════════════════════════════

class ZephyrColors {
  ZephyrColors._();

  // 品牌色
  static const blue500 = Color(0xFF007AFF);
  static const green500 = Color(0xFF34C759);
  static const orange500 = Color(0xFFFF9500);
  static const pink500 = Color(0xFFFF2D55);
  static const purple500 = Color(0xFFAF52DE);
  static const red500 = Color(0xFFEF4444);
  static const amber500 = Color(0xFFF59E0B);
  static const emerald500 = Color(0xFF22C55E);

  // 语义色
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF4ADE80);
  static const info = Color(0xFF38BDF8);
  static const closeBtn = Color(0xFFFF5F57);
}

class ZephyrSpacing {
  ZephyrSpacing._();
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 6;
  static const double s3 = 8;
  static const double s4 = 12;
  static const double s5 = 16;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 48;
}

class ZephyrRadius {
  ZephyrRadius._();
  static const double control = 8;
  static const double surface = 12;
  static const double md = 16;
  static const double overlay = 24;
  static const double full = 9999;
  static const double dropdownOption = 18;
}

class ZephyrFontSize {
  ZephyrFontSize._();
  static const double xxs = 10;
  static const double xs = 12;
  static const double sm = 14;
  static const double base = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double x2l = 24;
  static const double x3l = 30;
  static const double x4l = 36;
}

class ZephyrDuration {
  ZephyrDuration._();
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration standard = Duration(milliseconds: 210);
  static const Duration fast = Duration(milliseconds: 400);
  static const Duration dropdown = Duration(milliseconds: 150);
  static const Duration page = Duration(milliseconds: 300);
}

// ═══════════════════════════════════════════════════════════════════════════
//  Accent Theme System — 主题色系（对应 config.js theme-vars）
// ═══════════════════════════════════════════════════════════════════════════

class AccentTheme {
  const AccentTheme({
    required this.primary,
    required this.glow,
    required this.rgb,
  });

  final Color primary;
  final Color glow;
  final String rgb;

  static const blue = AccentTheme(
    primary: Color(0xFF007AFF),
    glow: Color(0x33007AFF),
    rgb: '0, 122, 255',
  );
  static const green = AccentTheme(
    primary: Color(0xFF34C759),
    glow: Color(0x3334C759),
    rgb: '52, 199, 89',
  );
  static const orange = AccentTheme(
    primary: Color(0xFFFF9500),
    glow: Color(0x33FF9500),
    rgb: '255, 149, 0',
  );
  static const pink = AccentTheme(
    primary: Color(0xFFFF2D55),
    glow: Color(0x33FF2D55),
    rgb: '255, 45, 85',
  );
  static const purple = AccentTheme(
    primary: Color(0xFFAF52DE),
    glow: Color(0x33AF52DE),
    rgb: '175, 82, 222',
  );

  static const defaultTheme = purple;
}

// ═══════════════════════════════════════════════════════════════════════════
//  Semantic Tokens — 语义层（对应 semantic.json，含 dark/light 双值）
// ═══════════════════════════════════════════════════════════════════════════

class ZephyrSemantic {
  final bool isDark;
  final AccentTheme accent;

  const ZephyrSemantic({required this.isDark, this.accent = AccentTheme.defaultTheme});

  // ── Text ──
  Color get textPrimary => isDark
      ? const Color(0xF2FFFFFF)
      : const Color(0xF218181C);
  Color get textSecondary => isDark
      ? const Color(0x99FFFFFF)
      : const Color(0xA618181C);
  Color get textTertiary => isDark
      ? const Color(0x66FFFFFF)
      : const Color(0x6618181C);
  Color get textMuted => const Color(0xFF71717A);
  Color get textOnAccent => const Color(0xFFFFFFFF);
  Color get textBadge => isDark
      ? const Color(0x99FFFFFF)
      : const Color(0xA618181C);

  // ── Background ──
  Color get bgSecondary => isDark
      ? const Color(0x8C0C0C10)
      : const Color(0x0A000000);
  Color get bgTertiary => isDark
      ? const Color(0x800C0C10)
      : const Color(0x0F000000);
  Color get bgSubtle => isDark
      ? const Color(0x08FFFFFF)
      : const Color(0x08000000);
  Color get bgMuted => isDark
      ? const Color(0x0DFFFFFF)
      : const Color(0x0D000000);
  Color get bgInput => isDark
      ? const Color(0x66000000)
      : const Color(0xCCFFFFFF);
  Color get bgElevated => isDark
      ? const Color(0xF718181B)
      : const Color(0xFFFFFFFF);
  Color get bgOverlay => isDark
      ? const Color(0x66000000)
      : const Color(0x40000000);

  // ── Surface ──
  Color get surfaceRaised => bgSecondary;
  Color get surfaceElevated => bgElevated;
  Color get surfaceInput => bgInput;
  Color get surfaceOverlay => bgOverlay;

  // ── Border ──
  Color get borderPrimary => isDark
      ? const Color(0x1AFFFFFF)
      : const Color(0x26000000);
  Color get borderSubtle => isDark
      ? const Color(0x0DFFFFFF)
      : const Color(0x1A1E293B);
  Color get borderDefault => isDark
      ? const Color(0x1AFFFFFF)
      : const Color(0x241E293B);
  Color get borderStrong => isDark
      ? const Color(0x33FFFFFF)
      : const Color(0x331E293B);

  // ── Status Colors ──
  Color get danger => isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
  Color get warning => isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
  Color get success => isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
  Color get info => isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);

  // ── Shadow ──
  List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: isDark ? const Color(0x33000000) : const Color(0x14000000),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
  List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: isDark ? const Color(0x59000000) : const Color(0x1F000000),
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
      ];
  List<BoxShadow> get shadowDialog => [
        BoxShadow(
          color: isDark ? const Color(0x8C000000) : const Color(0x40000000),
          blurRadius: 40,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Accent helpers ──
  Color get accentPrimary => accent.primary;
  Color get accentGlow => accent.glow;
  Color accentWithAlpha(int alpha) => accent.primary.withValues(alpha: alpha / 255);
}

// ═══════════════════════════════════════════════════════════════════════════
//  Theme Extension — 让 Zephyr tokens 在 Widget 树中全局可访问
// ═══════════════════════════════════════════════════════════════════════════

class ZephyrThemeExtension extends ThemeExtension<ZephyrThemeExtension> {
  final ZephyrSemantic semantic;

  const ZephyrThemeExtension({required this.semantic});

  @override
  ZephyrThemeExtension copyWith({ZephyrSemantic? semantic}) {
    return ZephyrThemeExtension(semantic: semantic ?? this.semantic);
  }

  @override
  ZephyrThemeExtension lerp(ThemeExtension<ZephyrThemeExtension>? other, double t) {
    if (other is! ZephyrThemeExtension) return this;
    return this;
  }

  static ZephyrThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<ZephyrThemeExtension>()!;
  }

  // 便捷访问
  ZephyrSemantic get s => semantic;
}

// ═══════════════════════════════════════════════════════════════════════════
//  App ThemeData — 将 Zephyr tokens 转为 Material 3 ThemeData
// ═══════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  static ThemeData dark({AccentTheme accent = AccentTheme.defaultTheme}) {
    final semantic = ZephyrSemantic(isDark: true, accent: accent);
    return _buildTheme(semantic);
  }

  static ThemeData light({AccentTheme accent = AccentTheme.defaultTheme}) {
    final semantic = ZephyrSemantic(isDark: false, accent: accent);
    return _buildTheme(semantic);
  }

  static ThemeData _buildTheme(ZephyrSemantic s) {
    final colorScheme = ColorScheme(
      brightness: s.isDark ? Brightness.dark : Brightness.light,
      primary: s.accentPrimary,
      onPrimary: s.textOnAccent,
      secondary: s.accentPrimary,
      onSecondary: s.textOnAccent,
      error: s.danger,
      onError: Colors.white,
      surface: s.bgElevated,
      onSurface: s.textPrimary,
      surfaceContainerHighest: s.bgMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: s.isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: [ZephyrThemeExtension(semantic: s)],

      // 文字
      textTheme: _buildTextTheme(s),

      // 按钮 — Zephyr button: uppercase, 700 weight, 0.05em tracking, radius 24
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.accentPrimary,
          foregroundColor: s.textOnAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: ZephyrSpacing.s5, vertical: ZephyrSpacing.s3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
          textStyle: TextStyle(
            fontSize: ZephyrFontSize.xxs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Ghost 按钮 (TextButton)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: s.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: ZephyrSpacing.s5, vertical: ZephyrSpacing.s3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
            side: BorderSide(color: s.accentWithAlpha(30)),
          ),
          textStyle: TextStyle(
            fontSize: ZephyrFontSize.xxs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // 卡片
      cardTheme: CardThemeData(
        color: s.isDark
            ? const Color(0x0DFFFFFF)
            : const Color(0x66FFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
          side: BorderSide(color: s.borderSubtle),
        ),
        margin: EdgeInsets.zero,
      ),

      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          borderSide: BorderSide(color: s.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          borderSide: BorderSide(color: s.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          borderSide: BorderSide(color: s.accentWithAlpha(128)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: ZephyrSpacing.s5, vertical: ZephyrSpacing.s3),
      ),

      // 开关 — iOS 风格
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return s.accentPrimary;
          return const Color(0xFF8E8E93);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // 滑块
      sliderTheme: SliderThemeData(
        activeTrackColor: s.accentPrimary,
        inactiveTrackColor: s.bgMuted,
        thumbColor: s.accentPrimary,
        overlayColor: s.accentGlow,
        trackHeight: 6,
      ),

      // 状态栏
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: s.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      // 页面过渡 — iOS 风格滑动过渡
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme(ZephyrSemantic s) {
    final base = TextStyle(
      color: s.textPrimary,
      fontFamily: 'sans-serif',
      decoration: TextDecoration.none,
    );

    return TextTheme(
      displayLarge: base.copyWith(fontSize: 64, fontWeight: FontWeight.w200, letterSpacing: -1.5, height: 1.1),
      displayMedium: base.copyWith(fontSize: 48, fontWeight: FontWeight.w200, letterSpacing: -1.2, height: 1.1),
      displaySmall: base.copyWith(fontSize: 36, fontWeight: FontWeight.w300, letterSpacing: -0.5, height: 1.2),
      headlineLarge: base.copyWith(fontSize: ZephyrFontSize.x3l, fontWeight: FontWeight.w300, height: 1.2),
      headlineMedium: base.copyWith(fontSize: ZephyrFontSize.x2l, fontWeight: FontWeight.w400, height: 1.3),
      headlineSmall: base.copyWith(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w400, height: 1.3),
      titleLarge: base.copyWith(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, height: 1.4),
      titleMedium: base.copyWith(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall: base.copyWith(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge: base.copyWith(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: base.copyWith(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: TextStyle(
        color: s.textTertiary,
        fontSize: ZephyrFontSize.xs,
        fontWeight: FontWeight.w400,
        height: 1.4,
        decoration: TextDecoration.none,
      ),
      labelLarge: base.copyWith(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.4),
      labelMedium: base.copyWith(fontSize: ZephyrFontSize.xs, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.4),
      labelSmall: TextStyle(
        color: s.textMuted,
        fontSize: ZephyrFontSize.xxs,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        height: 1.4,
        decoration: TextDecoration.none,
      ),
    );
  }
}
