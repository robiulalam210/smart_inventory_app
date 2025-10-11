import 'package:cached_network_image/cached_network_image.dart';

import '../core.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({super.key, required this.imageUrl, this.icon, this.height, this.iconSize});
  final String imageUrl;
  final IconData? icon;
  final double? height,iconSize;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height ?? 30,
      width: height ?? 30,
      fit: BoxFit.cover,
      imageUrl: imageUrl,
      placeholder: (context, url) => Icon(icon ?? Iconsax.airplane, size: iconSize??16,),
      errorWidget: (context, url, error) => Icon(icon ?? Iconsax.airplane,size: iconSize??16,),
    );
  }
}