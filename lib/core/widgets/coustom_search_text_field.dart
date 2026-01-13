// import '../configs/configs.dart';
//
// class CustomSearchTextFormField extends StatelessWidget {
//   final TextEditingController controller;
//   final ValueChanged<String> onChanged;
//   final VoidCallback? onClear;
//   final String hintText;
//   final bool forSearch;
//   final Widget? icon;
//   final Widget? suffixIcon;
//   final String? labelText;
//   final bool? isRequired;
//   final bool isRequiredLabel;
//
//   const CustomSearchTextFormField({
//     super.key,
//     required this.controller,
//     required this.onChanged,
//     this.onClear,
//     this.hintText = "Search",
//     this.forSearch = true,
//     this.icon,
//     this.suffixIcon,
//     this.labelText,
//     this.isRequired,
//     this.isRequiredLabel = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label widget
//         isRequiredLabel
//             ? Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               labelText??"",
//               style: AppTextStyle.labelDropdownTextStyle(context),
//             ),
//             const SizedBox(width: 4),
//             isRequired == true
//                 ? Text(
//               "*",
//               style: AppTextStyle.errorTextStyle(context),
//             )
//                 : Container(),
//           ],
//         )
//             : Container(),
//
//         isRequiredLabel
//             ? const SizedBox(height: 2)
//             : Container(),
//
//         // Search field
//         ConstrainedBox(
//           constraints: const BoxConstraints(
//             maxHeight: 52, // Fixed max height
//             minHeight: 40, // Fixed min height
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               // border: Border.all(color: AppColors.primaryColor(context), width: 0.5),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: TextFormField(
//               controller: controller,
//               onChanged: onChanged,
//               minLines: 1,
//               maxLines: 1,
//               // style: AppTextStyle.searchTextStyle(context),
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: forSearch ? "Search $hintText" : hintText,
//                 hintStyle: TextStyle(
//                   color:  AppColors.text(context),
//                   fontWeight: FontWeight.w300,
//                   fontSize: 14,
//                 ),
//                 prefixIcon: icon,
//                 errorMaxLines: 2,
//                 suffixIcon: suffixIcon,
//                 contentPadding: const EdgeInsets.only(
//                   top: 10.0,
//                   bottom: 10.0,
//                   left: 6,
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(AppSizes.radius),
//                   borderSide: BorderSide(color: AppColors.error),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(AppSizes.radius),
//                   borderSide: BorderSide(color:  AppColors.text(context)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(AppSizes.radius),
//                   borderSide: BorderSide(color: AppColors.border),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(AppSizes.radius),
//                   borderSide: BorderSide(color: AppColors.error),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import '../configs/configs.dart';

class CustomSearchTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool forSearch;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? labelText;
  final bool? isRequired;
  final bool isRequiredLabel;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool autofocus;

  const CustomSearchTextFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = "Search",
    this.forSearch = true,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText,
    this.isRequired,
    this.isRequiredLabel = true,
    this.enabled = true,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label Section
        if (labelText != null && labelText!.isNotEmpty) ...[
          _buildLabel(context),
          const SizedBox(height: 4),
        ],

        // Search Field
        _buildTextField(context),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          labelText!,
          style: AppTextStyle.labelDropdownTextStyle(context),
        ),
        if (isRequired == true) ...[
          const SizedBox(width: 4),
          Text(
            "*",
            style: AppTextStyle.errorTextStyle(context),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 38,
        minHeight: 35,
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        minLines: 1,
        maxLines: 1,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLength: maxLength,
        autofocus: autofocus,
        validator: validator,
        style: TextStyle(
          color: enabled ?  AppColors.text(context) :  AppColors.text(context).withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: forSearch ? "Search $hintText" : hintText,
          hintStyle: TextStyle(
            color:  AppColors.text(context).withValues(alpha: 0.5),
            fontWeight: FontWeight.w300,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon ?? (forSearch ? _buildDefaultSearchIcon(context) : null),
          suffixIcon:  _buildClearButton(context),
          counterText: "", // Hide counter text when maxLength is set
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 12.0,
          ),
          filled: !enabled,
          fillColor: !enabled ? Colors.grey[100] : null,
          errorMaxLines: 2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            borderSide: BorderSide(color: AppColors.border),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            borderSide: BorderSide(color: AppColors.primaryColor(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            borderSide: BorderSide(color: AppColors.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            borderSide: BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultSearchIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Icon(
        Icons.search,
        size: 20,
        color:  AppColors.text(context).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.clear,
        size: 20,
        color:  AppColors.text(context).withValues(alpha: 0.5),
      ),
      onPressed: onClear ?? () {
        controller.clear();
        onChanged("");
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    );
  }
}