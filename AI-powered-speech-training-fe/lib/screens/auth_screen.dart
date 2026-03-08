import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final Function(Map<String, dynamic> user) onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedRole = 'user';
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (_isLogin) {
        result = await ApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await ApiService.register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );
      }

      if (result.containsKey('token')) {
        widget.onAuthenticated(result['user']);
      } else {
        _showError(result['message'] ?? 'Đã xảy ra lỗi');
      }
    } catch (e) {
      _showError('Không thể kết nối server. Kiểm tra lại kết nối.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A5F), Color(0xFF0F1C2E)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI Speaking Practice',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? 'Đăng nhập tài khoản' : 'Tạo tài khoản mới',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username (register only)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) =>
                              v == null || v.trim().length < 3
                                  ? 'Username ít nhất 3 ký tự'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || !v.contains('@')
                                ? 'Email không hợp lệ'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.length < 6
                                ? 'Mật khẩu ít nhất 6 ký tự'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Role selection (register only)
                      if (!_isLogin) ...[
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Vai trò',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('User - Luyện nói'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin - Quản trị'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedRole = v);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 8),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle login/register
                      TextButton(
                        onPressed: () {
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(
                          _isLogin
                              ? 'Chưa có tài khoản? Đăng ký'
                              : 'Đã có tài khoản? Đăng nhập',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
