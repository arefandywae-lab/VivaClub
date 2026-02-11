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
  bool _isPhoneLogin = true; // State for Tabs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.skyBlue.withValues(alpha: 0.1),
              AppTheme.mintGreen.withValues(alpha: 0.1),
              AppTheme.cottonPink.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/dashboard'); // Navigate to dashboard on success
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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
                      // Header
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to continue your journey',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textGrey,
                        ),
                      ),
                      SizedBox(height: 32.h),

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
                        child: Column(
                          children: [
                            // Tabs
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  _buildTab(
                                    title: 'Phone',
                                    icon: Icons.phone_android,
                                    isSelected: _isPhoneLogin,
                                    onTap: () =>
                                        setState(() => _isPhoneLogin = true),
                                  ),
                                  _buildTab(
                                    title: 'Email',
                                    icon: Icons.email_outlined,
                                    isSelected: !_isPhoneLogin,
                                    onTap: () =>
                                        setState(() => _isPhoneLogin = false),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Identifier Input
                                  _buildInput(
                                    controller: _usernameController,
                                    hint: _isPhoneLogin
                                        ? '081 234 5678'
                                        : 'you@example.com',
                                    icon: _isPhoneLogin
                                        ? Icons.phone
                                        : Icons.mail,
                                    label: _isPhoneLogin
                                        ? 'Phone Number'
                                        : 'Email Address',
                                  ),
                                  SizedBox(height: 16.h),

                                  // Password Input
                                  _buildInput(
                                    controller: _passwordController,
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    label: 'Password',
                                    isPassword: true,
                                  ),
                                  SizedBox(height: 24.h),

                                  // Submit Button
                                  Container(
                                    width: double.infinity,
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.r),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.skyBlue,
                                          AppTheme.mintGreen,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.mintGreen.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                context.read<AuthBloc>().add(
                                                  AuthLoginRequested(
                                                    _usernameController.text,
                                                    _passwordController.text,
                                                  ),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24.r,
                                          ),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                const Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.h),
                            Text(
                              'By continuing, you agree to our Terms of Service',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.skyBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? AppTheme.textDark : AppTheme.textGrey,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.textDark : AppTheme.textGrey,
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
    required String hint,
    required IconData icon,
    required String label,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(fontSize: 16.sp, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textGrey.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, color: AppTheme.textGrey, size: 20.sp),
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
              borderSide: const BorderSide(color: AppTheme.skyBlue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
