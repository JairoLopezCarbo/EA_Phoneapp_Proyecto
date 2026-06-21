import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../services/review_service.dart';
import '../state/app_state.dart';
import '../state/localization_state.dart';
import '../theme/theme.dart';
import '../utils/formatters.dart';
import '../widgets/achievements_section.dart';
import 'edit_route_points_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _routeDescriptionController =
      TextEditingController();
  final TextEditingController _routeCoverController = TextEditingController();
  final TextEditingController _routeImagesController = TextEditingController();
  final TextEditingController _routeDistanceController =
      TextEditingController();
  final TextEditingController _routeDurationController =
      TextEditingController();
  final TextEditingController _routeCityController = TextEditingController();
  final TextEditingController _routeCountryController = TextEditingController();
  final TextEditingController _routeTagsController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewCommentController =
      TextEditingController();

  bool _editingUser = false;
  bool _savingUser = false;
  bool _savingRoute = false;
  bool _savingReview = false;
  bool _deletingReview = false;
  bool _loadingReviews = false;
  String _userMessage = '';
  String _routeMessage = '';
  String _reviewsMessage = '';
  String? _editingRouteId;
  String? _editingReviewId;
  String? _reviewsUserId;
  RouteDifficulty _routeDifficulty = RouteDifficulty.medium;
  List<ReviewRating> _reviewRatings = const <ReviewRating>[];
  List<ReviewModel> _reviews = const <ReviewModel>[];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _routeNameController.dispose();
    _routeDescriptionController.dispose();
    _routeCoverController.dispose();
    _routeImagesController.dispose();
    _routeDistanceController.dispose();
    _routeDurationController.dispose();
    _routeCityController.dispose();
    _routeCountryController.dispose();
    _routeTagsController.dispose();
    _reviewTitleController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _syncUserForm(AppUser user) {
    _nameController.text = user.name;
    _surnameController.text = user.surname;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _syncRouteForm(RouteModel route) {
    _routeNameController.text = route.name;
    _routeDescriptionController.text = route.description;
    _routeCoverController.text = route.coverImage;
    _routeImagesController.text = route.images.join(', ');
    _routeDistanceController.text = route.distance?.toString() ?? '';
    _routeDurationController.text = route.duration?.toString() ?? '';
    _routeCityController.text = route.city;
    _routeCountryController.text = route.country;
    _routeTagsController.text = route.tags.join(', ');
    _routeDifficulty = route.difficulty;
  }

  void _syncReviewForm(ReviewModel review) {
    _reviewTitleController.text = review.title;
    _reviewCommentController.text = review.comment ?? '';
    _reviewRatings = review.ratings
        .map((rating) => ReviewRating(label: rating.label, score: rating.score))
        .toList(growable: false);
  }

  List<String> _parseCommaSeparated(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _loadReviewsForUser(String userId) async {
    if (_loadingReviews || _reviewsUserId == userId) {
      return;
    }

    setState(() {
      _loadingReviews = true;
      _reviewsMessage = '';
      _reviewsUserId = userId;
    });

    try {
      final reviews = await reviewService.getReviewsByUser(userId);
      if (!mounted) return;

      setState(() {
        _reviews = reviews;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _reviews = const <ReviewModel>[];
        _reviewsMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingReviews = false;
        });
      }
    }
  }

  void _startEditingReview(ReviewModel review) {
    setState(() {
      _editingReviewId = review.id;
      _reviewsMessage = '';
      _syncReviewForm(review);
    });
  }

  void _cancelReviewEdit() {
    setState(() {
      _editingReviewId = null;
      _reviewsMessage = '';
      _reviewTitleController.clear();
      _reviewCommentController.clear();
      _reviewRatings = const <ReviewRating>[];
    });
  }

  void _changeReviewRating(String label, double score) {
    setState(() {
      _reviewRatings = _reviewRatings
          .map(
            (rating) => rating.label == label
                ? ReviewRating(label: rating.label, score: score)
                : rating,
          )
          .toList(growable: false);
    });
  }

  Future<void> _saveReview(ReviewModel review) async {
    final title = _reviewTitleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _reviewsMessage = 'Review title is required.';
      });
      return;
    }

    setState(() {
      _savingReview = true;
      _reviewsMessage = '';
    });

    try {
      final updatedReview = await reviewService.updateReview(
        review.id,
        ReviewUpdateInput(
          title: title,
          comment: _reviewCommentController.text,
          ratings: _reviewRatings,
        ),
      );

      if (!mounted) return;

      setState(() {
        _reviews = _reviews
            .map((item) => item.id == updatedReview.id ? updatedReview : item)
            .toList(growable: false);
        _editingReviewId = null;
        _reviewsMessage = 'Review updated successfully.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _reviewsMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _savingReview = false;
        });
      }
    }
  }

  Future<void> _deleteReview(ReviewModel review) async {
    setState(() {
      _deletingReview = true;
      _reviewsMessage = '';
    });

    try {
      await reviewService.deleteReview(review.id);

      if (!mounted) return;

      setState(() {
        _reviews = _reviews
            .where((item) => item.id != review.id)
            .toList(growable: false);
        if (_editingReviewId == review.id) {
          _editingReviewId = null;
        }
        _reviewsMessage = 'Review deleted successfully.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _reviewsMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _deletingReview = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final localization = context.watch<LocalizationState>();
        final user = appState.currentUser;
        final userRoutes = user == null
            ? <RouteModel>[]
            : appState.routesByUser(user.id);
        final pointsCreated = userRoutes.fold<int>(
          0,
          (total, route) => total + route.points.length,
        );

        if (user != null && !_editingUser && _nameController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _syncUserForm(user);
            }
          });
        }

        if (user != null && _reviewsUserId != user.id && !_loadingReviews) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadReviewsForUser(user.id);
            }
          });
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onBack,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localization.t('profile.title'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Text(
                        localization.t('profile.subtitle'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (user == null)
                      _NoticeCard(
                        title: localization.t('profile.userNotFound'),
                        actionLabel: localization.t('profile.backHome'),
                        onAction: () => Navigator.of(context).pop(),
                      )
                    else ...[
                      _CardShell(
                        title: localization.t('profile.accountInfo'),
                        trailing: _editingUser
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _SmallButton(
                                    label: localization.t('common.cancel'),
                                    filled: false,
                                    onTap: _savingUser
                                        ? null
                                        : () {
                                            setState(() {
                                              _editingUser = false;
                                              _userMessage = '';
                                              _syncUserForm(user);
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  _SmallButton(
                                    label: _savingUser
                                        ? localization.t('common.saving')
                                        : localization.t('common.save'),
                                    filled: true,
                                    onTap: _savingUser
                                        ? null
                                        : () async {
                                            final wantsPasswordChange =
                                                _newPasswordController.text
                                                    .trim()
                                                    .isNotEmpty ||
                                                _confirmPasswordController.text
                                                    .trim()
                                                    .isNotEmpty;

                                            if (wantsPasswordChange) {
                                              if (_newPasswordController.text !=
                                                  _confirmPasswordController
                                                      .text) {
                                                setState(() {
                                                  _userMessage = localization.t(
                                                    'profile.passwordMismatch',
                                                  );
                                                });
                                                return;
                                              }
                                              if (_newPasswordController
                                                      .text
                                                      .length <
                                                  6) {
                                                setState(() {
                                                  _userMessage = localization.t(
                                                    'profile.passwordMin',
                                                  );
                                                });
                                                return;
                                              }
                                            }

                                            setState(() {
                                              _savingUser = true;
                                              _userMessage = '';
                                            });

                                            try {
                                              await appState.updateCurrentUser(
                                                name: _nameController.text,
                                                surname:
                                                    _surnameController.text,
                                                username:
                                                    _usernameController.text,
                                                email: _emailController.text,
                                                newPassword: wantsPasswordChange
                                                    ? _newPasswordController
                                                          .text
                                                    : null,
                                              );

                                              if (mounted) {
                                                setState(() {
                                                  _editingUser = false;
                                                  _userMessage =
                                                      wantsPasswordChange
                                                      ? localization.t(
                                                          'profile.updatedPassword',
                                                        )
                                                      : localization.t(
                                                          'profile.updated',
                                                        );
                                                });
                                              }
                                            } catch (error) {
                                              if (mounted) {
                                                setState(() {
                                                  _userMessage = error
                                                      .toString();
                                                });
                                              }
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _savingUser = false;
                                                });
                                              }
                                            }
                                          },
                                  ),
                                ],
                              )
                            : _SmallButton(
                                label: localization.t('common.edit'),
                                filled: true,
                                onTap: () {
                                  setState(() {
                                    _editingUser = true;
                                    _userMessage = '';
                                  });
                                },
                              ),
                        message: _userMessage,
                        child: _editingUser
                            ? Column(
                                children: [
                                  _ProfileField(
                                    label: localization.t('profile.name'),
                                    controller: _nameController,
                                  ),
                                  _ProfileField(
                                    label: localization.t('profile.surname'),
                                    controller: _surnameController,
                                  ),
                                  _ProfileField(
                                    label: localization.t('profile.username'),
                                    controller: _usernameController,
                                  ),
                                  _ProfileField(
                                    label: localization.t('profile.email'),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  _ProfileField(
                                    label: localization.t(
                                      'profile.newPassword',
                                    ),
                                    controller: _newPasswordController,
                                    obscureText: true,
                                  ),
                                  _ProfileField(
                                    label: localization.t(
                                      'profile.confirmNewPassword',
                                    ),
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                  ),
                                ],
                              )
                            : _UserInfoGrid(user: user),
                      ),
                      const SizedBox(height: 16),
                      _CardShell(
                        title: localization.t('profile.creatorStats'),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MiniStat(
                              label: localization.t('profile.routesCreated'),
                              value: userRoutes.length.toString(),
                            ),
                            _MiniStat(
                              label: localization.t('profile.pointsCreated'),
                              value: pointsCreated.toString(),
                            ),
                            _MiniStat(
                              label: localization.t('profile.reviewsWritten'),
                              value: _reviews.length.toString(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _CardShell(title: '', child: AchievementsSection()),
                      const SizedBox(height: 16),
                      _CardShell(
                        title: localization.t('profile.myReviews'),
                        message: _reviewsMessage,
                        child: _loadingReviews
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  localization.t('profile.loadingReviews'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : _reviews.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  localization.t('profile.noReviews'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (final review in _reviews) ...[
                                    _ReviewSummaryCard(
                                      review: review,
                                      routeName: appState
                                          .routeById(review.routeId)
                                          ?.name,
                                      isEditing: _editingReviewId == review.id,
                                      titleController: _reviewTitleController,
                                      commentController:
                                          _reviewCommentController,
                                      editableRatings: _reviewRatings,
                                      saving: _savingReview,
                                      deleting: _deletingReview,
                                      onEdit: () => _startEditingReview(review),
                                      onCancel: _cancelReviewEdit,
                                      onSave: () => _saveReview(review),
                                      onRatingChanged: _changeReviewRating,
                                      onDelete: () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (dialogContext) => AlertDialog(
                                                title: Text(
                                                  localization.t(
                                                    'profile.deleteReviewTitle',
                                                  ),
                                                ),
                                                content: Text(
                                                  localization.t(
                                                    'profile.deleteReviewConfirm',
                                                    {'name': review.title},
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop(false),
                                                    child: Text(
                                                      localization.t(
                                                        'common.cancel',
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop(true),
                                                    child: Text(
                                                      localization.t(
                                                        'common.delete',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;

                                        if (confirmed) {
                                          await _deleteReview(review);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      _CardShell(
                        title: localization.t('profile.myPublishedRoutes'),
                        message: _routeMessage,
                        child: userRoutes.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  localization.t('profile.noPublishedRoutes'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (final route in userRoutes) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppTheme.borderSoft,
                                        ),
                                      ),
                                      child: _editingRouteId == route.id
                                          ? _RouteEditForm(
                                              nameController:
                                                  _routeNameController,
                                              descriptionController:
                                                  _routeDescriptionController,
                                              coverController:
                                                  _routeCoverController,
                                              imagesController:
                                                  _routeImagesController,
                                              distanceController:
                                                  _routeDistanceController,
                                              durationController:
                                                  _routeDurationController,
                                              cityController:
                                                  _routeCityController,
                                              countryController:
                                                  _routeCountryController,
                                              tagsController:
                                                  _routeTagsController,
                                              difficulty: _routeDifficulty,
                                              onDifficultyChanged: (value) {
                                                setState(() {
                                                  _routeDifficulty = value;
                                                });
                                              },
                                              onCancel: _savingRoute
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _editingRouteId = null;
                                                        _routeMessage = '';
                                                      });
                                                    },
                                              onSave: _savingRoute
                                                  ? null
                                                  : () async {
                                                      setState(() {
                                                        _savingRoute = true;
                                                        _routeMessage = '';
                                                      });

                                                      try {
                                                        await appState.updateRoute(
                                                          routeId: route.id,
                                                          name:
                                                              _routeNameController
                                                                  .text,
                                                          description:
                                                              _routeDescriptionController
                                                                  .text,
                                                          coverImage:
                                                              _routeCoverController
                                                                  .text,
                                                          images: _parseCommaSeparated(
                                                            _routeImagesController
                                                                .text,
                                                          ),
                                                          difficulty:
                                                              _routeDifficulty,
                                                          city:
                                                              _routeCityController
                                                                  .text,
                                                          country:
                                                              _routeCountryController
                                                                  .text,
                                                          tags: _parseCommaSeparated(
                                                            _routeTagsController
                                                                .text,
                                                          ),
                                                          distance: double.tryParse(
                                                            _routeDistanceController
                                                                .text,
                                                          ),
                                                          duration: int.tryParse(
                                                            _routeDurationController
                                                                .text,
                                                          ),
                                                        );

                                                        if (mounted) {
                                                          setState(() {
                                                            _editingRouteId =
                                                                null;
                                                            _routeMessage =
                                                                'Route updated successfully.';
                                                          });
                                                        }
                                                      } catch (error) {
                                                        if (mounted) {
                                                          setState(() {
                                                            _routeMessage =
                                                                error
                                                                    .toString();
                                                          });
                                                        }
                                                      } finally {
                                                        if (mounted) {
                                                          setState(() {
                                                            _savingRoute =
                                                                false;
                                                          });
                                                        }
                                                      }
                                                    },
                                            )
                                          : _RouteSummaryCard(
                                              route: route,
                                              onEdit: () {
                                                setState(() {
                                                  _editingRouteId = route.id;
                                                  _routeMessage = '';
                                                  _syncRouteForm(route);
                                                });
                                              },
                                              onEditPoints: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        EditRoutePointsPage(
                                                          routeId: route.id,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.filled, this.onTap});

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : AppTheme.text,
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.title,
    required this.child,
    this.trailing,
    this.message = '',
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                trailing != null ? trailing! : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.primary,
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: title,
      trailing: _SmallButton(label: actionLabel, filled: true, onTap: onAction),
      child: const SizedBox.shrink(),
    );
  }
}

class _UserInfoGrid extends StatelessWidget {
  const _UserInfoGrid({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoItem>[
      _InfoItem('Name', user.name.isEmpty ? '-' : user.name),
      _InfoItem('Surname', user.surname.isEmpty ? '-' : user.surname),
      _InfoItem('Username', user.username.isEmpty ? '-' : user.username),
      _InfoItem('Email', user.email.isEmpty ? '-' : user.email),
      const _InfoItem('Password', '••••••••'),
    ];

    return Column(
      children: rows
          .map(
            (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _ReviewSummaryCard extends StatelessWidget {
  const _ReviewSummaryCard({
    required this.review,
    required this.routeName,
    required this.isEditing,
    required this.titleController,
    required this.commentController,
    required this.editableRatings,
    required this.saving,
    required this.deleting,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
    required this.onDelete,
    required this.onRatingChanged,
  });

  final ReviewModel review;
  final String? routeName;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController commentController;
  final List<ReviewRating> editableRatings;
  final bool saving;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final Future<void> Function() onDelete;
  final void Function(String label, double score) onRatingChanged;

  String get _dateLabel {
    final date = review.createdAt;
    if (date == null) {
      return '';
    }

    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isEditing
            ? [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Editing review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _SmallButton(
                      label: 'Cancel',
                      filled: false,
                      onTap: saving ? null : onCancel,
                    ),
                    const SizedBox(width: 8),
                    _SmallButton(
                      label: saving ? 'Saving...' : 'Save',
                      filled: true,
                      onTap: saving ? null : onSave,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProfileField(label: 'Title', controller: titleController),
                _ProfileField(
                  label: 'Description',
                  controller: commentController,
                ),
                ...editableRatings.map(
                  (rating) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DropdownButtonFormField<double>(
                      initialValue: rating.score,
                      decoration: InputDecoration(
                        labelText: rating.label,
                        border: const OutlineInputBorder(),
                      ),
                      items: const [0, 1, 2, 3, 4, 5]
                          .map(
                            (score) => DropdownMenuItem<double>(
                              value: score.toDouble(),
                              child: Text('$score / 5'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                onRatingChanged(rating.label, value);
                              }
                            },
                    ),
                  ),
                ),
              ]
            : [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            routeName == null || routeName!.isEmpty
                                ? 'Route ID: ${review.routeId}'
                                : 'Route: $routeName',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MiniStat(
                      label: 'Rating',
                      value: '${review.averageRating.toStringAsFixed(1)}/5',
                    ),
                  ],
                ),
                if (review.comment != null &&
                    review.comment!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    review.comment!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.5,
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (dateLabel.isNotEmpty)
                      _MiniStat(label: 'Date', value: dateLabel),
                    ...review.ratings.map(
                      (rating) => _MiniStat(
                        label: rating.label,
                        value: '${rating.score.toStringAsFixed(0)}/5',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallButton(label: 'Edit', filled: true, onTap: onEdit),
                    _SmallButton(
                      label: deleting ? 'Deleting...' : 'Delete',
                      filled: false,
                      onTap: deleting
                          ? null
                          : () {
                              onDelete();
                            },
                    ),
                  ],
                ),
              ],
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({
    required this.route,
    required this.onEdit,
    required this.onEditPoints,
  });

  final RouteModel route;
  final VoidCallback onEdit;
  final VoidCallback onEditPoints;

  @override
  Widget build(BuildContext context) {
    final pointCount = route.points.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    route.locationLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _SmallButton(label: 'Edit', filled: true, onTap: onEdit),
                const SizedBox(height: 8),
                _SmallButton(
                  label: 'Points',
                  filled: false,
                  onTap: onEditPoints,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniStat(label: 'Difficulty', value: route.difficulty.value),
            _MiniStat(label: 'Distance', value: formatDistance(route.distance)),
            _MiniStat(label: 'Duration', value: formatDuration(route.duration)),
            _MiniStat(label: 'Points', value: pointCount.toString()),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          route.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            height: 1.5,
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
        if (route.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: route.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _RouteEditForm extends StatelessWidget {
  const _RouteEditForm({
    required this.nameController,
    required this.descriptionController,
    required this.coverController,
    required this.imagesController,
    required this.distanceController,
    required this.durationController,
    required this.cityController,
    required this.countryController,
    required this.tagsController,
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController coverController;
  final TextEditingController imagesController;
  final TextEditingController distanceController;
  final TextEditingController durationController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController tagsController;
  final RouteDifficulty difficulty;
  final ValueChanged<RouteDifficulty> onDifficultyChanged;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Editing route',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SmallButton(label: 'Cancel', filled: false, onTap: onCancel),
                const SizedBox(width: 8),
                _SmallButton(label: 'Save', filled: true, onTap: onSave),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileField(label: 'Name', controller: nameController),
        _DifficultyDropdown(value: difficulty, onChanged: onDifficultyChanged),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProfileField(label: 'City', controller: cityController),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileField(
                label: 'Country',
                controller: countryController,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _ProfileField(
                label: 'Distance',
                controller: distanceController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileField(
                label: 'Duration',
                controller: durationController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        _ProfileField(label: 'Description', controller: descriptionController),
        _ProfileField(label: 'Cover image', controller: coverController),
        _ProfileField(
          label: 'Images (comma separated)',
          controller: imagesController,
        ),
        _ProfileField(
          label: 'Tags (comma separated)',
          controller: tagsController,
        ),
      ],
    );
  }
}

class _DifficultyDropdown extends StatelessWidget {
  const _DifficultyDropdown({required this.value, required this.onChanged});

  final RouteDifficulty value;
  final ValueChanged<RouteDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RouteDifficulty>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Difficulty'),
      style: const TextStyle(fontSize: 14, color: AppTheme.text),
      items: RouteDifficulty.values
          .map(
            (difficulty) => DropdownMenuItem<RouteDifficulty>(
              value: difficulty,
              child: Text(difficulty.value),
            ),
          )
          .toList(growable: false),
      onChanged: (nextValue) {
        if (nextValue != null) {
          onChanged(nextValue);
        }
      },
    );
  }
}
