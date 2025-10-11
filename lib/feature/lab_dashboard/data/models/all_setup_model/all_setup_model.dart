import 'dart:convert';

import '../../../../../core/utilities/app_date_time.dart';

AllSetupModel allSetupModelFromJson(String str) =>
    AllSetupModel.fromJson(json.decode(str));

String allSetupModelToJson(AllSetupModel data) => json.encode(data.toJson());

class AllSetupModel {
  final SetupData? data;
  final String? message;
  final int? statusCode;

  AllSetupModel({
    this.data,
    this.message,
    this.statusCode,
  });

  factory AllSetupModel.fromJson(Map<String, dynamic> json) => AllSetupModel(
        data: json["data"] == null ? null : SetupData.fromJson(json["data"]),
        message: json["message"],
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "message": message,
        "status_code": statusCode,
      };
}


class SetupData {
  final List<SetupPatient>? patient;
  final List<SetupGender>? gender;
  final List<SetupBloodGroup>? bloodGroup;
  final List<SetupInventoryAllSetup>? inventories;
  final List<SetupTestName>? testName;
  final List<SetupDoctor>? doctors;
  final List<SetupTestCategory>? testCategory;
  final List<SetupParameter>? parameterSetup;
  final List<SetupParameterGroup>? parameterGroupSetup;
  final List<SetupTestParameter>? testParameterSetup;
  final List<SetupTestNameConfig>? testNameConfigSetup;
  final List<SetupBooth>? booths;
  final List<SetupCollector>? collectorInfo;
  final PrintLayout? printLayout;
  final List<SetupSpecimen>? specimen;
  final List<SetupTestGroup>? testGroup;
  final List<SetupCaseEffect>? caseEffect;
  final List<SetupMarketer>? marketerList;


  SetupData({
    this.patient,
    this.gender,
    this.bloodGroup,
    this.inventories,
    this.testName,
    this.doctors,
    this.testCategory,
    this.parameterSetup,
    this.parameterGroupSetup,
    this.testParameterSetup,
    this.testNameConfigSetup,
    this.booths,
    this.collectorInfo,
    this.printLayout,
    this.specimen,
    this.testGroup,
    this.caseEffect,
    this.marketerList,
  });

  factory SetupData.fromJson(Map<String, dynamic> json) => SetupData(
    patient: json["patient"] == null
        ? []
        : List<SetupPatient>.from(
        json["patient"]!.map((x) => SetupPatient.fromJson(x))),
    gender: json["gender"] == null
        ? []
        : List<SetupGender>.from(
        json["gender"]!.map((x) => SetupGender.fromJson(x))),
    bloodGroup: json["blood_group"] == null
        ? []
        : List<SetupBloodGroup>.from(
        json["blood_group"]!.map((x) => SetupBloodGroup.fromJson(x))),
    inventories: json["inventories"] == null
        ? []
        : List<SetupInventoryAllSetup>.from(json["inventories"]!
        .map((x) => SetupInventoryAllSetup.fromJson(x))),
    testName: json["test_name"] == null
        ? []
        : List<SetupTestName>.from(
        json["test_name"]!.map((x) => SetupTestName.fromJson(x))),
    doctors: json["doctors"] == null
        ? []
        : List<SetupDoctor>.from(
        json["doctors"]!.map((x) => SetupDoctor.fromJson(x))),
    testCategory: json["test_category"] == null
        ? []
        : List<SetupTestCategory>.from(json["test_category"]!
        .map((x) => SetupTestCategory.fromJson(x))),
    parameterSetup: json["parameter"] == null
        ? []
        : List<SetupParameter>.from(
        json["parameter"]!.map((x) => SetupParameter.fromJson(x))),
    parameterGroupSetup: json["parameterGroup"] == null
        ? []
        : List<SetupParameterGroup>.from(json["parameterGroup"]!
        .map((x) => SetupParameterGroup.fromJson(x))),
    testParameterSetup: json["testParameter"] == null
        ? []
        : List<SetupTestParameter>.from(json["testParameter"]!
        .map((x) => SetupTestParameter.fromJson(x))),
    testNameConfigSetup: json["testNameConfig"] == null
        ? []
        : List<SetupTestNameConfig>.from(json["testNameConfig"]!
        .map((x) => SetupTestNameConfig.fromJson(x))),
    booths: json["booths"] == null
        ? []
        : List<SetupBooth>.from(
        json["booths"]!.map((x) => SetupBooth.fromJson(x))),
    collectorInfo: json["collectorInfo"] == null
        ? []
        : List<SetupCollector>.from(
        json["collectorInfo"]!.map((x) => SetupCollector.fromJson(x))),
    printLayout: json["printLayout"] == null
        ? null
        : PrintLayout.fromJson(json["printLayout"]),
    specimen: json["specimen"] == null // 🆕
        ? []
        : List<SetupSpecimen>.from(
        json["specimen"]!.map((x) => SetupSpecimen.fromJson(x))),
    testGroup: json["test_group"] == null // 🆕
        ? []
        : List<SetupTestGroup>.from(
        json["test_group"]!.map((x) => SetupTestGroup.fromJson(x))),

    caseEffect: json["caseEffect"] == null
        ? []
        : List<SetupCaseEffect>.from(
        json["caseEffect"].map((x) => SetupCaseEffect.fromJson(x))),
    marketerList: json["marketerList"] == null
        ? []
        : List<SetupMarketer>.from(
        json["marketerList"].map((x) => SetupMarketer.fromJson(x))),

  );

