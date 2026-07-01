// Login / Register / Google Sign-In
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscurePass = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();

    if (_isLogin) {
      await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    } else {
      await auth.registerWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
      );
    }
    if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.coral),
      );
      auth.clearError();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Step ', style: AppText.fredoka(36, AppColors.coralDark)),
                  Text('Race', style: AppText.fredoka(36, AppColors.leafDark)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Race your friends, one step at a time.', style: AppText.dmSans(14, AppColors.inkSoft)),
              const SizedBox(height: 40),

              // Tab toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.sandDeep,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _tabBtn('Sign In', _isLogin, () => setState(() => _isLogin = true)),
                    _tabBtn('Create Account', !_isLogin, () => setState(() => _isLogin = false)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      TextFormField(

                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            !_isLogin && (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(_isLogin ? 'Sign In' : 'Create Account',
                          style: AppText.fredoka(16, AppColors.white)),
                ),
              ),
              const SizedBox(height: 16),

              Row(children: [
                const Expanded(child: Divider(color: AppColors.sandDeep)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: AppText.dmSans(13, AppColors.inkSoft)),
                ),
                const Expanded(child: Divider(color: AppColors.sandDeep)),
              ]),
              const SizedBox(height: 16),

              // Google Sign-In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: AppColors.sandDeep, width: 1.5),
                    backgroundColor: AppColors.white,
                  ),
                  onPressed: _loading ? null : _googleSignIn,
                  icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                  label: Text('Continue with Google', style: AppText.dmSans(15, AppColors.ink, weight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppText.dmSans(13, active ? AppColors.ink : AppColors.inkSoft,
                  weight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
