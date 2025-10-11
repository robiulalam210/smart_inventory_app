
import '../configs/configs.dart';

class CustomFilterBox extends StatelessWidget {
  final ValueChanged<TapDownDetails> onTapDown;
  final String hintText;

  const CustomFilterBox({super.key,
    required this.onTapDown,
    this.hintText = "Search",
  });

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTapDown: onTapDown,
      child: Container(
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 248, 248),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: const Color.fromARGB(38, 0, 0, 0),
              width: 0.3),
        ),
        child:  Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              const Icon(Iconsax.setting_54,
                  size: 18, color: AppColors.primaryColor),
              const SizedBox(
                width: 4,
              ),
              Text(
                "Filter",
               style:AppTextStyle.cardLevelHead(context)
              )
            ],
          ),
        ),
      ),
    );
  }
}
