import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:viva_club/core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.mintGreen.withValues(alpha: 0.1),
              AppTheme.skyBlue.withValues(alpha: 0.1),
              AppTheme.butteryYellow.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/dashboard');
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 24.h),

                      // Icon
                      Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.mintGreen, AppTheme.skyBlue],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.mintGreen.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Header
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Join our safe community — it\'s free',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textGrey,
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // Card
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Anonymous badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.mintGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppTheme.mintGreen.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.shield,
                                      size: 18.sp,
                                      color: AppTheme.mintGreen,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'You\'ll get an anonymous animal identity — no real name needed!',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Username
                              _buildInput(
                                controller: _usernameController,
                                hint: 'Choose a username',
                                icon: Icons.alternate_email,
                                label: 'Username',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Username is required';
                                  }
                                  if (v.length < 3) {
                                    return 'At least 3 characters';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                                    return 'Letters, numbers, and underscores only';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14.h),

                              // Email
                              _buildInput(
                                controller: _emailController,
                                hint: 'you@example.com',
                                icon: Icons.mail_outline,
                                label: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+$',
                                  ).hasMatch(v)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14.h),

                              // Password
                              _buildInput(
                                controller: _passwordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                label: 'Password',
                                isPassword: true,
                                obscure: _obscurePassword,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 8) {
                                    return 'At least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14.h),

                              // Confirm Password
                              _buildInput(
                                controller: _confirmPasswordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                label: 'Confirm Password',
                                isPassword: true,
                                obscure: _obscureConfirm,
                                onToggleObscure: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords don\'t match';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 18.h),

                              // Terms checkbox
                              GestureDetector(
                                onTap: () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 22.w,
                                      height: 22.w,
                                      margin: EdgeInsets.only(top: 2.h),
                                      decoration: BoxDecoration(
                                        color: _agreedToTerms
                                            ? AppTheme.mintGreen
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        border: Border.all(
                                          color: _agreedToTerms
                                              ? AppTheme.mintGreen
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                      ),
                                      child: _agreedToTerms
                                          ? Icon(
                                              Icons.check,
                                              size: 14.sp,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Submit Button
                              Container(
                                width: double.infinity,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  gradient: LinearGradient(
                                    colors: _agreedToTerms
                                        ? [AppTheme.mintGreen, AppTheme.skyBlue]
                                        : [
                                            Colors.grey.shade300,
                                            Colors.grey.shade400,
                                          ],
                                  ),
                                  boxShadow: _agreedToTerms
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.mintGreen
                                                .withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ElevatedButton(
                                  onPressed: (isLoading || !_agreedToTerms)
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthBloc>().add(
                                              AuthRegisterRequested(
                                                _usernameController.text.trim(),
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.w,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Create My Account',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.skyBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String label,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscure : false,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15.sp, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textGrey.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, color: AppTheme.textGrey, size: 20.sp),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: onToggleObscure,
                    child: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textGrey,
                      size: 20.sp,
                    ),
                  )
                : null,
            fillColor: AppTheme.background,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppTheme.mintGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 16.w,
            ),
          ),
          validator: validator ?? (value) => value!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