  Map<String, dynamic> toJson() => {
    "patient": patient == null
        ? []
        : List<dynamic>.from(patient!.map((x) => x.toJson())),
    "gender": gender == null
        ? []
        : List<dynamic>.from(gender!.map((x) => x.toJson())),
    "blood_group": bloodGroup == null
        ? []
        : List<dynamic>.from(bloodGroup!.map((x) => x.toJson())),
    "inventories": inventories == null
        ? []
        : List<dynamic>.from(inventories!.map((x) => x.toJson())),
    "test_name": testName == null
        ? []
        : List<dynamic>.from(testName!.map((x) => x.toJson())),
    "doctors": doctors == null
        ? []
        : List<dynamic>.from(doctors!.map((x) => x.toJson())),
    "test_category": testCategory == null
        ? []
        : List<dynamic>.from(testCategory!.map((x) => x.toJson())),
    "parameter": parameterSetup == null
        ? []
        : List<dynamic>.from(parameterSetup!.map((x) => x.toJson())),
    "parameterGroup": parameterGroupSetup == null
        ? []
        : List<dynamic>.from(parameterGroupSetup!.map((x) => x.toJson())),
    "testParameter": testParameterSetup == null
        ? []
        : List<dynamic>.from(testParameterSetup!.map((x) => x.toJson())),
    "testNameConfig": testNameConfigSetup == null
        ? []
        : List<dynamic>.from(testNameConfigSetup!.map((x) => x.toJson())),
    "booths": booths == null
        ? []
        : List<dynamic>.from(booths!.map((x) => x.toJson())),
    "collectorInfo": collectorInfo == null
        ? []
        : List<dynamic>.from(collectorInfo!.map((x) => x.toJson())),
    "printLayout": printLayout?.toJson(),
    "specimen": specimen == null // 🆕
        ? []
        : List<dynamic>.from(specimen!.map((x) => x.toJson())),
    "test_group": testGroup == null // 🆕
        ? []
        : List<dynamic>.from(testGroup!.map((x) => x.toJson())),
    "caseEffect": caseEffect == null
        ? []
        : List<dynamic>.from(caseEffect!.map((x) => x.toJson())),
    "marketerList": marketerList == null
        ? []
        : List<dynamic>.from(marketerList!.map((x) => x.toJson())),

  };
}
class SetupPatient {
  final int? id;
  final String? patientHnNumber;
  final String? patientFirstName;
  final dynamic patientMiddleName;
  final dynamic patientLastName;
  final String? patientBirthSexId;
  final String? patientDob;
  final String? patientMobilePhone;
  final String? patientAddress1;
  final String? age;
  final String? month;
  final String? day;
  final String? visitType;
  final String? ptnBloodGroupId;
  final DateTime? createdAt;
  final String? fullName;

  SetupPatient({
    this.id,
    this.patientHnNumber,
    this.patientFirstName,
    this.patientMiddleName,
    this.patientLastName,
    this.patientBirthSexId,
    this.patientDob,
    this.patientMobilePhone,
    this.patientAddress1,
    this.age,
    this.month,
    this.day,
    this.visitType,
    this.ptnBloodGroupId,
    this.createdAt,
    this.fullName,
  });

  factory SetupPatient.fromJson(Map<String, dynamic> json) => SetupPatient(
        id: json["id"],
        patientHnNumber: json["patient_hn_number"],
        patientFirstName: json["patient_first_name"],
        patientMiddleName: json["patient_middle_name"],
        patientLastName: json["patient_last_name"],
        patientBirthSexId: json["patient_birth_sex_id"],
        patientDob: json["patient_dob"],
        patientMobilePhone: json["patient_mobile_phone"],
        patientAddress1: json["patient_address1"],
        age: json["age"],
        month: json["month"],
        day: json["day"],
        visitType: json["visit_type"],
        ptnBloodGroupId: json["ptn_blood_group_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        fullName: json["fullName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patient_hn_number": patientHnNumber,
        "patient_first_name": patientFirstName,
        "patient_middle_name": patientMiddleName,
        "patient_last_name": patientLastName,
        "patient_birth_sex_id": patientBirthSexId,
        "patient_dob": patientDob,
        "patient_mobile_phone": patientMobilePhone,
        "patient_address1": patientAddress1,
        "age": age,
        "month": month,
        "day": day,
        "visit_type": visitType,
        "ptn_blood_group_id": ptnBloodGroupId,
        "created_at": createdAt?.toIso8601String(),
        "fullName": fullName,
      };
}

class SetupBloodGroup {
  final int? id;
  final String? bloodGroupName;

  SetupBloodGroup({
    this.id,
    this.bloodGroupName,
  });

