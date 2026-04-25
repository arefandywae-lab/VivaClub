import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPhoneLogin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      
      if (_isPhoneLogin) {
        username = username.replaceAll(' ', '').replaceAll('-', '');
        if (username.startsWith('0')) {
          username = '+66${username.substring(1)}';
        }
      }

      context.read<AuthBloc>().add(
        AuthLoginRequested(username, _passwordController.text),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'name@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<AuthBloc>().add(AuthForgotPasswordRequested(controller.text.trim()));
                Navigator.pop(context);
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AuthForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.mintGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/main_logo.png',
                          height: 120.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 16.h),
                        
                        Text(
                          'Viva Club',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Sustainability-First Mental Health',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? AppTheme.darkTextGrey : AppTheme.textGrey,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.transparent : Colors.white,
                            borderRadius: BorderRadius.circular(32.r),
                            border: isDark ? Border.all(color: Colors.white10) : null,
                            boxShadow: isDark ? [] : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : AppTheme.background,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  children: [
                                    _buildTab('Phone', Icons.phone_android, _isPhoneLogin),
                                    _buildTab('Email', Icons.mail_outline, !_isPhoneLogin),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32.h),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildInput(
                                      controller: _usernameController,
                                      label: _isPhoneLogin ? 'Phone Number' : 'Email Address',
                                      hint: _isPhoneLogin ? '08x xxx xxxx' : 'name@email.com',
                                      icon: _isPhoneLogin ? Icons.phone : Icons.email,
                                      keyboardType: _isPhoneLogin ? TextInputType.phone : TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildInput(
                                      controller: _passwordController,
                                      label: 'Password',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                    ),
                                    
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _showForgotPasswordDialog,
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),

                                    Container(
                                      width: double.infinity,
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18.r),
                                        color: AppTheme.primary,
                                        boxShadow: isDark ? [] : [
                                          BoxShadow(
                                            color: AppTheme.primary.withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _onLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                width: 24.w,
                                                height: 24.w,
                                                child: const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                              )
                                            : Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF2D3748),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: TextStyle(color: isDark ? AppTheme.darkTextGrey : AppTheme.textGrey)),
                            GestureDetector(
                              onTap: () => context.go('/signup'),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Doctor/Medical Icon in Top Right
              Positioned(
                top: 40.h,
                right: 20.w,
                child: IconButton(
                  onPressed: () => context.go('/doctor-login'),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      color: AppTheme.primary,
                      size: 24.sp,
                    ),
                  ),
                  tooltip: 'Medical Staff Portal',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          if (title == 'Phone') _isPhoneLogin = true;
          else _isPhoneLogin = false;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white12 : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: isSelected ? AppTheme.primary : (isDark ? Colors.white38 : AppTheme.textGrey)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : (isDark ? Colors.white38 : AppTheme.textGrey),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp, 
            fontWeight: FontWeight.w600, 
            color: isDark ? Colors.white : AppTheme.textDark
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : AppTheme.textGrey.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, size: 20.sp, color: isDark ? Colors.white38 : AppTheme.textGrey),
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
