import '../core.dart';

class AppTextField extends StatelessWidget {
  const AppTextField(
      { this.textInputAction,
      this.labelText,
      required this.hintText,
      required this.keyboardType,
      required this.controller,
      super.key,
      this.onChanged,
      this.validator,
      this.fillColor,
      this.obscureText,
      this.suffixIcon,
      this.prefixIcon,
      this.onEditingComplete,
      this.autofocus,
      this.isRequired,
      this.isRequiredLabel = true,
      this.onFieldSubmitted,
      this.focusNode,
      this.readOnly = false});

  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool? obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  final bool? isRequired;
  final bool? isRequiredLabel;
  final String? labelText;
  final String hintText;
  final bool? autofocus;
  final Color? fillColor;

  final bool readOnly;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SingleChildScrollView(
        child: Column(
          children: [
            isRequiredLabel == true
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(labelText ?? hintText,
                          style: AppTextStyle.labelDropdownTextStyle(context).copyWith(
                            color: AppColors.text(context)
                          )),
                      const SizedBox(
                        width: 4,
                      ),
                      isRequired == true
                          ? Text("*",
                              style:
                                  AppTextStyle.labelDropdownTextStyle(context))
                          : Container()
                    ],
                  )
                : Container(),
            const SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              focusNode: focusNode,
              onChanged: onChanged,
              autofocus: autofocus ?? false,
              validator: validator,
              obscureText: obscureText ?? false,
              obscuringCharacter: '*',
              onEditingComplete: onEditingComplete,
              readOnly: readOnly,
              decoration: InputDecoration(
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                filled: true,
                fillColor: fillColor ??
                    AppColors.primaryColor(context).withValues(alpha: 0.05), // theme background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.5), width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.primaryColor(context), width: 0.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide:  BorderSide(color: AppColors.errorColor(context), width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.5), width: 0.5),
                ),
              ),

              onFieldSubmitted: onFieldSubmitted,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
      ),
    );
  }
}
