import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplux/Auth/LoginPage/viewmodel/LogInCubit.dart';
import 'package:shoplux/Auth/SignUpPage/view/SignUpPage.dart';
import 'package:shoplux/MainPages/HomePage/view/HomePage.dart';

import '../../../constants/AppColors.dart';
import '../../../core/app_color_scheme.dart';
import '../../Components/CustomTextField.dart';
import '../viewmodel/LogInState.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }

        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.055),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '👋',
                          style: TextStyle(fontSize: size.width * 0.09),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome ',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: size.width * 0.13,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Serif',
                                  height: 1,
                                ),
                              ),
                              TextSpan(
                                text: 'back',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: size.width * 0.13,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Serif',
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.012),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sign in to your ShopLux account',
                          style: TextStyle(
                            color: colors.grey,
                            fontSize: size.width * 0.048,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _sectionTitle(
                          context,
                          title: 'EMAIL',
                          fontSize: size.width * 0.05,
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      CustomTextField(
                        controller: emailController,
                        hintText: 'alex@example.com',
                        icon: Icons.email_outlined,
                      ),

                      SizedBox(height: size.height * 0.025),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle(
                            context,
                            title: 'PASSWORD',
                            fontSize: size.width * 0.05,
                          ),
                          Text(
                            'Forgot?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.01),

                      CustomTextField(
                        controller: passwordController,
                        hintText: '••••••••',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),

                      SizedBox(height: size.height * 0.03),

                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.068,
                        child: ElevatedButton(
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                                  context.read<LoginCubit>().login(
                                      emailController.text,
                                      passwordController.text);
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: state is LoginLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: size.width * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: colors.divider,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                            ),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: colors.grey,
                                fontSize: size.width * 0.042,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: colors.divider,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03),

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

                      SizedBox(height: size.height * 0.04),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: colors.grey,
                                  fontSize: size.width * 0.046,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: size.width * 0.046,
                                  fontWeight: FontWeight.bold,
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