  factory SetupBloodGroup.fromJson(Map<String, dynamic> json) =>
      SetupBloodGroup(
        id: json["id"],
        bloodGroupName: json["blood_group_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "blood_group_name": bloodGroupName,
      };
}

class SetupDoctor {
  final int? id;
  final int? saasBranchId;
  final String? saasBranchName;
  final String? drIdentityNo;
  final Title? title;
  final String? departmentId;
  final String? specialistsId;
  final dynamic departmentName;
  final String? drFamilyName;
  final String? drGivenName;
  final String? drMiddleName;
  final String? drLastName;
  final String? drPreferredName;
  final String? drAbout;
  final String? workExperienceYears;
  final String? drAddressLine1;
  final String? drAddressLine2;
  final String? drBmdcRegNo;
  final String? drEmail;
  final dynamic drIsReferred;
  final DateTime? drDob;
  final String? drBirthSexId;
  final String? drCityId;
  final String? drPostalCode;
  final String? drHomePhone;
  final String? drWorkPhone;
  final String? drMobilePhone;
  final String? drContactViaId;
  final String? drProviderId;
  final String? drImages;
  final String? doctorFee;
  final dynamic appToken;
  final String? deleteStatus;
  final dynamic createdBy;
  final dynamic updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fullName;
  final SetupGender? birthSex;
  final UsualProvider? usualProvider;
  final Department? department;
  final Specialist? specialist;
  final List<Academic>? academic;

  SetupDoctor({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.drIdentityNo,
    this.title,
    this.departmentId,
    this.specialistsId,
    this.departmentName,
    this.drFamilyName,
    this.drGivenName,
    this.drMiddleName,
    this.drLastName,
    this.drPreferredName,
    this.drAbout,
    this.workExperienceYears,
    this.drAddressLine1,
    this.drAddressLine2,
    this.drBmdcRegNo,
    this.drEmail,
    this.drIsReferred,
    this.drDob,
    this.drBirthSexId,
    this.drCityId,
    this.drPostalCode,
    this.drHomePhone,
    this.drWorkPhone,
    this.drMobilePhone,
    this.drContactViaId,
    this.drProviderId,
    this.drImages,
    this.doctorFee,
    this.appToken,
    this.deleteStatus,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.birthSex,
    this.usualProvider,
    this.department,
    this.specialist,
    this.academic,
  });

