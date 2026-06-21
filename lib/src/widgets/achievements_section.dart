import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';
import '../services/achievement_service.dart';
import '../services/auth_service.dart';
import '../utils/localization.dart';

class AchievementsSection extends StatefulWidget {
  const AchievementsSection({super.key});

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  List<Achievement> achievements = [];
  Achievement? selectedAchievement;
  bool loading = true;
  bool showAll = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadAchievements();
  }

  Future<String> getSeenAchievementsKey() async {
    final session = await getStoredSession();
    return 'seenAchievements:${session?.user.id ?? 'guest'}';
  }

  Future<List<String>> getSeenAchievementCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await getSeenAchievementsKey();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveSeenAchievementCodes(List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await getSeenAchievementsKey();
    await prefs.setStringList(key, codes);
  }

  Future<void> loadAchievements() async {
    try {
      final result = await achievementService.getMyAchievements();

      if (!mounted) return;

      setState(() {
        achievements = result;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = context.l10n.achievementsLoadFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  IconData getAchievementIcon(Achievement achievement) {
    if (!achievement.unlocked) {
      return Icons.lock_rounded;
    }

    switch (achievement.code) {
      case 'FIRST_ROUTE':
        return Icons.map_rounded;
      case 'FIVE_ROUTES':
        return Icons.terrain_rounded;
      case 'FIRST_FAVORITE':
        return Icons.star_rounded;
      case 'TEN_FAVORITES':
        return Icons.emoji_events_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  Future<void> handleAchievementTap(Achievement achievement) async {
    setState(() {
      if (selectedAchievement?.code == achievement.code) {
        selectedAchievement = null;
      } else {
        selectedAchievement = achievement;
      }
    });

    if (!achievement.unlocked) return;

    final seenCodes = await getSeenAchievementCodes();

    if (!seenCodes.contains(achievement.code)) {
      await saveSeenAchievementCodes([...seenCodes, achievement.code]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Text(context.l10n.achievementsLoading);
    }

    if (error != null) {
      return Text(error!);
    }

    final visibleAchievements = showAll
        ? achievements
        : achievements.where((achievement) => achievement.unlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.achievements,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  showAll = !showAll;
                  selectedAchievement = null;
                });
              },
              child: Text(
                showAll
                    ? context.l10n.achievementsUnlocked
                    : context.l10n.achievementsAll,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleAchievements.isEmpty)
          Text(context.l10n.achievementsEmpty)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visibleAchievements.map((achievement) {
              return Opacity(
                opacity: achievement.unlocked ? 1 : 0.45,
                child: ActionChip(
                  avatar: Icon(getAchievementIcon(achievement), size: 18),
                  label: Text(achievement.title),
                  onPressed: () {
                    handleAchievementTap(achievement);
                  },
                ),
              );
            }).toList(),
          ),
        if (selectedAchievement != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAchievement!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(selectedAchievement!.description),
                const SizedBox(height: 8),
                Text(
                  selectedAchievement!.unlocked
                      ? 'Logro desbloqueado'
                      : 'Logro todavía bloqueado',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
