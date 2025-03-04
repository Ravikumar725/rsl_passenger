import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_style.dart';
import '../styles/colors.dart';


class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {this.hintText,
      this.keyboardType,
      this.textCapitalization,
      this.textController,
      this.decoration,
      this.enable = false,
      super.key,
      this.suffix,
      this.style,
      this.onChanged,
      this.onSubmitted,
      this.focusNode,
      this.autofocus = false,
      this.contentPadding,
      this.maxLength,
      this.textInputAction,
      this.inputFormatters,
      this.onTap,
      this.cursorColor});

  final String? hintText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextEditingController? textController;
  final InputDecoration? decoration;
  final bool? enable;
  final TextStyle? style;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Widget? suffix;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final void Function()? onTap;
  final Color? cursorColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: textInputAction,
      inputFormatters: inputFormatters ?? [],
      focusNode: focusNode,
      enabled: enable,
      autofocus: autofocus ?? false,
      keyboardType: keyboardType ?? TextInputType.text,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      cursorColor: cursorColor ?? AppColor.kLightTextDisabled.value,
      controller: textController,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      style: style ??
          TextStyle(
              fontSize: AppFontSize.small.value,
              fontWeight: AppFontWeight.normal.value,
              color: AppColor.kPrimaryTextColor.value),
      decoration: decoration ??
          InputDecoration(
            hintText: hintText ?? "0",
            hintStyle: TextStyle(
                fontSize: AppFontSize.small.value,
                fontWeight: AppFontWeight.normal.value,
                color: AppColor.kLightTextDisabled.value),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kLightTextDisabled.value),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kLightTextDisabled.value),
            ),
            //labelText: 'Even Densed TextFiled',
            suffixIcon: suffix,
            isDense: true,
            // Added this
            contentPadding:
                contentPadding ?? EdgeInsets.all(10.r), // Added this
          ),
    );
  }
}

class CustomTextFormField1 extends StatelessWidget {
  const CustomTextFormField1(
      {this.hintText,
      this.keyboardType,
      this.validator,
      this.textController,
      this.decoration,
      this.enable = false,
      super.key,
      this.suffix,
      this.style,
      this.onChanged,
      this.onSubmitted,
      this.focusNode,
      this.autofocus = false,
      this.contentPadding,
      this.maxLength,
      this.inputFormatters,
      this.labelText,
      this.preffix,
      this.textInputAction,
      this.onTap,
      this.readOnly = false});

  final String? labelText;
  final String? hintText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextEditingController? textController;
  final InputDecoration? decoration;
  final bool? enable;
  final TextStyle? style;
  final FocusNode? focusNode;
  final bool? autofocus;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final Widget? preffix;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final void Function()? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters ?? [],
      focusNode: focusNode,
      enabled: enable,
      validator: validator,
      autofocus: autofocus ?? false,
      keyboardType: keyboardType ?? TextInputType.text,
      cursorColor: AppColor.kLightTextDisabled.value,
      controller: textController,
      onChanged: onChanged,
      textInputAction: textInputAction ?? TextInputAction.done,
      // onSubmitted: onSubmitted,
      style: style ??
          TextStyle(
              fontSize: AppFontSize.small.value,
              fontWeight: AppFontWeight.normal.value,
              color: AppColor.kPrimaryTextColor.value),
      decoration: decoration ??
          InputDecoration(
            labelText: labelText ?? null,
            hintText: hintText ?? "0",
            hintStyle: TextStyle(
                fontSize: AppFontSize.small.value,
                fontWeight: AppFontWeight.normal.value,
                color: AppColor.kLightTextPrimary.value.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kLightTextDisabled.value),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.kLightTextDisabled.value),
            ),
            //labelText: 'Even Densed TextFiled',
            suffixIcon: suffix,
            prefix: preffix,

            isDense: true,
            // Added this
            contentPadding:
                contentPadding ?? EdgeInsets.all(10.r), // Added this
          ),
      onTap: onTap,
      readOnly: readOnly,
    );
  }
}
