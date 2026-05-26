import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/accessibility_state.dart';
import '../theme/theme.dart';

class AccessibilityFloatingButton extends StatelessWidget {
  const AccessibilityFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Positioned(
      right: 18,
      bottom: 82,
      child: SafeArea(
        child: FloatingActionButton(
          heroTag: 'accessibility_fab',
          backgroundColor: accessibility.buttonColor,
          foregroundColor: accessibility.buttonTextColor,
          elevation: 8,
          onPressed: () => _showAccessibilityPanel(context),
          child: const Icon(Icons.accessibility_new_rounded),
        ),
      ),
    );
  }

  void _showAccessibilityPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AccessibilityPanel(),
    );
  }
}

class AccessibilityPanel extends StatelessWidget {
  const AccessibilityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    final isDark = accessibility.forceDarkUi;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accessibility.surfaceColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accessibility.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330F172A),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Accessibility',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: accessibility.textColor,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: accessibility.buttonColor,
                        foregroundColor: accessibility.buttonTextColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _SectionTitle(
                  'Color adjustment',
                  color: accessibility.textColor,
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width >= 520
                      ? 3
                      : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _ColorModeTile(
                      icon: Icons.remove_red_eye_rounded,
                      label: 'Monochrome',
                      mode: AccessibilityColorMode.monochrome,
                    ),
                    _ColorModeTile(
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark contrast',
                      mode: AccessibilityColorMode.darkContrast,
                    ),
                    _ColorModeTile(
                      icon: Icons.light_mode_rounded,
                      label: 'Light contrast',
                      mode: AccessibilityColorMode.lightContrast,
                    ),
                    _ColorModeTile(
                      icon: Icons.water_drop_rounded,
                      label: 'Low saturation',
                      mode: AccessibilityColorMode.lowSaturation,
                    ),
                    _ColorModeTile(
                      icon: Icons.palette_rounded,
                      label: 'High saturation',
                      mode: AccessibilityColorMode.highSaturation,
                    ),
                    _ColorModeTile(
                      icon: Icons.contrast_rounded,
                      label: 'High contrast',
                      mode: AccessibilityColorMode.highContrast,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _SectionTitle(
                  'Content adjustment',
                  color: accessibility.textColor,
                ),
                const SizedBox(height: 12),

                _PanelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardHeader(
                        icon: Icons.format_size_rounded,
                        title: 'Font settings',
                        subtitle: 'Increase or modify text readability',
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _RoundButton(
                            icon: Icons.remove_rounded,
                            onTap: accessibility.decreaseFont,
                          ),
                          const SizedBox(width: 18),
                          Text(
                            'Level ${accessibility.fontLevel}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: accessibility.textColor,
                            ),
                          ),
                          const SizedBox(width: 18),
                          _RoundButton(
                            icon: Icons.add_rounded,
                            onTap: accessibility.increaseFont,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PillToggle(
                            label: 'Line spacing',
                            selected: accessibility.lineSpacing,
                            onTap: accessibility.toggleLineSpacing,
                          ),
                          _PillToggle(
                            label: 'Word spacing',
                            selected: accessibility.wordSpacing,
                            onTap: accessibility.toggleWordSpacing,
                          ),
                          _PillToggle(
                            label: 'Letter spacing',
                            selected: accessibility.letterSpacing,
                            onTap: accessibility.toggleLetterSpacing,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: _BigActionButton(
                    icon: Icons.restart_alt_rounded,
                    label: 'Reset settings',
                    onTap: accessibility.reset,
                  ),
                ),

                if (isDark) const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccessibilityAppWrapper extends StatelessWidget {
  const AccessibilityAppWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final mediaQuery = MediaQuery.of(context);
    final baseTheme = Theme.of(context);

    final adjustedTextTheme = _applyTextAdjustmentsToTextTheme(
      baseTheme.textTheme,
      accessibility,
    );

    Widget result = Theme(
      data: baseTheme.copyWith(
        brightness: accessibility.forceDarkUi
            ? Brightness.dark
            : Brightness.light,
        scaffoldBackgroundColor: accessibility.pageBackgroundColor,
        canvasColor: accessibility.pageBackgroundColor,
        cardColor: accessibility.surfaceColor,
        dividerColor: accessibility.borderColor,

        textTheme: adjustedTextTheme,
        primaryTextTheme: adjustedTextTheme,

        iconTheme: IconThemeData(color: accessibility.textColor),

        appBarTheme: AppBarTheme(
          backgroundColor: accessibility.surfaceColor,
          foregroundColor: accessibility.textColor,
          iconTheme: IconThemeData(color: accessibility.textColor),
        ),

        cardTheme: CardThemeData(
          color: accessibility.surfaceColor,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: accessibility.borderColor),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: accessibility.inputFillColor,
          hintStyle: TextStyle(color: accessibility.secondaryTextColor),
          labelStyle: TextStyle(color: accessibility.secondaryTextColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: accessibility.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: accessibility.borderColor, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: accessibility.borderColor),
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: accessibility.surfaceColor,
          selectedItemColor: accessibility.textColor,
          unselectedItemColor: accessibility.secondaryTextColor,
          selectedIconTheme: IconThemeData(color: accessibility.textColor),
          unselectedIconTheme: IconThemeData(
            color: accessibility.secondaryTextColor,
          ),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      child: MediaQuery(
        data: mediaQuery.copyWith(
          textScaler: TextScaler.linear(accessibility.textScale),
        ),
        child: DefaultTextStyle.merge(
          style: accessibility.textAdjustments.copyWith(
            color: accessibility.textColor,
          ),
          child: Container(
            color: accessibility.pageBackgroundColor,
            child: child,
          ),
        ),
      ),
    );

    final colorFilter = accessibility.colorFilter;
    if (colorFilter != null) {
      result = ColorFiltered(colorFilter: colorFilter, child: result);
    }

    return result;
  }

  TextTheme _applyTextAdjustmentsToTextTheme(
    TextTheme textTheme,
    AccessibilityState accessibility,
  ) {
    TextStyle? apply(TextStyle? style) {
      if (style == null) return null;

      return style.copyWith(
        color: accessibility.textColor,
        height: accessibility.lineHeight ?? style.height,
        wordSpacing: accessibility.wordSpacingValue ?? style.wordSpacing,
        letterSpacing: accessibility.letterSpacingValue ?? style.letterSpacing,
      );
    }

    return textTheme.copyWith(
      displayLarge: apply(textTheme.displayLarge),
      displayMedium: apply(textTheme.displayMedium),
      displaySmall: apply(textTheme.displaySmall),
      headlineLarge: apply(textTheme.headlineLarge),
      headlineMedium: apply(textTheme.headlineMedium),
      headlineSmall: apply(textTheme.headlineSmall),
      titleLarge: apply(textTheme.titleLarge),
      titleMedium: apply(textTheme.titleMedium),
      titleSmall: apply(textTheme.titleSmall),
      bodyLarge: apply(textTheme.bodyLarge),
      bodyMedium: apply(textTheme.bodyMedium),
      bodySmall: apply(textTheme.bodySmall),
      labelLarge: apply(textTheme.labelLarge),
      labelMedium: apply(textTheme.labelMedium),
      labelSmall: apply(textTheme.labelSmall),
    );
  }
}

class _ColorModeTile extends StatelessWidget {
  const _ColorModeTile({
    required this.icon,
    required this.label,
    required this.mode,
  });

  final IconData icon;
  final String label;
  final AccessibilityColorMode mode;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();
    final selected = accessibility.colorMode == mode;

    final backgroundColor = selected
        ? accessibility.buttonColor.withValues(alpha: 0.12)
        : accessibility.surfaceColor;

    return InkWell(
      onTap: () => context.read<AccessibilityState>().setColorMode(mode),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: selected
                ? const Color(0xFFD6C45F)
                : accessibility.borderColor,
            width: selected ? 3 : 1.2,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: accessibility.textColor),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: accessibility.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        border: Border.all(color: accessibility.borderColor),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return Row(
      children: [
        Icon(icon, size: 32, color: accessibility.textColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accessibility.textColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accessibility.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: accessibility.buttonColor,
        foregroundColor: accessibility.buttonTextColor,
        fixedSize: const Size(44, 44),
      ),
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}

class _PillToggle extends StatelessWidget {
  const _PillToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? accessibility.buttonColor
            : accessibility.surfaceColor,
        foregroundColor: selected
            ? accessibility.buttonTextColor
            : accessibility.textColor,
        side: BorderSide(
          color: selected
              ? accessibility.buttonColor
              : accessibility.borderColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          color: accessibility.surfaceColor,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: accessibility.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accessibility.textColor, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: accessibility.textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
    );
  }
}
