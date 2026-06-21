import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import '../utils/localization.dart';

final RegExp passwordRegex = RegExp(
  r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$',
);

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.mode});

  final AuthMode mode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _stepOne = true;
  bool _submitting = false;
  String _error = '';

  bool get _isLogin => widget.mode == AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _error = context.l10n.emailRequired;
      });
      return;
    }

    setState(() {
      _stepOne = false;
      _error = '';
    });
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final appState = context.read<AppState>();

    setState(() {
      _submitting = true;
      _error = '';
    });

    try {
      if (_isLogin) {
        await appState.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await appState.register(
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = localizedError(context, error);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? context.l10n.signIn : context.l10n.createAccount;
    final subtitle = _isLogin
        ? context.l10n.signInSubtitle
        : context.l10n.signUpSubtitle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/resources/logos/logo.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.appTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (_stepOne) ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'email@domain.com',
                        errorMaxLines: 2,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.l10n.emailRequired
                          : null,
                    ),

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _handleContinue,
                      child: Text(context.l10n.continueAction),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'email@domain.com',
                        errorMaxLines: 2,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.l10n.emailRequired
                          : null,
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: context.l10n.firstName,
                          errorMaxLines: 2,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.required
                            : null,
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          hintText: context.l10n.lastName,
                          errorMaxLines: 2,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.required
                            : null,
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: context.l10n.username,
                          errorMaxLines: 2,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.required
                            : null,
                      ),
                    ],

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: context.l10n.password,
                        errorMaxLines: 3,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.passwordRequired;
                        }

                        if (!_isLogin && !passwordRegex.hasMatch(value)) {
                          return context.l10n.passwordRules;
                        }

                        return null;
                      },
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: context.l10n.confirmPassword,
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.confirmPasswordRequired;
                          }

                          if (value != _passwordController.text) {
                            return context.l10n.passwordsDoNotMatch;
                          }

                          return null;
                        },
                      ),
                    ],

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _stepOne = true;
                                _error = '';
                                _confirmPasswordController.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _handleSubmit,
                            child: Text(
                              _submitting
                                  ? context.l10n.loading
                                  : _isLogin
                                  ? context.l10n.signIn
                                  : context.l10n.createAccountAction,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PageDot(active: _stepOne),
                      const SizedBox(width: 8),
                      _PageDot(active: !_stepOne),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Divider(),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: _submitting
                        ? null
                        : () async {
                            final appState = context.read<AppState>();

                            setState(() {
                              _submitting = true;
                              _error = '';
                            });

                            try {
                              await appState.loginWithGoogle();

                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            } catch (error) {
                              if (!context.mounted) return;
                              setState(() {
                                _error = localizedError(context, error);
                              });
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _submitting = false;
                                });
                              }
                            }
                          },
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Text(context.l10n.continueGoogle),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.apple, size: 22),
                    label: Text(context.l10n.continueAppleUnavailable),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text.rich(
                    TextSpan(
                      text: context.l10n.legalPrefix,
                      children: [
                        TextSpan(
                          text: context.l10n.termsOfService,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.text,
                          ),
                        ),
                        TextSpan(text: context.l10n.legalAnd),
                        TextSpan(
                          text: context.l10n.privacyPolicy,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.text,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? context.l10n.noAccount
                            : context.l10n.alreadyAccount,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => AuthPage(
                                mode: _isLogin
                                    ? AuthMode.register
                                    : AuthMode.login,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          _isLogin ? context.l10n.signUp : context.l10n.signIn,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.goToMainPage),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 8 : 6,
      height: active ? 8 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppTheme.text : const Color(0xFFD1D5DB),
      ),
    );
  }
}
