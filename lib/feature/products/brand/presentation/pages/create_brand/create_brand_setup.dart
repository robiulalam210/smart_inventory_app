import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/configs/app_routes.dart';
import '../../../../../../core/configs/app_sizes.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../bloc/brand/brand_bloc.dart';


final GlobalKey<FormState> formKey = GlobalKey<FormState>();

void setupBrand(
  BuildContext context,
  String title,
  String submitText, {
  String? id,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => AppRoutes.pop(context),
                            child: const Icon(Icons.close,
                                color: Colors.red, size: 22),
                          ),
                        ),
                        SizedBox(height: AppSizes.height(context) * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // appWidgets.textTitle(
                            //     title: title, isRequired: false),
                          ],
                        ),
                        SizedBox(
                          height: AppSizes.height(context) * 0.02,
                        ),
                        CustomInputField(
                          isRequiredLable: true,
                          isRequired: true,
                          controller:
                              context.read<BrandBloc>().nameController,
                          hintText: 'Brand Name',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.text,
                          autofillHints: AutofillHints.telephoneNumber,
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter Name ' : null;
                          },
                          onChanged: (value) {
                            return null;
                          },
                        ),


                        SizedBox(
                          height: AppSizes.height(context) * 0.03,
                        ),
                        AppButton(
                          name: submitText,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {

                              if(id.toString()==""){
                                Map<String, String> body = {
                                  "name": context
                                      .read<BrandBloc>()
                                      .nameController
                                      .text,
                                };
                                context
                                    .read<BrandBloc>()
                                    .add(AddBrand(body: body));
                              }else{
                                Map<String, String> body = {
                                  "name":   context.read<BrandBloc>().nameController.text,

                                };

                                context
                                    .read<BrandBloc>()
                                    .add(UpdateBrand(body: body,id: id.toString()));
                              }

                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
