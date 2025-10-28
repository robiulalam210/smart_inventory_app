import '../configs/configs.dart';

class CustomSearchTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool forSearch;
  final Widget? icon;
  final Widget? suffixIcon;
  final String? labelText;
  final bool? isRequired;
  final bool isRequiredLabel;

  const CustomSearchTextFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = "Search",
    this.forSearch = true,
    this.icon,
    this.suffixIcon,
    this.labelText,
    this.isRequired,
    this.isRequiredLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label widget
        isRequiredLabel
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              labelText??"",
              style: AppTextStyle.labelDropdownTextStyle(context),
            ),
            const SizedBox(width: 4),
            isRequired == true
                ? Text(
              "*",
              style: AppTextStyle.errorTextStyle(context),
            )
                : Container(),
          ],
        )
            : Container(),

        isRequiredLabel
            ? const SizedBox(height: 2)
            : Container(),

        // Search field
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 52, // Fixed max height
            minHeight: 40, // Fixed min height
          ),
          child: Container(
            decoration: BoxDecoration(
              // border: Border.all(color: AppColors.primaryColor, width: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              minLines: 1,
              maxLines: 1,
              // style: AppTextStyle.searchTextStyle(context),
              decoration: InputDecoration(
                isDense: true,
                hintText: forSearch ? "Search $hintText" : hintText,
                hintStyle: TextStyle(
                  color: AppColors.matteBlack,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
                prefixIcon: icon,
                errorMaxLines: 2,
                suffixIcon: suffixIcon,
                contentPadding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  left: 6,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.matteBlack),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}