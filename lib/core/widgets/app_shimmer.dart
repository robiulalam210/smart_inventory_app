

import 'package:shimmer/shimmer.dart';
import '../core.dart';


class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),
      itemCount: 5,
        itemBuilder: (_,i)=> Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Container(
                    width: AppSizes.width(context)*0.15,
                    height: AppSizes.height(context)*0.07,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                    ),
                  ),
                  const SizedBox(width: AppSizes.bodyPadding,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSizes.width(context)*0.5,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Container(
                        width: AppSizes.width(context)*0.4,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10,),

              Container(
                width: double.maxFinite,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                width: double.maxFinite,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                width: double.maxFinite,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                width: double.maxFinite,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
                ),
              ),
              const SizedBox(height: 10,),
              const SizedBox(height: AppSizes.bodyPadding,),
            ],
          ),
        )
    );

  }
}
