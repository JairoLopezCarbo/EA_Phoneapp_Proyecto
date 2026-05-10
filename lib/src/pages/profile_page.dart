import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

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

  bool _editingUser = false;
  bool _savingUser = false;
  bool _savingRoute = false;
  String _userMessage = '';
  String _routeMessage = '';
  String? _editingRouteId;
  RouteDifficulty _routeDifficulty = RouteDifficulty.medium;

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

  List<String> _parseCommaSeparated(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        final userRoutes = user == null
            ? <RouteModel>[]
            : appState.routesByUser(user.id);

        if (user != null && !_editingUser && _nameController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _syncUserForm(user);
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
                        const Expanded(
                          child: Text(
                            'My profile',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 48),
                      child: Text(
                        'View and edit your account information and routes.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (user == null)
                      _NoticeCard(
                        title: 'User session not found.',
                        actionLabel: 'Back to home',
                        onAction: () => Navigator.of(context).pop(),
                      )
                    else ...[
                      _CardShell(
                        title: 'Account information',
                        trailing: _editingUser
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _SmallButton(
                                    label: 'Cancel',
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
                                    label: _savingUser ? 'Saving...' : 'Save',
                                    filled: true,
                                    onTap: _savingUser
                                        ? null
                                        : () async {
                                            final wantsPasswordChange =
                                                _newPasswordController.text.trim().isNotEmpty ||
                                                _confirmPasswordController.text.trim().isNotEmpty;

                                            if (wantsPasswordChange) {
                                              if (_newPasswordController.text !=
                                                  _confirmPasswordController.text) {
                                                setState(() {
                                                  _userMessage = 'The new passwords do not match.';
                                                });
                                                return;
                                              }
                                              if (_newPasswordController.text.length < 6) {
                                                setState(() {
                                                  _userMessage =
                                                      'The new password must contain at least 6 characters.';
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
                                                surname: _surnameController.text,
                                                username: _usernameController.text,
                                                email: _emailController.text,
                                                newPassword: wantsPasswordChange
                                                    ? _newPasswordController.text
                                                    : null,
                                              );
                                              if (mounted) {
                                                setState(() {
                                                  _editingUser = false;
                                                  _userMessage = wantsPasswordChange
                                                      ? 'Profile and password updated successfully.'
                                                      : 'Profile updated successfully.';
                                                });
                                              }
                                            } catch (error) {
                                              if (mounted) {
                                                setState(() {
                                                  _userMessage = error.toString();
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
                                label: 'Edit',
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
                                  _ProfileField(label: 'Name', controller: _nameController),
                                  _ProfileField(label: 'Surname', controller: _surnameController),
                                  _ProfileField(label: 'Username', controller: _usernameController),
                                  _ProfileField(
                                    label: 'Email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  _ProfileField(
                                    label: 'New password',
                                    controller: _newPasswordController,
                                    obscureText: true,
                                  ),
                                  _ProfileField(
                                    label: 'Confirm new password',
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                  ),
                                ],
                              )
                            : _UserInfoGrid(user: user),
                      ),
                      const SizedBox(height: 16),
                      _CardShell(
                        title: 'My published routes',
                        message: _routeMessage,
                        child: userRoutes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'You have not published any routes yet.',
                                  style: TextStyle(
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
                                        border: Border.all(color: AppTheme.borderSoft),
                                      ),
                                      child: _editingRouteId == route.id
                                          ? _RouteEditForm(
                                              nameController: _routeNameController,
                                              descriptionController: _routeDescriptionController,
                                              coverController: _routeCoverController,
                                              imagesController: _routeImagesController,
                                              distanceController: _routeDistanceController,
                                              durationController: _routeDurationController,
                                              cityController: _routeCityController,
                                              countryController: _routeCountryController,
                                              tagsController: _routeTagsController,
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
                                                          name: _routeNameController.text,
                                                          description: _routeDescriptionController.text,
                                                          coverImage: _routeCoverController.text,
                                                          images: _parseCommaSeparated(_routeImagesController.text),
                                                          difficulty: _routeDifficulty,
                                                          city: _routeCityController.text,
                                                          country: _routeCountryController.text,
                                                          tags: _parseCommaSeparated(_routeTagsController.text),
                                                          distance: double.tryParse(_routeDistanceController.text),
                                                          duration: int.tryParse(_routeDurationController.text),
                                                        );
                                                        if (mounted) {
                                                          setState(() {
                                                            _editingRouteId = null;
                                                            _routeMessage = 'Route updated successfully.';
                                                          });
                                                        }
                                                      } catch (error) {
                                                        if (mounted) {
                                                          setState(() {
                                                            _routeMessage = error.toString();
                                                          });
                                                        }
                                                      } finally {
                                                        if (mounted) {
                                                          setState(() {
                                                            _savingRoute = false;
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
          border: Border.all(color: filled ? AppTheme.primary : AppTheme.border),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              if (trailing != null) ?trailing,
            ],
          ),
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
          const SizedBox(height: 12),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({required this.route, required this.onEdit});

  final RouteModel route;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
            _SmallButton(label: 'Edit', filled: true, onTap: onEdit),
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
          ],
        ),
        const SizedBox(height: 10),
        Text(
          route.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.5, fontSize: 13, color: AppTheme.textMuted),
        ),
        if (route.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: route.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
            Expanded(child: _ProfileField(label: 'City', controller: cityController)),
            const SizedBox(width: 10),
            Expanded(child: _ProfileField(label: 'Country', controller: countryController)),
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
        _ProfileField(label: 'Images (comma separated)', controller: imagesController),
        _ProfileField(label: 'Tags (comma separated)', controller: tagsController),
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
