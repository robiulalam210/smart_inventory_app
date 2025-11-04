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
  final bool readOnly;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            isRequiredLabel == true
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(labelText ?? hintText,
                          style: AppTextStyle.labelDropdownTextStyle(context)),
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
                // fillColor: fillColor,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingInside,
                    vertical: AppSizes.paddingInside),
                isDense: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.matteBlack,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),

                errorMaxLines: 2,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    borderSide: BorderSide(color: AppColors.error, width: 0.7)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    borderSide:
                        BorderSide(color: AppColors.matteBlack, width: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.border, width: 0.7),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.error, width: 0.7),
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
