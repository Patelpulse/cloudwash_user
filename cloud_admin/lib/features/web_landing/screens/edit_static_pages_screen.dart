import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_admin/core/config/app_config.dart';
import 'package:cloud_admin/core/utils/image_data_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class EditStaticPagesScreen extends ConsumerStatefulWidget {
  const EditStaticPagesScreen({super.key});

  @override
  ConsumerState<EditStaticPagesScreen> createState() =>
      _EditStaticPagesScreenState();
}

class _StaticPagePreset {
  final String slug;
  final String label;
  final String title;
  final String subtitle;
  final String body;

  const _StaticPagePreset({
    required this.slug,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.body,
  });
}

class _EditStaticPagesScreenState extends ConsumerState<EditStaticPagesScreen> {
  final _formKey = GlobalKey<FormState>();

  static const List<_StaticPagePreset> _presets = [
    _StaticPagePreset(
      slug: 'terms',
      label: 'Terms & Conditions',
      title: 'Terms & Conditions',
      subtitle: 'Last Updated: April 2026',
      body:
          'Welcome to Cloud Wash. By using our website and app, you agree to these terms.\n\n'
          '- Bookings are subject to professional availability.\n'
          '- Cancellation fees may apply for late cancellations.\n'
          '- Payments are processed securely.\n'
          '- Cloud Wash is not liable for damages caused during service delivery.',
    ),
    _StaticPagePreset(
      slug: 'privacy',
      label: 'Privacy Policy',
      title: 'Privacy Policy',
      subtitle: 'Last Updated: April 2026',
      body:
          'Your privacy is important to us. This policy outlines how we collect, use, and protect your data.\n\n'
          '- We collect your name, phone number, and address to deliver services.\n'
          '- Location data is used to match you with nearby professionals.\n'
          '- We use industry-standard encryption to protect personal information.\n'
          '- We do not sell your data to third parties.',
    ),
    _StaticPagePreset(
      slug: 'child-protection',
      label: 'Child Protection',
      title: 'Child Protection Policy',
      subtitle: 'Last Updated: April 2026',
      body:
          'At Cloud Wash, the safety and well-being of children are a priority.\n\n'
          '- All professionals undergo identity verification and background checks.\n'
          '- Service professionals are trained to interact respectfully in homes where children are present.\n'
          '- We do not knowingly collect personal information from children under 18.\n'
          '- Report any safety concern to our support team immediately.',
    ),
    _StaticPagePreset(
      slug: 'help',
      label: 'Help & Support',
      title: 'Help & Support',
      subtitle: 'Last Updated: April 2026',
      body:
          'Need help with your order, account, or service? Our support team is here for you.\n\n'
          '- Email us for quick assistance.\n'
          '- Use the website contact form for service issues.\n'
          '- Check your booking status in your account dashboard.\n'
          '- Reach out for cancellations, rescheduling, or special requests.',
    ),
    _StaticPagePreset(
      slug: 'refund-policy',
      label: 'Refund Policy',
      title: 'Refund Policy',
      subtitle: 'Last Updated: April 2026',
      body:
          'Our refund policy is designed to be fair and transparent.\n\n'
          '- Refunds are considered for eligible prepaid cancellations.\n'
          '- Service quality issues should be reported within 24 hours.\n'
          '- Refunds may take 5-7 business days to process.\n'
          '- Certain service fees may be non-refundable after dispatch.',
    ),
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _imageUrlController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageMimeType;

  String _selectedSlug = _presets.first.slug;
  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _bodyController = TextEditingController();
    _imageUrlController = TextEditingController();
    _loadPage();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  _StaticPagePreset _currentPreset() {
    return _presets.firstWhere((preset) => preset.slug == _selectedSlug);
  }

  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final preset = _currentPreset();

      final apiData = await _loadPageFromApi();
      final firestoreData = await _loadPageFromFirestore();
      final data = <String, dynamic>{
        'title': preset.title,
        'subtitle': preset.subtitle,
        'body': preset.body,
        'imageUrl': '',
        'isActive': true,
        ...?firestoreData,
        ...?apiData,
      };

      _titleController.text = (data['title'] ?? preset.title).toString().trim();
      _subtitleController.text =
          (data['subtitle'] ?? preset.subtitle).toString().trim();
      _bodyController.text =
          (data['body'] ?? data['content'] ?? preset.body).toString().trim();
      _imageUrlController.text = (data['imageUrl'] ?? '').toString().trim();
      if (!mounted) return;
      setState(() {
        final activeValue = data['isActive'];
        _isActive = activeValue is bool
            ? activeValue
            : activeValue != null &&
                activeValue.toString().trim().toLowerCase() == 'true';
        _selectedImageBytes = null;
        _selectedImageMimeType = null;
      });
    } catch (e) {
      _errorMessage = 'Failed to load page: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageMimeType = pickedFile.mimeType;
    });
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageMimeType = null;
    });
  }

  String? _selectedImageDataUrl() {
    if (_selectedImageBytes == null) return null;
    final mimeType = (_selectedImageMimeType ?? 'image/png').trim();
    final normalizedMimeType = mimeType.contains('/')
        ? mimeType
        : 'image/png';
    return 'data:$normalizedMimeType;base64,${base64Encode(_selectedImageBytes!)}';
  }

  Future<Map<String, dynamic>?> _loadPageFromApi() async {
    try {
      final response = await http.get(
        AppConfig.apiUri(
          'web-content/pages/$_selectedSlug',
          queryParameters: {
            'ts': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadPageFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('web_landing')
          .doc('page_$_selectedSlug')
          .get();
      final data = doc.data();
      if (data == null || data.isEmpty) return null;
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = <String, dynamic>{
        'slug': _selectedSlug,
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'body': _bodyController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'isActive': _isActive,
      };

      final apiSaved = await _savePageToApi(payload);
      var firestoreSaved = false;
      if (apiSaved == null) {
        final firestorePayload = Map<String, dynamic>.from(payload);
        final fallbackImageUrl = _selectedImageDataUrl();
        if (fallbackImageUrl != null && fallbackImageUrl.isNotEmpty) {
          firestorePayload['imageUrl'] = fallbackImageUrl;
        }
        firestoreSaved = await _savePageToFirestore(firestorePayload);
      }

      if (apiSaved == null && !firestoreSaved) {
        throw Exception('Failed to save static page to backend');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Page saved successfully')),
      );
      await _loadPage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Map<String, dynamic>?> _savePageToApi(
    Map<String, dynamic> payload,
  ) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        AppConfig.apiUri('web-content/pages/$_selectedSlug'),
      );
      request.fields['slug'] = _selectedSlug;
      request.fields['title'] = payload['title']?.toString() ?? '';
      request.fields['subtitle'] = payload['subtitle']?.toString() ?? '';
      request.fields['body'] = payload['body']?.toString() ?? '';
      request.fields['content'] = payload['body']?.toString() ?? '';
      request.fields['imageUrl'] = payload['imageUrl']?.toString() ?? '';
      request.fields['isActive'] = payload['isActive'].toString();

      if (_selectedImageBytes != null) {
        final mimeParts = (_selectedImageMimeType ?? 'image/png').split('/');
        final mediaType = mimeParts.length == 2
            ? MediaType(mimeParts[0], mimeParts[1])
            : MediaType('image', 'png');
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _selectedImageBytes!,
            filename: 'static_page_image.png',
            contentType: mediaType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return payload;
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _savePageToFirestore(Map<String, dynamic> payload) async {
    try {
      await FirebaseFirestore.instance
          .collection('web_landing')
          .doc('page_$_selectedSlug')
          .set(
        {
          ...payload,
          'content': payload['body'],
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Static Pages'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadPage,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<String>(
                      value: _selectedSlug,
                      decoration: const InputDecoration(
                        labelText: 'Page Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _presets
                          .map(
                            (preset) => DropdownMenuItem<String>(
                              value: preset.slug,
                              child: Text(preset.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null || value == _selectedSlug) return;
                        setState(() => _selectedSlug = value);
                        _loadPage();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      minLines: 10,
                      maxLines: 18,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        helperText:
                            'Use blank lines between paragraphs and - for bullet points.',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Content is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      subtitle: const Text('Show this page content on website'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Page'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    final imageUrl = _imageUrlController.text.trim();
    final hasSelectedImage = _selectedImageBytes != null;
    final decodedImageBytes =
        !hasSelectedImage && isDataImageUrl(imageUrl)
            ? decodeDataImage(imageUrl)
            : null;

    Widget previewChild;
    if (hasSelectedImage) {
      previewChild = Image.memory(
        _selectedImageBytes!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    } else if (decodedImageBytes != null) {
      previewChild = Image.memory(
        decodedImageBytes,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.isNotEmpty) {
      previewChild = Image.network(
        imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 220,
          color: Colors.grey.shade100,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      );
    } else {
      previewChild = Container(
        width: double.infinity,
        height: 220,
        color: Colors.grey.shade100,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, size: 42, color: Colors.grey),
              SizedBox(height: 8),
              Text('No image selected'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Page Image (optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: previewChild,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Image'),
            ),
            OutlinedButton.icon(
              onPressed: hasSelectedImage ? _clearSelectedImage : null,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Selected Image'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'Image URL fallback (optional)',
            hintText: 'Used if no uploaded image is selected',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
