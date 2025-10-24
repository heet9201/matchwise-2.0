import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/ai_engine/content_detector.dart';
import '../../../../core/common_widgets/loading_widgets.dart';

class UploadInputScreen extends StatefulWidget {
  const UploadInputScreen({Key? key}) : super(key: key);

  @override
  State<UploadInputScreen> createState() => _UploadInputScreenState();
}

class _UploadInputScreenState extends State<UploadInputScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  String? _selectedFileName;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedFileTypes,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _processContent() async {
    setState(() => _isProcessing = true);

    // Simulate file processing
    await Future.delayed(const Duration(seconds: 2));

    final detector = ContentDetector();
    final detectionResult = await detector.detectContentType(
      _textController.text.isNotEmpty
          ? _textController.text
          : 'Sample content from $_selectedFileName',
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      context.push(
        RouteNames.detection,
        extra: {'detectedContent': detectionResult},
      );
    }
  }

  bool get _canContinue {
    return (_selectedFileName != null || _textController.text.isNotEmpty) &&
        !_isProcessing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Upload Document'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Upload File'),
            Tab(text: 'Paste Text'),
            Tab(text: 'Manual Entry'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUploadTab(),
                _buildPasteTextTab(),
                _buildManualEntryTab(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload Your Document',
            style: AppTypography.h3(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Support for PDF, Word, Image, Text, CSV (max ${(AppConstants.maxFileSize / (1024 * 1024)).toInt()}MB)',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            dashPattern: const [8, 4],
            color: AppColors.primaryGreen,
            strokeWidth: 2,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primaryGreenOverlay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedFileName != null
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          size: 64,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFileName ?? 'Click to upload or drag & drop',
                          style: AppTypography.h5(color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFileName != null
                              ? 'File selected successfully'
                              : 'PDF, DOCX, JPG, PNG, TXT, CSV',
                          style: AppTypography.small(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_selectedFileName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file,
                      color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: AppTypography.body(color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _selectedFileName = null),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasteTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Paste Your Content',
            style: AppTypography.h3(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste your resume, job description, biodata, or any other text',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            maxLines: 15,
            decoration: InputDecoration(
              hintText: 'Paste your content here...',
              hintStyle: AppTypography.body(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.cardBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Manual Entry',
            style: AppTypography.h3(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the fields manually (Coming soon)',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Icon(
              Icons.construction,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Manual entry form coming soon',
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
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
          onPressed: _canContinue ? _processContent : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessing
              ? const InlineLoadingIndicator(size: 20)
              : Text(
                  'Continue',
                  style: AppTypography.buttonLarge(color: AppColors.textWhite),
                ),
        ),
      ),
    );
  }
}
