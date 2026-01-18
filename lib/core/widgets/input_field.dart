

import '../core.dart';

import '../core.dart';

class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    this.controller,
    required this.hintText,
    required this.keyboardType,
    this.labelText,
    this.suffixIcon,
    this.autofillHints,
    this.obscureText,
    this.textInputAction,
    this.readOnly,
    this.icon,
    this.fillColor,
    this.autoFocus,
    this.validator,
    this.onChanged,
    this.onTap,
    this.isRequired = false,
    this.isRequiredLable = true,
    this.inputFormatters,
    this.focusNode,
    this.maxLength,
  });

  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? autofillHints;
  final bool? obscureText;
  final Icon? icon;
  final bool? readOnly;
  final bool? autoFocus;
  final bool isRequired;
  final bool isRequiredLable;
  final Color? fillColor;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final int? maxLength;
  final FocusNode? focusNode;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late final TextEditingController _controller;
  bool _externalController = false;

  @override
  void initState() {
    super.initState();
    _externalController = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (!_externalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 LABEL (ONLY WHEN ENABLED)
        if (widget.isRequiredLable) ...[
          Row(
            children: [
              Text(
                widget.labelText ?? widget.hintText,
                style: AppTextStyle.labelDropdownTextStyle(context),
              ),
              if (widget.isRequired)
                const Text(
                  " *",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        /// 🔹 FIXED HEIGHT INPUT
        SizedBox(
          height: 55,
          child: TextFormField(
            controller: _controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText ?? false,
            readOnly: widget.readOnly ?? false,
            autofocus: widget.autoFocus ?? false,
            maxLength: widget.maxLength,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            inputFormatters: widget.inputFormatters,
            autofillHints: widget.autofillHints != null
                ? [widget.autofillHints!]
                : null,
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyle.cardLevelText(context),
            decoration: InputDecoration(
              counterText: "",
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.greyColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              isDense: true,
              prefixIcon: widget.icon,
              suffixIcon: widget.suffixIcon,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 10),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide:
                BorderSide(color: AppColors.greyColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide:
                BorderSide(color: AppColors.text(context)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide:
                BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide:
                BorderSide(color: AppColors.error),
              ),
            ),
            onTapOutside: (_) =>
                FocusScope.of(context).unfocus(),
          ),
        ),
      ],
    );
  }
}


class CustomInputFieldPayRoll extends StatefulWidget {
  const CustomInputFieldPayRoll({
    super.key,
    this.controller,
    required this.hintText,
    required this.levelText,
    required this.keyboardType,
    this.suffixIcon,
    this.bottom,
    this.autofillHints,
    this.obscureText,
    this.textInputAction,
    this.readOnly,
    this.icon,
    this.prefixIcon,
    this.fillColor,
    this.maxLine = 5, // default maximum lines
    this.autoFocus,
    this.validator,
    this.radius = AppSizes.borderRadiusSize,
    this.onChanged,
    this.onTap,
    this.forSearch = false,
    this.isRequired,
    this.isRequiredLevle = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final String levelText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? autofillHints;
  final bool? obscureText;
  final Icon? icon;
  final ImageIcon? prefixIcon;
  final bool? readOnly;
  final bool? autoFocus;
  final bool? isRequired;
  final bool? isRequiredLevle;
  final bool forSearch;
  final Color? fillColor;
  final InkWell? suffixIcon;
  final int maxLine;
  final double? bottom;
  final String? Function(String?)? validator;
  final double radius;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  @override
  CustomInputFieldPayRollState createState() => CustomInputFieldPayRollState();
}

class CustomInputFieldPayRollState extends State<CustomInputFieldPayRoll> {
  late TextEditingController _controller;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.controller != null;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (!_isExternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: widget.maxLine * 40.0, // Adjust max height as needed
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: true,
          child: Column(
            children: [
              widget.isRequiredLevle == true
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.levelText,
                          style: AppTextStyle.labelDropdownTextStyle(context),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        widget.isRequired == true
                            ? Text(
                                "*",
                                style: AppTextStyle.cardLevelText(context),
                              )
                            : Container()
                      ],
                    )
                  : Container(),
              widget.isRequiredLevle == true
                  ? const SizedBox(
                      height: 5,
                    )
                  : Container(),
              TextFormField(
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                controller: _controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText ?? false,
                autofillHints: widget.autofillHints != null
                    ? [widget.autofillHints!]
                    : null,
                readOnly: widget.readOnly ?? false,
                textInputAction: widget.textInputAction,
                maxLines: null,
                minLines: 1,
                autofocus: widget.autoFocus ?? false,
                validator: widget.validator,
                textAlignVertical: TextAlignVertical.center,
                obscuringCharacter: '*',
                style: AppTextStyle.cardLevelText(context),
                decoration: InputDecoration(
                  fillColor: widget.fillColor,
                  filled: true,
                  hintStyle: AppTextStyle.cardLevelText(context),
                  isCollapsed: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius),
                    borderSide: BorderSide(
                        color: AppColors.primaryColor(context).withValues(alpha: 0.5),
                        width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius),
                    borderSide: BorderSide(
                        color: AppColors.primaryColor(context).withValues(alpha: 0.5),
                        width: 0.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius),
                    borderSide: BorderSide(
                        color: AppColors.errorColor(context).withValues(alpha: 0.5),
                        width: 1.0), // Customize error border color
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.radius),
                    borderSide: BorderSide(
                        color: AppColors.errorColor(context).withValues(alpha: 0.5),
                        width: 1.5), // Customize focused error border color
                  ),
                  errorStyle: AppTextStyle.errorTextStyle(context),
                  suffixIcon: widget.suffixIcon,
                  prefixIcon: widget.prefixIcon,
                  contentPadding:
                      const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 12),
                  isDense: true,
                  hintText:
                      widget.forSearch ? widget.hintText : widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                inputFormatters: widget.keyboardType == TextInputType.number
                    ? [
                        FilteringTextInputFormatter.allow(RegExp('^[0-9]*')),
                      ]
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

