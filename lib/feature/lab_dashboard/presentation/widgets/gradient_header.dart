// import 'package:aura_box/aura_box.dart';
// import 'package:dokani_360/blocs/blocs.dart';
// import 'package:flutter/material.dart';
//
//
//
// class GradientHeader extends StatelessWidget {
//   const GradientHeader({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     String greeting() {
//       var hour = DateTime.now().hour;
//       if (hour < 12) {
//         return 'Morning';
//       }
//       if (hour < 17) {
//         return 'Afternoon';
//       }
//       return 'Evening';
//     }
//
//     return AuraBox(
//             spots: [
//               AuraSpot(
//                 color: Colors.orangeAccent,
//                 radius: 500,
//                 alignment: const Alignment(0, 0.1),
//                 blurRadius: 50,
//               ),
//               AuraSpot(
//                 color: const Color.fromARGB(255, 251, 148, 255),
//                 radius: 400,
//                 alignment: const Alignment(0,-0.7),
//                 blurRadius: 500,
//               ),
//               AuraSpot(
//                 color:  Colors.orange,
//                 radius: 400,
//                 alignment: const Alignment(-0.5, -1.2),
//                 blurRadius: 50,
//               ),
//             ],
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             child: Container(
//               width: double.infinity,
//               height:  Responsive.isMobile(context)? AppSizes.height(context)*0.12:AppSizes.height(context)*0.16,
//               padding: const EdgeInsets.all(12.0),
//               child:  Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Hello, ${context.read<ProfileBloc>().profileModel.userName??" "} \nGood ${greeting()}',
//                     style:  TextStyle(
//                       color: Colors.white,
//                       fontSize: Responsive.isMobile(context)? 16:20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//
//                 ],
//               ),
//             ),
//           );
//
//   }
//
//
// }
