import 'package:flutter_typeahead/flutter_typeahead.dart';
import '/feature/lab_billing/data/models/common_model.dart';

import 'package:intl/intl.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/utilities/app_date_time.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_input_widgets.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../data/models/doctors_model/doctor_model.dart';
import '../../../data/models/patient_model/patient_model.dart';
import '../../bloc/blood_group_bloc/blood_group_bloc.dart';
import '../../bloc/doctor_bloc/doctor_bloc.dart';
import '../../bloc/gender_bloc/gender_bloc.dart';
import '../../bloc/lab_billing/lab_billing_bloc.dart';
import '../../bloc/patient_bloc/patient_bloc.dart';
import '../../bloc/patient_bloc/patient_state.dart';
import '../visit_type_toggle/visit_type_toggle.dart';

class PatientInfoSection extends StatefulWidget {
  const PatientInfoSection({super.key});

  @override
  State<PatientInfoSection> createState() => _PatientInfoSectionState();
}

class _PatientInfoSectionState extends State<PatientInfoSection> {
  late final LabBillingBloc labBillingBloc;

  void setPhone(String? phone) {
    final newValue = phoneCountryController(phone)?.value ??
        PhoneNumber(isoCode: IsoCode.BD, nsn: '');
    labBillingBloc.phoneCController.value = newValue;
  }

  @override
  void initState() {
    super.initState();
    labBillingBloc = context.read<LabBillingBloc>();
    labBillingBloc.phoneCController = phoneCountryController('') ??
        PhoneController(
            initialValue: PhoneNumber(isoCode: IsoCode.BD, nsn: ''));
  }

