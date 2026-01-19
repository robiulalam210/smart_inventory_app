import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/profile_perrmission_model.dart';
import '../../data/service/image_upload_service.dart';

/// Company profile card that can also upload company logo.
/// Uses ImageUploadService to avoid duplicating upload logic.
class CompanyProfileCardWithUpload extends StatefulWidget {
  final CompanyInfo? company;
  final VoidCallback? onUpdated;
  final bool allowPick; // whether pick/upload UI should be enabled

  const CompanyProfileCardWithUpload({
    super.key,
    required this.company,
    this.onUpdated,
    this.allowPick = true,
  });

  @override
  State<CompanyProfileCardWithUpload> createState() =>
      _CompanyProfileCardWithUploadState();
}

class _CompanyProfileCardWithUploadState
    extends State<CompanyProfileCardWithUpload> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _progress = 0.0;
  final ImageUploadService _uploadService = ImageUploadService();

  Future<void> _pickImageAndUpload(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null) return;
      final file = File(picked.path);
      await _uploadLogo(file);
    } catch (e, st) {
      debugPrint('Pick/upload failed: $e\n$st');
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'image_upload_failed'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    }
  }

  Future<void> _uploadLogo(File file) async {
    setState(() {
      _isUploading = true;
      _progress = 0.0;
    });

    final token = await LocalDB.getLoginInfo();
    if (token == null) {
      setState(() {
        _isUploading = false;
      });
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'auth_token_missing'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    final filename = p.basename(file.path);
    final form = FormData.fromMap({
      'logo': await MultipartFile.fromFile(file.path, filename: filename),
    });
    final url = '${AppUrls.baseUrlMain}/api/company/logo/';

    try {
      final resp = await _uploadService.uploadWithPatchFallback(
        url: url,
        token: token['token'],
        formData: form,
        onProgress: (sent, total) {
          if (total != -1) setState(() => _progress = sent / total);
        },
      );

      debugPrint('Company upload resp: ${resp?.statusCode} ${resp?.data}');

      if (resp != null &&
          resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300) {
        // Clear Flutter image cache so updated logo is fetched immediately
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        } catch (_) {}

        showCustomToast(
          context: context,
          title: 'success'.tr(),
          description: 'company_logo_updated'.tr(),
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
        widget.onUpdated?.call();
      } else {
        final msg = resp?.data != null && resp?.data['message'] != null
            ? resp?.data['message'].toString()
            : 'upload_failed'.tr();
        showCustomToast(
          context: context,
          title: 'error'.tr(),
          description: msg ?? 'upload_failed'.tr(),
          icon: Icons.error,
          primaryColor: Colors.red,
        );
      }
    } on DioError catch (e) {
      debugPrint(
        'Logo upload DioError: ${e.type} ${e.message} resp=${e.response?.statusCode} ${e.response?.data}',
      );
      final friendly = (e.response?.statusCode == 404)
          ? 'not_found_endpoint'.tr()
          : (e.message ?? 'image_upload_failed'.tr());
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: friendly,
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } catch (e, st) {
      debugPrint('Logo upload error: $e\n$st');
      showCustomToast(
        context: context,
        title: 'error'.tr(),
        description: 'image_upload_failed'.tr(),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    } finally {
      setState(() {
        _isUploading = false;
        _progress = 0.0;
      });
    }
  }

  Future<void> _showImagePickerOptions({required bool allowCompanyLogo}) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('choose_from_gallery'.tr()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageAndUpload(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('take_photo'.tr()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageAndUpload(ImageSource.camera);
                },
              ),
              if (allowCompanyLogo) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: Text('update_company_logo'.tr()),
                  subtitle: Text('update_company_logo_desc'.tr()),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImageAndUpload(ImageSource.gallery);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    if (company == null) return const SizedBox.shrink();

    // Build URL with a cache-busting query param that changes when company.logo string changes.
    String? logoUrl;
    if (company.logo != null && company.logo.toString().isNotEmpty) {
      final logoStr = company.logo.toString();
      final sep = logoStr.contains('?') ? '&' : '?';
      logoUrl = '${AppUrls.baseUrlMain}$logoStr${sep}v=${logoStr.hashCode}';
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.greyColor(context).withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Company Information",style: AppTextStyle.bodyLarge(context),),
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.allowPick
                          ? () =>
                                _showImagePickerOptions(allowCompanyLogo: true)
                          : null,
                      child: CircleAvatar(
                        key: ValueKey(company.logo ?? ''),
                        radius: 30,
                        backgroundColor: AppColors.primaryColor(
                          context,
                        ).withValues(alpha: 0.1),
                        backgroundImage: (logoUrl != null)
                            ? NetworkImage(logoUrl)
                            : null,
                        child: (logoUrl == null)
                            ? Text(
                                company.name?.substring(0, 1).toUpperCase() ??
                                    '',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor(context),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        company.name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                // _infoRow('Trade License', company.tradeLicense, context),
                _infoRow('Company Code', company.companyCode, context),

                _infoRow('Phone', company.phone, context),
                _infoRow('Email', company.email, context),
                _infoRow('Plan Type', company.planType, context),
                _infoRow(
                  'Status',
                  company.isActive == true ? 'Active' : 'Inactive',
                  context,
                ),
                // _infoRow('Website', company.website, context),
                _infoRow('Address', company.address, context),

              ],
            ),
          ),

          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(value: _progress),
                            const Icon(
                              Icons.cloud_upload,
                              size: 32,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_progress * 100).toStringAsFixed(0)} %',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value, BuildContext context) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(child: Text(': $value', style: AppTextStyle.body(context))),
        ],
      ),
    );
  }
}
