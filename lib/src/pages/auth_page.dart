import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';

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
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter an email address.';
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
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await appState.register(
          name: _nameController.text,
          surname: _surnameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _error = error is StateError ? error.message : 'An unexpected error occurred.';
      });
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
    final title = _isLogin ? 'Sign in' : 'Create an account';
    final subtitle = _isLogin ? 'Enter your email to continue' : 'Enter your email to sign up in this app';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F8FB), Color(0xFFF1F3F7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 0,
                  color: Colors.white.withValues(alpha: 0.96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Color(0xFFE7E8EF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Center(
                              child: Text(
                                'Trip2Guide',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF4A5770), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 18),
                          if (_stepOne)
                            Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(hintText: 'email@domain.com'),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty ? 'Please enter an email address.' : null,
                                ),
                                if (_error.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(_error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                ],
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: _handleContinue,
                                  child: const Text('Continue'),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(hintText: 'email@domain.com'),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty ? 'Please enter an email address.' : null,
                                ),
                                if (!_isLogin) ...[
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(hintText: 'First name'),
                                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _surnameController,
                                    decoration: const InputDecoration(hintText: 'Last name'),
                                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: const InputDecoration(hintText: 'Username'),
                                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(hintText: 'Password'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password.';
                                    }

                                    if (!_isLogin && value.length < 6) {
                                      return 'Use at least 6 characters.';
                                    }

                                    return null;
                                  },
                                ),
                                if (_error.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(_error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _stepOne = true;
                                            _error = '';
                                          });
                                        },
                                        child: const Text('Back'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _submitting ? null : _handleSubmit,
                                        child: Text(_submitting ? 'Loading...' : _isLogin ? 'Sign in' : 'Create account'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.account_circle_outlined),
                            label: const Text('Continue with Google'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.apple),
                            label: const Text('Continue with Apple'),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'By clicking continue, you agree to our Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.45),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isLogin ? 'Don\'t have an account?' : 'Already have an account?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (_) => AuthPage(mode: _isLogin ? AuthMode.register : AuthMode.login),
                                    ),
                                  );
                                },
                                child: Text(_isLogin ? 'Sign up' : 'Sign in'),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Go to main page'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