  void _calculateAge(DateTime dob) {
    try {
      final now = DateTime.now();
      int years = now.year - dob.year;
      int months = now.month - dob.month;
      int days = now.day - dob.day;

      // Adjust for negative days
      if (days < 0) {
        months -= 1;
        days += DateTime(now.year, now.month, 0).day;
      }

      // Adjust for negative months
      if (months < 0) {
        years -= 1;
        months += 12;
      }

      // Update the UI fields
      labBillingBloc.yearController.text = years.toString();
      labBillingBloc.monthController.text = months.toString();
      labBillingBloc.dayController.text = days.toString();

      // Format the date consistently
      labBillingBloc.dobController.text = DateFormat('dd-MM-yyyy').format(dob);
    } catch (e) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Error calculating age: ${e.toString()}',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );

      // Fallback: Clear age fields if calculation fails
      labBillingBloc.yearController.clear();
      labBillingBloc.monthController.clear();
      labBillingBloc.dayController.clear();
    }
  }

  /// Safely calculates DOB from Age
  void _calculateDOB() {
    try {
      final now = DateTime.now();
      final years = int.tryParse(labBillingBloc.yearController.text) ?? 0;
      final months = int.tryParse(labBillingBloc.monthController.text) ?? 0;
      final days = int.tryParse(labBillingBloc.dayController.text) ?? 0;

      // Return if no age information is provided
      if (years == 0 && months == 0 && days == 0) {
        labBillingBloc.dobController.clear();
        return;
      }

      // Calculate DOB by subtracting years, then months, then days
      DateTime dob = DateTime(now.year - years, now.month, now.day);

      // Adjust for months
      if (months > 0) {
        dob = DateTime(dob.year, dob.month - months, dob.day);

        // Handle year wrap-around if we went negative on months
        if (dob.month > now.month) {
          dob = DateTime(dob.year - 1, dob.month + 12, dob.day);
        }
      }

      // Adjust for days
      if (days > 0) {
        dob = dob.subtract(Duration(days: days));

        // Special handling for cases where the day doesn't exist in the month
        if (dob.day != now.day - days) {
          // Move to last day of previous month if needed
          dob = DateTime(dob.year, dob.month + 1, 0);
        }
      }

      // Format and set the DOB
      labBillingBloc.dobController.text = DateFormat('dd-MM-yyyy').format(dob);
    } catch (e) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Error calculating DOB: ${e.toString()}',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );

      // Clear the DOB field if calculation fails
      labBillingBloc.dobController.clear();
    }
  }

  Future<void> _selectDate() async {
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        _calculateAge(picked);
      }
    } catch (e) {
      if (!mounted) return; // ✅ This will work

      showCustomToast(
        context: context,
        title: 'Warning!',
        description: 'Error selecting date: ${e.toString()}',
        type: ToastificationType.warning,
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.bg,
        padding: EdgeInsets.zero,
        child: BlocBuilder<LabBillingBloc, LabBillingState>(
            builder: (context, state) {
          return Column(
            children: [
              ResponsiveRow(
                spacing: 0.0,
                children: [
                  ResponsiveCol(
                    xs: 12,
                    sm: 12,
                    md: 8,
                    lg: 8,
                    xl: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                        color: AppColors.whiteColor,
                        borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusSize),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingInside,
                          vertical: AppSizes.paddingInside),
                      margin: EdgeInsets.all(AppSizes.paddingInside / 2),
                      child: Column(
                        children: [
                          ResponsiveRow(
                            spacing: 5,
                            runSpacing: 0,
                            children: [
                              ResponsiveCol(
                                xs: 12,
                                sm: 3,
                                md: 3,
                                lg: 3,
                                xl: 3,
                                child: CustomInputField(
                                  controller: labBillingBloc.nameController,
                                  labelText: "Name",
                                  hintText: "Enter Name",
                                  keyboardType: TextInputType.name,
                                  isRequired: true,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? "Enter name"
                                      : null,
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 3,
                                md: 3,
                                lg: 3,
                                xl: 3,
                                child: AppPhoneFormField(
                                  controller: labBillingBloc.phoneCController,
                                  labelText: "Phone Number",
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 1,
                                md: 1,
                                lg: 1,
                                xl: 1,
                                child: CustomInputField(
                                  controller: labBillingBloc.yearController,
                                  hintText: "Age",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  isRequired: true,
                                  onChanged: (value) => _calculateDOB(),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? "Enter age"
                                      : null,
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 1,
                                md: 1,
                                lg: 1,
                                xl: 1,
                                child: CustomInputField(
                                  controller: labBillingBloc.monthController,
                                  hintText: "Month",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) => _calculateDOB(),
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 1,
                                md: 1,
                                lg: 1,
                                xl: 1,
                                child: CustomInputField(
                                  controller: labBillingBloc.dayController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  hintText: "Day",
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => _calculateDOB(),
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 2,
                                md: 2,
                                lg: 2,
                                xl: 2,
                                child: CustomInputField(
                                  controller: labBillingBloc.dobController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  hintText: "Date of Birth",
                                  keyboardType: TextInputType.datetime,
                                  onTap: () => _selectDate(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ResponsiveRow(
                            spacing: 8,
                            runSpacing: 5,
                            children: [
                              ResponsiveCol(
                                xs: 12,
                                sm: 3,
                                md: 3,
                                lg: 3,
                                xl: 3,
                                child: BlocBuilder<GenderBloc, GenderState>(
                                  builder: (context, state) {
                                    if (state is GenderLoaded) {
                                      return AppDropdown<GenderLocalModel>(
                                        isRequired: true,
                                        label: 'Gender',
                                        hint: labBillingBloc.gender == null
                                            ? 'Select Gender'
                                            : labBillingBloc.gender?.name ?? "",
                                        itemList: state.genders,
                                        onChanged: (val) => setState(
                                            () => labBillingBloc.gender = val),
                                        itemBuilder: (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item.name ?? "")),
                                        context: context,
                                      );
                                    } else if (state is GenderError) {
                                      return Text('Error: ${state.message}');
                                    }
                                    return const CircularProgressIndicator();
                                  },
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 3,
                                md: 3,
                                lg: 3,
                                xl: 3,
                                child: BlocBuilder<BloodGroupBloc,
                                    BloodGroupState>(
                                  builder: (context, state) {
                                    if (state is BloodGroupLoaded) {
                                      return AppDropdown<BloodGroupLocalModel>(
                                        context: context,
                                        label: 'Blood Group',
                                        hint: labBillingBloc.bloodGroup == null
                                            ? 'Select Blood Group'
                                            : labBillingBloc.bloodGroup?.name ??
                                                "",
                                        itemList: state.bloodGroups,
                                        onChanged: (val) => setState(() =>
                                            labBillingBloc.bloodGroup = val),
                                        itemBuilder: (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item.name ?? "")),
                                      );
                                    } else if (state is BloodGroupError) {
                                      return Text('Error: ${state.message}');
                                    }
                                    return const CircularProgressIndicator();
                                  },
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 2,
                                md: 2,
                                lg: 2,
                                xl: 2,
                                child: VisitTypeToggle(
                                  initialType: labBillingBloc.visitType,
                                  // Optional: default is "In"
                                  onChanged: (value) {
                                    setState(() {
                                      labBillingBloc.visitType = value;
                                    });
                                  },
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 3,
                                md: 3,
                                lg: 3,
                                xl: 3,
                                child: CustomInputField(
                                  controller: labBillingBloc.addressController,
                                  hintText: "Address",
                                  keyboardType: TextInputType.streetAddress,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ResponsiveCol(
                    xs: 12,
                    sm: 12,
                    md: 4,
                    lg: 4,
                    xl: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondaryLight,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusSize),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingInside,
                          vertical: AppSizes.paddingInside),
                      margin: EdgeInsets.all(AppSizes.paddingInside / 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          gapH8,
                          BlocBuilder<LabBillingBloc, LabBillingState>(
                            builder: (context, labState) {
                              return BlocBuilder<PatientBloc, PatientState>(
                                builder: (context, patientState) {
                                  final patients =
                                      context.read<PatientBloc>().patient ?? [];
                                  final labBillingBloc =
                                      context.read<LabBillingBloc>();

                                  void updatePatientFields(
                                      PatientLocalModel patient) {
                                    setState(() {
                                      labBillingBloc.patientModel = patient;
                                      labBillingBloc.nameController.text =
                                          patient.name;
                                      setPhone(patient.phone);
                                      final newControllerValue =
                                          phoneCountryController(patient.phone)
                                                  ?.value ??
                                              const PhoneNumber(
                                                  isoCode: IsoCode.BD, nsn: '');

                                      labBillingBloc.phoneCController.value =
                                          newControllerValue;

                                      labBillingBloc.dobController.text =
                                          patient.dob;
                                      labBillingBloc.visitType =
                                          patient.visitType;

                                      final genderMatch = context
                                          .read<GenderBloc>()
                                          .gender
                                          .firstWhere(
                                            (g) =>
                                                g.originalId.toString() ==
                                                patient.gender.toString(),
                                            orElse: () => GenderLocalModel(
                                                id: -1,
                                                name: '',
                                                originalId: null),
                                          );
                                      if (genderMatch.id != -1 &&
                                          genderMatch.originalId != null) {
                                        labBillingBloc.gender = genderMatch;
                                      }

                                      final bloodMatch = context
                                          .read<BloodGroupBloc>()
                                          .bloodList
                                          .firstWhere(
                                            (g) =>
                                                g.originalId.toString() ==
                                                patient.bloodGroup.toString(),
                                            orElse: () => BloodGroupLocalModel(
                                                id: -1,
                                                name: '',
                                                originalId: null),
                                          );
                                      if (bloodMatch.id != -1 &&
                                          bloodMatch.originalId != null) {
                                        labBillingBloc.bloodGroup = bloodMatch;
                                      }

                                      labBillingBloc.addressController.text =
                                          patient.address;

                                      final dob = tryParseDob(patient.dob);
                                      if (dob != null) {
                                        _calculateAge(dob);
                                      } else {
                                        showCustomToast(
                                          context: context,
                                          title: 'Warning!',
                                          description: 'Invalid DOB format.',
                                          type: ToastificationType.warning,
                                          icon: Icons.warning,
                                          primaryColor: Colors.orange,
                                        );
                                      }
                                    });
                                  }

                                  void clearPatientSelection() {
                                    setState(() {
                                      labBillingBloc.nameController.clear();

                                      labBillingBloc.phoneCController.value =
                                          const PhoneNumber(
                                              isoCode: IsoCode.BD, nsn: '');
                                      labBillingBloc.addressController.clear();
                                      labBillingBloc.yearController.clear();
                                      labBillingBloc.monthController.clear();
                                      labBillingBloc.dayController.clear();
                                      labBillingBloc.dobController.clear();
                                      labBillingBloc.gender = null;
                                      labBillingBloc.bloodGroup = null;
                                      labBillingBloc.patientModel = null;
                                      labBillingBloc.patientTypeAheadController
                                          .clear();
                                      labBillingBloc.visitType = "";
                                    });
                                  }

                                  List<T> searchAndSort<T>(
                                    List<T> list,
                                    String query,
                                    String Function(T) combineFields,
                                  ) {
                                    final lowerQuery =
                                        query.toLowerCase().trim();

                                    final matches = list.where((item) {
                                      final combined =
                                          combineFields(item).toLowerCase();
                                      return combined.contains(lowerQuery);
                                    }).toList();

                                    matches.sort((a, b) {
                                      final aName =
                                          combineFields(a).toLowerCase();
                                      final bName =
                                          combineFields(b).toLowerCase();

                                      final aStartsWith =
                                          aName.startsWith(lowerQuery) ? 0 : 1;
                                      final bStartsWith =
                                          bName.startsWith(lowerQuery) ? 0 : 1;

                                      if (aStartsWith == bStartsWith) {
                                        return aName.compareTo(bName);
                                      }
                                      return aStartsWith.compareTo(bStartsWith);
                                    });

                                    return matches;
                                  }

                                  return TypeAheadField<PatientLocalModel>(
                                    controller: labBillingBloc
                                        .patientTypeAheadController,
                                    focusNode: labBillingBloc.patientFocusNode,
                                    debounceDuration:
                                        const Duration(milliseconds: 300),
                                    direction: VerticalDirection.down,
                                    suggestionsCallback: (pattern) {
                                      return searchAndSort<PatientLocalModel>(
                                        patients
                                            .where((p) =>
                                                (p.name.isNotEmpty) ||
                                                p.name != "" ||
                                                (p.phone.isNotEmpty) ||
                                                (p.hnNumber.isNotEmpty))
                                            .toList(),
                                        pattern,
                                        (patient) =>
                                            '${patient.name} ${patient.phone} ${patient.hnNumber}',
                                      );
                                    },
                                    itemBuilder: (context, patient) {
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: AppSizes.bodyPadding,
                                              vertical: AppSizes.bodyPadding),
                                          color: AppColors.white
                                              .withValues(alpha: 0.6),
                                          // custom light background

                                          child:   Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 2, // give name more space
                                                  child: Text(
                                                    patient.name,
                                                    style: AppTextStyle.cardLevelText(context),
                                                    softWrap: true,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    patient.phone,
                                                    style: AppTextStyle.cardLevelText(context),
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ],
                                            )

                                        ),
                                      );
                                    },
                                    onSelected: (patient) {
                                      updatePatientFields(patient);
                                      labBillingBloc
                                              .patientTypeAheadController.text =
                                          patient.name; // ✅ Ensure text is set
                                      FocusScope.of(context).unfocus();
                                    },
                                    hideOnEmpty: true,
                                    hideOnError: true,
                                    hideOnLoading: true,
                                    builder: (context, controller, focusNode) {
                                      return StatefulBuilder(
                                        builder: (context, setStateField) {
                                          controller.addListener(() {
                                            // setStateField(() {});
                                          });

                                          return SizedBox(
                                            height: 35,
                                            child: TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 4.0,
                                                        bottom: 4.0,
                                                        left: 6),
                                                hintText: 'Search by Patient',
                                                hintStyle: TextStyle(
                                                  color: AppColors.matteBlack,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 14,
                                                ),
                                                suffixIcon: controller
                                                        .text.isNotEmpty
                                                    ? InkWell(
                                                        child: Icon(
                                                            Icons.clear_rounded,
                                                            size: 12),
                                                        onTap: () {
                                                          controller.clear();
                                                          clearPatientSelection();
                                                          focusNode
                                                              .requestFocus();
                                                          focusNode
                                                              .requestFocus();
                                                        },
                                                      )
                                                    : const Icon(
                                                        Icons.search_rounded,
                                                        size: 12,
                                                      ),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSizes.radius),
                                                    borderSide: BorderSide(
                                                        color: AppColors.error,
                                                        width: 0.7)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppSizes
                                                                        .radius),
                                                        borderSide: BorderSide(
                                                            color: AppColors
                                                                .matteBlack,
                                                            width: 0.7)),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes.radius),
                                                  borderSide: BorderSide(
                                                      color: AppColors.border,
                                                      width: 0.7),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppSizes.radius),
                                                  borderSide: BorderSide(
                                                      color: AppColors.error,
                                                      width: 0.7),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    constraints: BoxConstraints(
                                      maxHeight: 300,
                                      minWidth:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          gapH16,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                child: AppDropdown<String>(
                                  context: context,
                                  isLabel: false,
                                  hint: labBillingBloc.referredBy.isEmpty
                                      ? 'Select Referred'
                                      : labBillingBloc.referredBy,
                                  itemList: const ['Self', 'Doctor', 'Other'],
                                  onChanged: (value) {
                                    setState(() {
                                      labBillingBloc.referredBy = value!;
                                    });
                                  },
                                  itemBuilder: (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                  label: 'Referred By',
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (labBillingBloc.referredBy == "Doctor")
                                Expanded(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      BlocBuilder<DoctorBloc, DoctorState>(
                                        builder: (context, state) {
                                          final doctors = context
                                                  .read<DoctorBloc>()
                                                  .doctor ??
                                              [];
                                          final selectedDoctor =
                                              labBillingBloc.doctorModel;

                                          final controller =
                                              TextEditingController(
                                            text: selectedDoctor?.toString() ??
                                                '',
                                          );
                                          final focusNode = FocusNode();
                                          final showClearButton = ValueNotifier(
                                              controller.text.isNotEmpty);

                                          void clearSelection() {
                                            controller.clear();
                                            labBillingBloc.doctorModel = null;
                                            showClearButton.value = false;
                                            focusNode.requestFocus();
                                          }

                                          final TextEditingController
                                              doctorController =
                                              TextEditingController(
                                            text: labBillingBloc.doctorModel
                                                    ?.toString() ??
                                                '',
                                          );
                                          final FocusNode doctorFocusNode =
                                              FocusNode();

                                          return TypeAheadField<
                                              DoctorLocalModel>(
                                            controller: doctorController,
                                            focusNode: doctorFocusNode,
                                            debounceDuration: const Duration(
                                                milliseconds: 300),
                                            hideOnEmpty: true,
                                            hideOnError: true,
                                            hideOnSelect: true,
                                            hideOnLoading: true,
                                            suggestionsCallback:
                                                (pattern) async {
                                              final query =
                                                  pattern.toLowerCase();
                                              return doctors
                                                  .where((doctor) => doctor
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(query))
                                                  .toList();
                                            },
                                            itemBuilder: (context, doctor) {
                                              return MouseRegion(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppSizes.bodyPadding,
                                                      vertical:
                                                          AppSizes.bodyPadding),
                                                  color: AppColors.white
                                                      .withValues(alpha: 0.6),
                                                  // custom light background

                                                  child: Text(doctor.toString(),
                                                      style: AppTextStyle
                                                          .cardLevelText(
                                                              context)),
                                                ),
                                              );
                                            },
                                            onSelected: (doctor) {
                                              labBillingBloc.doctorModel =
                                                  doctor;
                                              doctorController.text =
                                                  doctor.toString();
                                            },
                                            builder: (context, controller,
                                                focusNode) {
                                              return StatefulBuilder(
                                                builder:
                                                    (context, setStateField) {
                                                  controller.addListener(() {
                                                    setStateField(
                                                        () {}); // Triggers suffixIcon update
                                                  });

                                                  return SizedBox(
                                                    height: 35,
                                                    child: TextField(
                                                      controller: controller,
                                                      focusNode: focusNode,
                                                      style: AppTextStyle
                                                          .cardLevelText(
                                                              context),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 4,
                                                                bottom: 4,
                                                                left: 6),
                                                        hintText:
                                                            'Search by Doctor',
                                                        hintStyle:
                                                            const TextStyle(
                                                          color: AppColors
                                                              .matteBlack,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 14,
                                                        ),
                                                        suffixIcon: controller
                                                                .text.isNotEmpty
                                                            ? InkWell(
                                                                child: const Icon(
                                                                    Icons
                                                                        .clear_rounded,
                                                                    size: 12),
                                                                onTap: () {
                                                                  controller
                                                                      .clear();
                                                                  clearSelection();
                                                                  labBillingBloc
                                                                          .doctorModel =
                                                                      null;
                                                                  focusNode
                                                                      .requestFocus();
                                                                },
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .search_rounded,
                                                                size: 12),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppSizes
                                                                          .radius),
                                                          borderSide: BorderSide(
                                                              color: AppColors
                                                                  .error,
                                                              width: 0.7),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppSizes
                                                                          .radius),
                                                          borderSide: BorderSide(
                                                              color: AppColors
                                                                  .matteBlack,
                                                              width: 0.7),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppSizes
                                                                          .radius),
                                                          borderSide: BorderSide(
                                                              color: AppColors
                                                                  .border,
                                                              width: 0.7),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppSizes
                                                                          .radius),
                                                          borderSide: BorderSide(
                                                              color: AppColors
                                                                  .error,
                                                              width: 0.7),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            constraints: BoxConstraints(
                                              maxHeight: 200,
                                              minWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              if (labBillingBloc.referredBy == "Other")
                                Expanded(
                                  child: CustomInputField(
                                    controller: labBillingBloc.otherController,
                                    hintText: "Enter Doctor Details",
                                    labelText: "Other Doctor Details",
                                    keyboardType: TextInputType.text,
                                    isRequired: true,
                                  ),
                                ),
                            ],
                          ),
                          gapH8,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }));
  }
}
