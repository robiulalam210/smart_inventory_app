


import '../../../../../core/configs/configs.dart';

class VisitTypeToggle extends StatefulWidget {
  final Function(String visitType)? onChanged;
  final String initialType;

  const VisitTypeToggle({
    super.key,
    this.onChanged,
    this.initialType = "In",
  });


  @override
  State<VisitTypeToggle> createState() => _VisitTypeToggleState();
}

class _VisitTypeToggleState extends State<VisitTypeToggle> {
  late int selectedIndex;
  final List<String> visitTypes = ["In", "Out"];

  @override
  void initState() {
    super.initState();
    selectedIndex = visitTypes.indexOf(widget.initialType);
  }

  @override
  void didUpdateWidget(covariant VisitTypeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialType != oldWidget.initialType) {
      setState(() {
        selectedIndex = visitTypes.indexOf(widget.initialType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Visit Type",
          style: AppTextStyle.labelDropdownTextStyle(context),
        ),
        const SizedBox(height: 5),
        ToggleButtons(
          constraints: const BoxConstraints(minHeight: 30, maxHeight: 50,minWidth: 40),
          borderRadius: BorderRadius.circular(8),

          isSelected: List.generate(
              visitTypes.length, (index) => index == selectedIndex),
          onPressed: (index) {
            setState(() {
              selectedIndex = index;
            });
            widget.onChanged?.call(visitTypes[index]);
          },
          children: List.generate(visitTypes.length, (index) {
            final isSelected = selectedIndex == index;
            final text = visitTypes[index];
            final color = text == "In"
                ? Colors.green
                : Colors.red;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.black54,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
