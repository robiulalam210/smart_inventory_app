
import '../configs/configs.dart';

class CustomSearchTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const CustomSearchTextFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = "Search",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor,width: 0.5), borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,

        // style: AppTextStyle.searchTextStyle(context),
        decoration: InputDecoration(
          // fillColor: AppColors.bg,
          filled: true,
          hintStyle: AppTextStyle.searchTextStyle(context),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.blue.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.whiteColor.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          prefixIcon: const Icon(Iconsax.search_normal_14),
          suffixIcon: IconButton(
            onPressed: onClear, // If onClear is null, this button will be disabled
            icon: const Icon(Icons.clear),
          ),
          contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 12),
          isDense: true,
          hintText: hintText,
          labelStyle: AppTextStyle.searchTextStyle(context),
          suffixStyle: AppTextStyle.searchTextStyle(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}
