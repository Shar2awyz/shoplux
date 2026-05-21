import 'package:flutter/material.dart';

import '../../core/app_color_scheme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return Container(
      height: size.height * 0.072,
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.fieldBorder,
          width: 1.3,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? obscure : false,
        style: TextStyle(
          color: colors.text,
          fontSize: size.width * 0.048,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: size.height * 0.018,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: const Color(0xffFFCC66),
            size: size.width * 0.065,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: colors.grey,
            fontSize: size.width * 0.048,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colors.grey,
                    size: size.width * 0.06,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