  factory SetupDoctor.fromJson(Map<String, dynamic> json) => SetupDoctor(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        drIdentityNo: json["dr_identity_no"],
        title: json["title"] == null ? null : Title.fromJson(json["title"]),
        departmentId: json["department_id"],
        specialistsId: json["specialists_id"],
        departmentName: json["department_name"],
        drFamilyName: json["dr_family_name"],
        drGivenName: json["dr_given_name"],
        drMiddleName: json["dr_middle_name"],
        drLastName: json["dr_last_name"],
        drPreferredName: json["dr_preferred_name"],
        drAbout: json["dr_about"],
        workExperienceYears: json["work_experience_years"],
        drAddressLine1: json["dr_address_line_1"],
        drAddressLine2: json["dr_address_line_2"],
        drBmdcRegNo: json["dr_bmdc_reg_no"],
        drEmail: json["dr_email"],
        drIsReferred: json["dr_is_referred"],
        drDob: json["dr_dob"] == null ? null : parseCustomDate(json["dr_dob"]),
        drBirthSexId: json["dr_birth_sex_id"],
        drCityId: json["dr_city_id"],
        drPostalCode: json["dr_postal_code"],
        drHomePhone: json["dr_home_phone"],
        drWorkPhone: json["dr_work_phone"],
        drMobilePhone: json["dr_mobile_phone"],
        drContactViaId: json["dr_contact_via_id"],
        drProviderId: json["dr_provider_id"],
        drImages: json["dr_images"],
        doctorFee: json["doctor_fee"],
        appToken: json["app_token"],
        deleteStatus: json["delete_status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        fullName: json["fullName"],
        birthSex: json["birth_sex"] == null
            ? null
            : SetupGender.fromJson(json["birth_sex"]),
        usualProvider: json["usual_provider"] == null
            ? null
            : UsualProvider.fromJson(json["usual_provider"]),
        department: json["department"] == null
            ? null
            : Department.fromJson(json["department"]),
        specialist: json["specialist"] == null
            ? null
            : Specialist.fromJson(json["specialist"]),
        academic: json["academic"] == null
            ? []
            : List<Academic>.from(
                json["academic"]!.map((x) => Academic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "dr_identity_no": drIdentityNo,
        "title": title?.toJson(),
        "department_id": departmentId,
        "specialists_id": specialistsId,
        "department_name": departmentName,
        "dr_family_name": drFamilyName,
        "dr_given_name": drGivenName,
        "dr_middle_name": drMiddleName,
        "dr_last_name": drLastName,
        "dr_preferred_name": drPreferredName,
        "dr_about": drAbout,
        "work_experience_years": workExperienceYears,
        "dr_address_line_1": drAddressLine1,
        "dr_address_line_2": drAddressLine2,
        "dr_bmdc_reg_no": drBmdcRegNo,
        "dr_email": drEmail,
        "dr_is_referred": drIsReferred,
        "dr_dob": drDob?.toIso8601String(),
        "dr_birth_sex_id": drBirthSexId,
        "dr_city_id": drCityId,
        "dr_postal_code": drPostalCode,
        "dr_home_phone": drHomePhone,
        "dr_work_phone": drWorkPhone,
        "dr_mobile_phone": drMobilePhone,
        "dr_contact_via_id": drContactViaId,
        "dr_provider_id": drProviderId,
        "dr_images": drImages,
        "doctor_fee": doctorFee,
        "app_token": appToken,
        "delete_status": deleteStatus,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "fullName": fullName,
        "birth_sex": birthSex?.toJson(),
        "usual_provider": usualProvider?.toJson(),
        "department": department?.toJson(),
        "specialist": specialist?.toJson(),
        "academic": academic == null
            ? []
            : List<dynamic>.from(academic!.map((x) => x.toJson())),
      };
}

class Academic {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? doctorsMasterId;
  final String? degreeId;
  final String? passingYear;
  final String? result;
  final String? institutionId;
  final String? countryId;
  final String? cityId;
  final String? scanCopy;
  final String? scanCopyTitle;
  final int? deleteStatus;
  final dynamic createdBy;
  final dynamic updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? inistitution;
  final List<Country>? country;

  Academic({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.doctorsMasterId,
    this.degreeId,
    this.passingYear,
    this.result,
    this.institutionId,
    this.countryId,
    this.cityId,
    this.scanCopy,
    this.scanCopyTitle,
    this.deleteStatus,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.inistitution,
    this.country,
  });

  factory Academic.fromJson(Map<String, dynamic> json) => Academic(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        doctorsMasterId: json["doctors_master_id"],
        degreeId: json["degree_id"],
        passingYear: json["passing_year"],
        result: json["result"],
        institutionId: json["institution_id"],
        countryId: json["country_id"],
        cityId: json["city_id"],
        scanCopy: json["scan_copy"],
        scanCopyTitle: json["scan_copy_title"],
        deleteStatus: json["delete_status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        inistitution: json["inistitution"] == null
            ? []
            : List<dynamic>.from(json["inistitution"]!.map((x) => x)),
        country: json["country"] == null
            ? []
            : List<Country>.from(
                json["country"]!.map((x) => Country.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "doctors_master_id": doctorsMasterId,
        "degree_id": degreeId,
        "passing_year": passingYear,
        "result": result,
        "institution_id": institutionId,
        "country_id": countryId,
        "city_id": cityId,
        "scan_copy": scanCopy,
        "scan_copy_title": scanCopyTitle,
        "delete_status": deleteStatus,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "inistitution": inistitution == null
            ? []
            : List<dynamic>.from(inistitution!.map((x) => x)),
        "country": country == null
            ? []
            : List<dynamic>.from(country!.map((x) => x.toJson())),
      };
}

class Country {
  final int? id;
  final String? countryName;

  Country({
    this.id,
    this.countryName,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        countryName: json["country_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "country_name": countryName,
      };
}

class SetupGender {
  final int? id;
  final String? birthSexName;

  SetupGender({
    this.id,
    this.birthSexName,
  });

  factory SetupGender.fromJson(Map<String, dynamic> json) => SetupGender(
        id: json["id"],
        birthSexName: json["birth_sex_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "birth_sex_name": birthSexName,
      };
}

class Department {
  final int? id;
  final String? departmentsName;

  Department({
    this.id,
    this.departmentsName,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json["id"],
        departmentsName: json["departments_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "departments_name": departmentsName,
      };
}

class Specialist {
  final int? id;
  final String? specialistsName;

  Specialist({
    this.id,
    this.specialistsName,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) => Specialist(
        id: json["id"],
        specialistsName: json["specialists_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "specialists_name": specialistsName,
      };
}

class Title {
  final int? id;
  final String? titleName;

  Title({
    this.id,
    this.titleName,
  });

  factory Title.fromJson(Map<String, dynamic> json) => Title(
        id: json["id"],
        titleName: json["title_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title_name": titleName,
      };
}

class UsualProvider {
  final int? id;
  final String? usualProviderName;
  final dynamic address;
  final dynamic mobile;
  final dynamic phone;
  final dynamic email;

  UsualProvider({
    this.id,
    this.usualProviderName,
    this.address,
    this.mobile,
    this.phone,
    this.email,
  });

  factory UsualProvider.fromJson(Map<String, dynamic> json) => UsualProvider(
        id: json["id"],
        usualProviderName: json["usual_provider_name"],
        address: json["address"],
        mobile: json["mobile"],
        phone: json["phone"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "usual_provider_name": usualProviderName,
        "address": address,
        "mobile": mobile,
        "phone": phone,
        "email": email,
      };
}

class SetupInventoryAllSetup {
  final int? id;
  final String? itemCode;
  final String? name;
  final dynamic mrp;

  SetupInventoryAllSetup({
    this.id,
    this.itemCode,
    this.name,
    this.mrp,
  });

  factory SetupInventoryAllSetup.fromJson(Map<String, dynamic> json) =>
      SetupInventoryAllSetup(
        id: json["id"],
        itemCode: json["item_code"],
        name: json["name"],
        mrp: json["mrp"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "item_code": itemCode,
        "name": name,
        "mrp": mrp,
      };
}

class SetupTestCategory {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? testGroupId;
  final String? testCategoryName;
  final dynamic createdAt;
  final dynamic updatedAt;
  final Group? testGroup;

  SetupTestCategory({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.testGroupId,
    this.testCategoryName,
    this.createdAt,
    this.updatedAt,
    this.testGroup,
  });

  factory SetupTestCategory.fromJson(Map<String, dynamic> json) =>
      SetupTestCategory(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        testGroupId: json["test_group_id"],
        testCategoryName: json["test_category_name"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        testGroup: json["test_group"] == null
            ? null
            : Group.fromJson(json["test_group"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "test_group_id": testGroupId,
        "test_category_name": testCategoryName,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "test_group": testGroup?.toJson(),
      };
}

class Group {
  final int? id;
  final String? testGroupName;

  Group({
    this.id,
    this.testGroupName,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"],
        testGroupName: json["test_group_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "test_group_name": testGroupName,
      };
}

class SetupTestName {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? testGroupId;
  final String? testCategoryId;
  final String? testSubCategoryId;
  final String? specimenId;
  final String? testName;
  final String? fee;
  final String? testParameter;
  final String? accountsId;
  final String? accountsTypeId;
  final String? accountsGroupId;
  final dynamic createdAt;
  final dynamic updatedAt;
  final dynamic parameterGroupId;
  final int? discountApplied;
  final dynamic discount;
  final int? hideTestName;
  final String? itemCode;
  final Category? category;
  final Group? group;
  final SubCategory? subCategory;
  final List<Parameter>? parameter;
  final Accounts? accounts;
  final AccountsGroup? accountsGroup;
  final Accounts? accountsType;

  SetupTestName({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.testGroupId,
    this.testCategoryId,
    this.testSubCategoryId,
    this.specimenId,
    this.testName,
    this.fee,
    this.testParameter,
    this.accountsId,
    this.accountsTypeId,
    this.accountsGroupId,
    this.createdAt,
    this.updatedAt,
    this.parameterGroupId,
    this.discountApplied,
    this.discount,
    this.hideTestName,
    this.itemCode,
    this.category,
    this.group,
    this.subCategory,
    this.parameter,
    this.accounts,
    this.accountsGroup,
    this.accountsType,
  });

  factory SetupTestName.fromJson(Map<String, dynamic> json) => SetupTestName(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        testGroupId: json["test_group_id"],
        testCategoryId: json["test_category_id"],
        testSubCategoryId: json["test_sub_category_id"],
        specimenId: json["specimen_id"],
        testName: json["test_name"],
        fee: json["fee"],
        testParameter: json["test_parameter"],
        accountsId: json["accounts_id"],
        accountsTypeId: json["accounts_type_id"],
        accountsGroupId: json["accounts_group_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        parameterGroupId: json["parameter_group_id"],
        discountApplied: json["discount_applied"],
        discount: json["discount"],
        hideTestName: json["hide_test_name"],
        itemCode: json["item_code"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        group: json["group"] == null ? null : Group.fromJson(json["group"]),
        subCategory: json["sub_category"] == null
            ? null
            : SubCategory.fromJson(json["sub_category"]),
        parameter: json["parameter"] == null
            ? []
            : List<Parameter>.from(
                json["parameter"]!.map((x) => Parameter.fromJson(x))),
        accounts: json["accounts"] == null
            ? null
            : Accounts.fromJson(json["accounts"]),
        accountsGroup: json["accounts_group"] == null
            ? null
            : AccountsGroup.fromJson(json["accounts_group"]),
        accountsType: json["accounts_type"] == null
            ? null
            : Accounts.fromJson(json["accounts_type"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "test_group_id": testGroupId,
        "test_category_id": testCategoryId,
        "test_sub_category_id": testSubCategoryId,
        "specimen_id": specimenId,
        "test_name": testName,
        "fee": fee,
        "test_parameter": testParameter,
        "accounts_id": accountsId,
        "accounts_type_id": accountsTypeId,
        "accounts_group_id": accountsGroupId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "parameter_group_id": parameterGroupId,
        "discount_applied": discountApplied,
        "discount": discount,
        "hide_test_name": hideTestName,
        "item_code": itemCode,
        "category": category?.toJson(),
        "group": group?.toJson(),
        "sub_category": subCategory?.toJson(),
        "parameter": parameter == null
            ? []
            : List<dynamic>.from(parameter!.map((x) => x.toJson())),
        "accounts": accounts?.toJson(),
        "accounts_group": accountsGroup?.toJson(),
        "accounts_type": accountsType?.toJson(),
      };
}

class Accounts {
  final int? id;
  final String? name;

  Accounts({
    this.id,
    this.name,
  });

  factory Accounts.fromJson(Map<String, dynamic> json) => Accounts(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class AccountsGroup {
  final int? id;
  final String? feeName;

  AccountsGroup({
    this.id,
    this.feeName,
  });

  factory AccountsGroup.fromJson(Map<String, dynamic> json) => AccountsGroup(
        id: json["id"],
        feeName: json["fee_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fee_name": feeName,
      };
}

class Category {
  final int? id;
  final String? testCategoryName;

  Category({
    this.id,
    this.testCategoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        testCategoryName: json["test_category_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "test_category_name": testCategoryName,
      };
}

class Parameter {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? testId;
  final String? parameterName;
  final String? parameterUnit;
  final String? referenceValue;
  final int? showOptions;
  final String? options;
  final String? parameterGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ParameterValue>? parameterValue;
  final ParameterConfig? parameterConfig;

  Parameter({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.testId,
    this.parameterName,
    this.parameterUnit,
    this.referenceValue,
    this.showOptions,
    this.options,
    this.parameterGroupId,
    this.createdAt,
    this.updatedAt,
    this.parameterValue,
    this.parameterConfig,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) => Parameter(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        testId: json["test_id"],
        parameterName: json["parameter_name"],
        parameterUnit: json["parameter_unit"],
        referenceValue: json["reference_value"],
        showOptions: json["show_options"],
        options: json["options"],
        parameterGroupId: json["parameter_group_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        parameterValue: json["parameter_value"] == null
            ? []
            : List<ParameterValue>.from(json["parameter_value"]!
                .map((x) => ParameterValue.fromJson(x))),
        parameterConfig: json["parameter_config"] == null
            ? null
            : ParameterConfig.fromJson(json["parameter_config"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "test_id": testId,
        "parameter_name": parameterName,
        "parameter_unit": parameterUnit,
        "reference_value": referenceValue,
        "show_options": showOptions,
        "options": options,
        "parameter_group_id": parameterGroupId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "parameter_value": parameterValue == null
            ? []
            : List<dynamic>.from(parameterValue!.map((x) => x.toJson())),
        "parameter_config": parameterConfig?.toJson(),
      };
}

class ParameterConfig {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final int? testNameId;
  final int? parameterId;
  final String? childLowerValue;
  final String? childUpperValue;
  final String? childNormalValue;
  final String? maleLowerValue;
  final String? maleUpperValue;
  final String? maleNormalValue;
  final String? femaleLowerValue;
  final String? femaleUpperValue;
  final String? femaleNormalValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParameterConfig({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.testNameId,
    this.parameterId,
    this.childLowerValue,
    this.childUpperValue,
    this.childNormalValue,
    this.maleLowerValue,
    this.maleUpperValue,
    this.maleNormalValue,
    this.femaleLowerValue,
    this.femaleUpperValue,
    this.femaleNormalValue,
    this.createdAt,
    this.updatedAt,
  });

  factory ParameterConfig.fromJson(Map<String, dynamic> json) =>
      ParameterConfig(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        testNameId: json["test_name_id"],
        parameterId: json["parameter_id"],
        childLowerValue: json["child_lower_value"],
        childUpperValue: json["child_upper_value"],
        childNormalValue: json["child_normal_value"],
        maleLowerValue: json["male_lower_value"],
        maleUpperValue: json["male_upper_value"],
        maleNormalValue: json["male_normal_value"],
        femaleLowerValue: json["female_lower_value"],
        femaleUpperValue: json["female_upper_value"],
        femaleNormalValue: json["female_normal_value"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "test_name_id": testNameId,
        "parameter_id": parameterId,
        "child_lower_value": childLowerValue,
        "child_upper_value": childUpperValue,
        "child_normal_value": childNormalValue,
        "male_lower_value": maleLowerValue,
        "male_upper_value": maleUpperValue,
        "male_normal_value": maleNormalValue,
        "female_lower_value": femaleLowerValue,
        "female_upper_value": femaleUpperValue,
        "female_normal_value": femaleNormalValue,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class ParameterValue {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? parameter;
  final String? gender;
  final String? minimumAge;
  final String? maximumAge;
  final String? lowerValue;
  final String? upperValue;
  final String? normalValue;
  final dynamic inWords;
  final String? testNameId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParameterValue({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.parameter,
    this.gender,
    this.minimumAge,
    this.maximumAge,
    this.lowerValue,
    this.upperValue,
    this.normalValue,
    this.inWords,
    this.testNameId,
    this.createdAt,
    this.updatedAt,
  });

  factory ParameterValue.fromJson(Map<String, dynamic> json) => ParameterValue(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        parameter: json["parameter"],
        gender: json["gender"],
        minimumAge: json["minimum_age"],
        maximumAge: json["maximum_age"],
        lowerValue: json["lower_value"],
        upperValue: json["upper_value"],
        normalValue: json["normal_value"],
        inWords: json["in_words"],
        testNameId: json["test_name_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "parameter": parameter,
        "gender": gender,
        "minimum_age": minimumAge,
        "maximum_age": maximumAge,
        "lower_value": lowerValue,
        "upper_value": upperValue,
        "normal_value": normalValue,
        "in_words": inWords,
        "test_name_id": testNameId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class SubCategory {
  final int? id;
  final String? testSubCategoryName;

  SubCategory({
    this.id,
    this.testSubCategoryName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        id: json["id"],
        testSubCategoryName: json["test_sub_category_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "test_sub_category_name": testSubCategoryName,
      };
}

// ------------------- Parameter Setup -------------------
class SetupParameter {
  final int? id;
  final int? testId;
  final String? parameterName;
  final String? parameterUnit;
  final String? referenceValue;
  final int? showOptions;
  final String? options;
  final int? parameterGroupId;
  final String? createdAt;
  final String? updatedAt;

  SetupParameter({
    this.id,
    this.testId,
    this.parameterName,
    this.parameterUnit,
    this.referenceValue,
    this.showOptions = 0,
    this.options,
    this.parameterGroupId,
    this.createdAt,
    this.updatedAt,
  });

  factory SetupParameter.fromJson(Map<String, dynamic> json) => SetupParameter(
        id: json["id"],
        testId: int.tryParse(json["test_id"].toString()) ?? 0,
        parameterName: json["parameter_name"] ?? "",
        parameterUnit: json["parameter_unit"],
        referenceValue: json["reference_value"],
        showOptions: int.tryParse(json["show_options"].toString()) ?? 0,
        options: json["options"],
        parameterGroupId: json["parameter_group_id"] != null
            ? int.tryParse(json["parameter_group_id"].toString())
            : null,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "test_id": testId,
        "parameter_name": parameterName,
        "parameter_unit": parameterUnit,
        "reference_value": referenceValue,
        "show_options": showOptions,
        "options": options,
        "parameter_group_id": parameterGroupId,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

// ------------------- Parameter Group Setup -------------------
class SetupParameterGroup {
  final int? id;
  final int? testNameId;
  final String? groupName;
  final int? hidden;
  final String? createdAt;
  final String? updatedAt;

  SetupParameterGroup({
    this.id,
    this.testNameId,
    this.groupName,
    this.hidden,
    this.createdAt,
    this.updatedAt,
  });

  factory SetupParameterGroup.fromJson(Map<String, dynamic> json) =>
      SetupParameterGroup(
        id: json["id"],
        testNameId: int.tryParse(json["test_name_id"].toString()) ?? 0,
        groupName: json["group_name"] ?? "",
        hidden: int.tryParse(json["hidden"].toString()) ?? 0,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "test_name_id": testNameId,
        "group_name": groupName,
        "hidden": hidden,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

// ------------------- Test Parameter Group Setup -------------------

class SetupTestParameter {
  final int id;
  final int parameterId;
  final String? gender;
  final int? minimumAge;
  final int? maximumAge;
  final String? lowerValue;
  final String? upperValue;
  final String? normalValue;
  final String? inWords;
  final int testNameId;
  final String? createdAt;
  final String? updatedAt;

  SetupTestParameter({
    required this.id,
    required this.parameterId,
    this.gender,
    this.minimumAge,
    this.maximumAge,
    this.lowerValue,
    this.upperValue,
    this.normalValue,
    this.inWords,
    required this.testNameId,
    this.createdAt,
    this.updatedAt,
  });

  factory SetupTestParameter.fromJson(Map<String, dynamic> json) =>
      SetupTestParameter(
        id: json["id"],
        parameterId: int.tryParse(json["parameter"].toString()) ?? 0,
        gender: json["gender"],
        minimumAge: int.tryParse(json["minimum_age"].toString()),
        maximumAge: int.tryParse(json["maximum_age"].toString()),
        lowerValue: json["lower_value"],
        upperValue: json["upper_value"],
        normalValue: json["normal_value"],
        inWords: json["in_words"],
        testNameId: int.tryParse(json["test_name_id"].toString()) ?? 0,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parameter_id": parameterId,
        "gender": gender,
        "minimum_age": minimumAge,
        "maximum_age": maximumAge,
        "lower_value": lowerValue,
        "upper_value": upperValue,
        "normal_value": normalValue,
        "in_words": inWords,
        "test_name_id": testNameId,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

// ------------------- Test Name Config Setup -------------------
class SetupTestNameConfig {
  final int? id;
  final int? testNameId;
  final int? parameterId;
  final String? childLowerValue;
  final String? childUpperValue;
  final String? childNormalValue;
  final String? maleLowerValue;
  final String? maleUpperValue;
  final String? maleNormalValue;
  final String? femaleLowerValue;
  final String? femaleUpperValue;
  final String? femaleNormalValue;
  final String? createdAt;
  final String? updatedAt;

  SetupTestNameConfig({
    this.id,
    this.testNameId,
    this.parameterId,
    this.childLowerValue,
    this.childUpperValue,
    this.childNormalValue,
    this.maleLowerValue,
    this.maleUpperValue,
    this.maleNormalValue,
    this.femaleLowerValue,
    this.femaleUpperValue,
    this.femaleNormalValue,
    this.createdAt,
    this.updatedAt,
  });

  factory SetupTestNameConfig.fromJson(Map<String, dynamic> json) =>
      SetupTestNameConfig(
        id: json["id"],
        testNameId: json["test_name_id"],
        parameterId: json["parameter_id"],
        childLowerValue: json["child_lower_value"],
        childUpperValue: json["child_upper_value"],
        childNormalValue: json["child_normal_value"],
        maleLowerValue: json["male_lower_value"],
        maleUpperValue: json["male_upper_value"],
        maleNormalValue: json["male_normal_value"],
        femaleLowerValue: json["female_lower_value"],
        femaleUpperValue: json["female_upper_value"],
        femaleNormalValue: json["female_normal_value"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "test_name_id": testNameId,
        "parameter_id": parameterId,
        "child_lower_value": childLowerValue,
        "child_upper_value": childUpperValue,
        "child_normal_value": childNormalValue,
        "male_lower_value": maleLowerValue,
        "male_upper_value": maleUpperValue,
        "male_normal_value": maleNormalValue,
        "female_lower_value": femaleLowerValue,
        "female_upper_value": femaleUpperValue,
        "female_normal_value": femaleNormalValue,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

// ------------------- Booths -------------------

class SetupBooth {
  final int? id;
  final int? saasBranchId;
  final String? saasBranchName;
  final int? branchId;
  final String? name;
  final String? boothNo;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  SetupBooth({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.branchId,
    this.name,
    this.boothNo,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SetupBooth.fromJson(Map<String, dynamic> json) => SetupBooth(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        branchId: json["branch_id"],
        name: json["name"],
        boothNo: json["booth_no"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "branch_id": branchId,
        "name": name,
        "booth_no": boothNo,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

// ------------------- Collector Info -------------------
class SetupCollector {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final int? saasBranchId;
  final String? saasBranchName;
  final String? address;
  final String? createdAt;
  final String? updatedAt;

  SetupCollector({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.saasBranchId,
    this.saasBranchName,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory SetupCollector.fromJson(Map<String, dynamic> json) => SetupCollector(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        address: json["address"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "address": address,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

// ------------------- Print Layout -------------------
class PrintLayout {
  final int? id;
  final String? layoutName;
  final String? pageSize;
  final String? orientation;
  final String? billing; // JSON string
  final String? letter; // JSON string
  final String? sticker; // JSON string
  final String? createdAt;
  final String? updatedAt;

  PrintLayout({
    this.id,
    this.layoutName,
    this.pageSize,
    this.orientation,
    this.billing,
    this.letter,
    this.sticker,
    this.createdAt,
    this.updatedAt,
  });

  factory PrintLayout.fromJson(Map<String, dynamic> json) => PrintLayout(
        id: json["id"],
        layoutName: json["layout_name"],
        pageSize: json["page_size"],
        orientation: json["orientation"],
        billing: json["billing"],
        letter: json["letter"],
    sticker: json["sticker"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "layout_name": layoutName,
        "page_size": pageSize,
        "orientation": orientation,
        "billing": billing,
        "letter": letter,
        "sticker": sticker,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
class SetupSpecimen {
  final int id;
  final String? saasBranchId;
  final String? saasBranchName;
  final String name;
  final String createdAt;
  final String updatedAt;

  SetupSpecimen({
    required this.id,
    this.saasBranchId,
    this.saasBranchName,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SetupSpecimen.fromJson(Map<String, dynamic> json) => SetupSpecimen(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    name: json["name"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "name": name,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class SetupTestGroup {
  final int id;
  final String? saasBranchId;
  final String? saasBranchName;
  final String testGroupName;
  final String createdAt;
  final String updatedAt;

  SetupTestGroup({
    required this.id,
    this.saasBranchId,
    this.saasBranchName,
    required this.testGroupName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SetupTestGroup.fromJson(Map<String, dynamic> json) => SetupTestGroup(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    testGroupName: json["test_group_name"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "test_group_name": testGroupName,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class SetupCaseEffect {
  final int? id;
  final int? moneyReceiptId;
  final String? amount;

  SetupCaseEffect({this.id, this.moneyReceiptId, this.amount});

  factory SetupCaseEffect.fromJson(Map<String, dynamic> json) => SetupCaseEffect(
    id: json["id"],
    moneyReceiptId: json["money_receipt_id"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "money_receipt_id": moneyReceiptId,
    "amount": amount,
  };
}

class MarketerGroup {
  final int? id;
  final String? name;

  MarketerGroup({this.id, this.name});

  factory MarketerGroup.fromJson(Map<String, dynamic> json) => MarketerGroup(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class SetupMarketer {
  final int? id;
  final String? name;
  final String? marketerId;
  final int? marketerGroupId;
  final String? phone;
  final String? email;
  final String? address;
  final MarketerGroup? group;

  SetupMarketer({
    this.id,
    this.name,
    this.marketerId,
    this.marketerGroupId,
    this.phone,
    this.email,
    this.address,
    this.group,
  });

  factory SetupMarketer.fromJson(Map<String, dynamic> json) => SetupMarketer(
    id: json["id"],
    name: json["name"],
    marketerId: json["marketer_id"],
    marketerGroupId: json["marketer_group_id"],
    phone: json["phone"],
    email: json["email"],
    address: json["address"],
    group: json["group"] == null
        ? null
        : MarketerGroup.fromJson(json["group"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "marketer_id": marketerId,
    "marketer_group_id": marketerGroupId,
    "phone": phone,
    "email": email,
    "address": address,
    "group": group?.toJson(),
  };
}