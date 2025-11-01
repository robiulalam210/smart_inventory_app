import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_inventory/feature/products/groups/presentation/pages/create_groups.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_sizes.dart';
import '../../data/model/groups.dart';
import '../bloc/groups/groups_bloc.dart';


class GroupsCard extends StatefulWidget {
  final GroupsModel group;
  final int index;

  const GroupsCard({super.key, required this.group, required this.index});

  @override
  State<GroupsCard> createState() => _GroupsCardState();
}

class _GroupsCardState extends State<GroupsCard> {
  // late AdvancedSwitchController _controller;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize the switch controller based on the warehouse status (assumes status is an int)
  //   _controller = AdvancedSwitchController(widget.group.status == 1);
  //
  //   _controller.addListener(() {
  //     setState(() {
  //       // Perform actions when the switch state changes
  //       final isActive = _controller.value;
  //       widget.group.status = isActive ? 1 : 0; // Update with int values
  //       Map<String, String> body = {
  //         "status":widget.group.status.toString()
  //       };
  //       context.read<GroupsBloc>().add(
  //           UpdateSwitchGroups(body: body, id: widget.group.id.toString()));
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: AppColors.linearGradient),
          child: Text(
            widget.index.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          widget.group.name ?? "N/A",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // AdvancedSwitch(
                //   activeColor: Colors.green,
                //   inactiveColor: Colors.red,
                //   borderRadius: BorderRadius.circular(5),
                //   width: 65,
                //   height: 30,
                //   controller: _controller,
                // ),
                IconButton(
                  onPressed: () {
                    context.read<GroupsBloc>().nameController.text =
                        widget.group.name ?? "";
                    // context.read<GroupsBloc>().selectedState =
                    //     widget.group.status.toString() == "1"
                    //         ? "Active"
                    //         : "Inactive";
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: SizedBox(
                            width: AppSizes.width(context)*0.50,
                            child: GroupsCreate(
                              id: widget.group.id.toString(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Iconsax.edit,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
