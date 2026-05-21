import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplux/Auth/SignUpPage/viewmodel/SignUpCubit.dart';
import 'package:shoplux/Auth/SignUpPage/viewmodel/SignUpState.dart';

import '../../../constants/AppColors.dart';
import '../../../core/app_color_scheme.dart';
import '../../Components/CustomTextField.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sign Up Success')));
        }

        if (state is SignUpFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,

          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: size.height * 0.1),

                    Text('🫴🔑', style: TextStyle(fontSize: size.width * 0.09)),

                    SizedBox(height: size.height * 0.03),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Create ',
                            style: TextStyle(
                              color: colors.text,
                              fontSize: size.width * 0.13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Serif',
                            ),
                          ),
                          TextSpan(
                            text: 'account',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: size.width * 0.13,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Serif',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.015),

                    Text(
                      'Join ShopLux and start shopping',
                      style: TextStyle(
                        color: colors.grey,
                        fontSize: size.width * 0.045,
                      ),
                    ),

                    SizedBox(height: size.height * 0.045),

                    _sectionTitle(
                      context,
                      title: 'FULL NAME',
                      fontSize: size.width * 0.05,
                    ),

                    SizedBox(height: size.height * 0.012),

                    CustomTextField(
                      controller: nameController,
                      hintText: 'Enter your full name',
                      icon: Icons.person_outline,
                    ),

                    SizedBox(height: size.height * 0.025),

                    _sectionTitle(
                      context,
                      title: 'EMAIL',
                      fontSize: size.width * 0.05,
                    ),

                    SizedBox(height: size.height * 0.012),

                    CustomTextField(
                      controller: emailController,
                      hintText: 'your@email.com',
                      icon: Icons.email_outlined,
                    ),

                    SizedBox(height: size.height * 0.025),

                    _sectionTitle(
                      context,
                      title: 'PASSWORD',
                      fontSize: size.width * 0.05,
                    ),

                    SizedBox(height: size.height * 0.012),

                    CustomTextField(
                      controller: passwordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    SizedBox(height: size.height * 0.025),

                    _sectionTitle(
                      context,
                      title: 'CONFIRM PASSWORD',
                      fontSize: size.width * 0.05,
                    ),

                    SizedBox(height: size.height * 0.012),

                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    SizedBox(height: size.height * 0.04),

                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<SignUpCubit>().SignUp(
                            emailController.text,
                            passwordController.text,
                            nameController.text,
                          );

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: colors.divider),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                          ),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: colors.grey,
                              fontSize: size.width * 0.043,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: colors.divider),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.035),

                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(context, title: 'Google'),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Expanded(
                          child: _socialButton(context, title: 'Apple'),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.05),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: colors.grey,
                                fontSize: size.width * 0.046,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * 0.046,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _socialButton(BuildContext context, {required String title}) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return Container(
      height: size.height * 0.065,
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.fieldBorder),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required String title,
    required double fontSize,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: context.colors.grey,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: fontSize,
      ),
    );
  }
}
