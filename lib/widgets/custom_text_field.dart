import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hintText;

  final bool obscureText;

  final TextInputType keyboardType;

  final Widget? suffixIcon;

  final String? Function(String?)?
      validator;

  final int? maxLength;

  final TextAlign textAlign;

  final ValueChanged<String>?
      onChanged;

  final FocusNode? focusNode;
  
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,

    required this.controller,

    required this.hintText,

    this.obscureText = false,

    this.keyboardType =
        TextInputType.text,

    this.suffixIcon,

    this.validator,

    this.maxLength,

    this.textAlign =
        TextAlign.start,

    this.onChanged,
    this.focusNode,
    this.contentPadding,
  });

  @override
  Widget build(
      BuildContext context) {
    return TextFormField(
      controller: controller,

      focusNode:
          focusNode,

      obscureText:
          obscureText,

      keyboardType:
          keyboardType,

      validator:
          validator,

      maxLength:
          maxLength,

      textAlign:
          textAlign,

      onChanged:
          onChanged,

      style:
          const TextStyle(
        fontSize: 16,
        color:
            Colors.black87,
        fontWeight:
            FontWeight.w500,
      ),

      decoration:
          InputDecoration(
        hintText:
            hintText,

        hintStyle:
            const TextStyle(
          color: Color(
              0xFF9E9B98),

          fontSize: 15,

          fontWeight:
              FontWeight.normal,
        ),

        filled: true,

        fillColor:
            const Color(
                0xFFEFEFEF),

        counterText:
            '',

        contentPadding: contentPadding ??
            const EdgeInsets
                .symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
                      16),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
                      16),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
                      16),

          borderSide:
              const BorderSide(
            color:
                Color(
                    0xFFBEB6AF),

            width: 1.5,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
                      16),

          borderSide:
              const BorderSide(
            color:
                Colors
                    .redAccent,

            width: 1,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius
                  .circular(
                      16),

          borderSide:
              const BorderSide(
            color:
                Colors
                    .redAccent,

            width: 1.5,
          ),
        ),

        suffixIcon:
            suffixIcon,
      ),
    );
  }
}