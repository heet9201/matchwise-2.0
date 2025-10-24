import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/domain_types.dart';
import '../../../../core/router/route_names.dart';

class ComparisonUploadScreen extends StatefulWidget {
  final ComparisonTarget? comparisonType;
  final Map<String, dynamic>? userProfile;

  const ComparisonUploadScreen({
    Key? key,
    this.comparisonType,
    this.userProfile,
  }) : super(key: key);

  @override
  State<ComparisonUploadScreen> createState() => _ComparisonUploadScreenState();
}

class _ComparisonUploadScreenState extends State<ComparisonUploadScreen> {
  final List<String> _uploadedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedFileTypes,
    );

    if (result != null) {
      setState(() {
        _uploadedFiles.addAll(result.files.map((f) => f.name));
      });
    }
  }

  void _removeFile(int index) {
    setState(() => _uploadedFiles.removeAt(index));
  }

  void _proceedToComparison() {
    if (_uploadedFiles.isEmpty) return;

    // Mock comparison items data
    final comparisonItems = List.generate(_uploadedFiles.length, (index) {
      return {
        'id': 'item_$index',
        'title': _uploadedFiles[index],
        'skills': ['Python', 'JavaScript', 'React', 'AWS'],
        'experience': {'min': 3, 'max': 7},
        'education': 'Bachelor\'s Degree',
        'location': 'Remote',
        'salary': {'min': 100000, 'max': 150000},
      };
    });

    context.push(
      RouteNames.processing,
      extra: {
        'userProfile': widget.userProfile ?? {},
        'comparisonItems': comparisonItems,
        'domainType': DomainType.job,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Upload Comparison Items'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Now Upload What You Want to Compare With',
                    style: AppTypography.h3(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can upload multiple files at once (up to ${AppConstants.maxComparisonItems})',
                    style: AppTypography.body(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildUploadZone(),
                  const SizedBox(height: 16),
                  if (_uploadedFiles.isNotEmpty) _buildFileList(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      dashPattern: const [8, 4],
      color: AppColors.primaryGreen,
      strokeWidth: 2,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primaryGreenOverlay,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickFiles,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _uploadedFiles.isEmpty
                        ? Icons.cloud_upload_outlined
                        : Icons.add_circle_outline,
                    size: 48,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _uploadedFiles.isEmpty
                        ? 'Click to upload files'
                        : 'Add more files',
                    style: AppTypography.h5(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_uploadedFiles.length}/${AppConstants.maxComparisonItems} files uploaded',
                    style: AppTypography.small(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Files',
          style: AppTypography.h5(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _uploadedFiles.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _uploadedFiles[index],
                      style: AppTypography.body(color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removeFile(index),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _uploadedFiles.isEmpty ? null : _proceedToComparison,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _uploadedFiles.isEmpty
                ? 'Upload at least 1 file'
                : 'Compare ${_uploadedFiles.length} Items →',
            style: AppTypography.buttonLarge(color: AppColors.textWhite),
          ),
        ),
      ),
    );
  }
}
