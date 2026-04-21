import 'package:dio/dio.dart';
import 'package:cloud_admin/core/config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_admin/features/web_landing/models/hero_section_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class EditHeroSectionScreen extends ConsumerStatefulWidget {
  const EditHeroSectionScreen({super.key});

  @override
  ConsumerState<EditHeroSectionScreen> createState() =>
      _EditHeroSectionScreenState();
}

class _EditHeroSectionScreenState extends ConsumerState<EditHeroSectionScreen> {
  /// Must match backend `multer` `fileSize` for `/api/hero` image field.
  static const int _heroImageMaxBytes = 10 * 1024 * 1024;

  static const List<String> _fontFamilies = <String>[
    'Playfair Display',
    'Inter',
    'Poppins',
    'Montserrat',
    'Lora',
    'Merriweather',
    'Nunito',
    'Raleway',
    'Roboto',
  ];

  static const List<_ColorChoice> _colorChoices = <_ColorChoice>[
    _ColorChoice('Slate', Color(0xFF1E293B)),
    _ColorChoice('Gray', Color(0xFF475569)),
    _ColorChoice('Blue', Color(0xFF2563EB)),
    _ColorChoice('Sky', Color(0xFF0EA5E9)),
    _ColorChoice('Cyan', Color(0xFF06B6D4)),
    _ColorChoice('Teal', Color(0xFF14B8A6)),
    _ColorChoice('Emerald', Color(0xFF10B981)),
    _ColorChoice('Green', Color(0xFF22C55E)),
    _ColorChoice('Lime', Color(0xFF84CC16)),
    _ColorChoice('Amber', Color(0xFFF59E0B)),
    _ColorChoice('Orange', Color(0xFFF97316)),
    _ColorChoice('Red', Color(0xFFEF4444)),
    _ColorChoice('Rose', Color(0xFFF43F5E)),
    _ColorChoice('Pink', Color(0xFFEC4899)),
    _ColorChoice('Fuchsia', Color(0xFFD946EF)),
    _ColorChoice('Violet', Color(0xFF8B5CF6)),
    _ColorChoice('Indigo', Color(0xFF6366F1)),
    _ColorChoice('White', Color(0xFFFFFFFF)),
    _ColorChoice('Black', Color(0xFF111827)),
  ];

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _taglineController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _buttonTextController;
  late TextEditingController _titleColorController;
  late TextEditingController _descriptionColorController;
  late TextEditingController _accentColorController;
  late TextEditingController _buttonTextColorController;
  late TextEditingController _youtubeUrlController;

  bool _isLoading = false;
  bool _isActive = true;
  String _titleFontFamily = 'Playfair Display';
  String _bodyFontFamily = 'Inter';
  String? _imageUrl;
  String? _logoUrl;
  Uint8List? _selectedImageBytes;
  Uint8List? _selectedLogoBytes;
  String? _selectedLogoMimeType;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

  @override
  void initState() {
    super.initState();
    _taglineController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _buttonTextController = TextEditingController();
    _titleColorController = TextEditingController();
    _descriptionColorController = TextEditingController();
    _accentColorController = TextEditingController();
    _buttonTextColorController = TextEditingController();
    _youtubeUrlController = TextEditingController();
    _fetchHeroSection();
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _buttonTextController.dispose();
    _titleColorController.dispose();
    _descriptionColorController.dispose();
    _accentColorController.dispose();
    _buttonTextColorController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _loadHeroFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('web_landing')
          .doc('hero')
          .get();
      final data = doc.data();
      if (data == null || data.isEmpty) return null;
      return <String, dynamic>{'_id': doc.id, ...data};
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadHeroFromApi() async {
    try {
      final response = await _dio.get(
        'hero',
        queryParameters: {
          '_ts': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final data = response.data;
      if (data is! Map) return null;
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  void _applyHeroData(Map<String, dynamic> data) {
    final hero = HeroSectionModel.fromJson(data);

    _taglineController.text = hero.tagline;
    _titleController.text = hero.mainTitle;
    _descriptionController.text = hero.description;
    _buttonTextController.text = hero.buttonText;
    _titleColorController.text = _normalizeHexColor(
      hero.titleColor,
      fallback: '#1E293B',
    );
    _descriptionColorController.text = _normalizeHexColor(
      hero.descriptionColor,
      fallback: '#64748B',
    );
    _accentColorController.text = _normalizeHexColor(
      hero.accentColor,
      fallback: '#3B82F6',
    );
    _buttonTextColorController.text = _normalizeHexColor(
      hero.buttonTextColor,
      fallback: '#FFFFFF',
    );
    _youtubeUrlController.text = hero.youtubeUrl ?? '';
    setState(() {
      _titleFontFamily = _fontFamilies.contains(hero.titleFontFamily)
          ? hero.titleFontFamily
          : _fontFamilies.first;
      _bodyFontFamily = _fontFamilies.contains(hero.bodyFontFamily)
          ? hero.bodyFontFamily
          : 'Inter';
      _imageUrl = hero.imageUrl;
      _logoUrl = hero.logoUrl;
      _isActive = hero.isActive;
    });
  }

  String _resolvePreferredString(
    Map<String, dynamic>? primary,
    Map<String, dynamic>? secondary,
    String key,
    String fallback,
  ) {
    String? parse(dynamic value) {
      final text = (value ?? '').toString().trim();
      return text.isEmpty ? null : text;
    }

    final primaryValue = parse(primary?[key]);
    final secondaryValue = parse(secondary?[key]);

    bool isMeaningful(String? value) {
      return value != null && value.toLowerCase() != fallback.toLowerCase();
    }

    if (isMeaningful(primaryValue)) return primaryValue!;
    if (isMeaningful(secondaryValue)) return secondaryValue!;
    if (primaryValue != null) return primaryValue;
    if (secondaryValue != null) return secondaryValue;
    return fallback;
  }

  Future<bool> _saveHeroToFirestore(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('web_landing')
          .doc('hero')
          .set(
        {
          ...data,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchHeroSection() async {
    setState(() => _isLoading = true);
    try {
      final apiFuture = _loadHeroFromApi();
      final firestoreFuture = _loadHeroFromFirestore();

      final apiData = await apiFuture;
      final firestoreData = await firestoreFuture;

      final mergedData = <String, dynamic>{
        ...?firestoreData,
        ...?apiData,
      };
      mergedData['titleFontFamily'] = _resolvePreferredString(
        apiData,
        firestoreData,
        'titleFontFamily',
        'Playfair Display',
      );
      mergedData['bodyFontFamily'] = _resolvePreferredString(
        apiData,
        firestoreData,
        'bodyFontFamily',
        'Inter',
      );
      mergedData['titleColor'] = _resolvePreferredString(
        apiData,
        firestoreData,
        'titleColor',
        '#1E293B',
      );
      mergedData['descriptionColor'] = _resolvePreferredString(
        apiData,
        firestoreData,
        'descriptionColor',
        '#64748B',
      );
      mergedData['accentColor'] = _resolvePreferredString(
        apiData,
        firestoreData,
        'accentColor',
        '#3B82F6',
      );
      mergedData['buttonTextColor'] = _resolvePreferredString(
        apiData,
        firestoreData,
        'buttonTextColor',
        '#FFFFFF',
      );

      if (mergedData.isNotEmpty) {
        _applyHeroData(mergedData);
        return;
      }

      _applyHeroData({
        '_id': 'hero',
        'tagline': '',
        'mainTitle': '',
        'description': '',
        'buttonText': '',
        'titleFontFamily': 'Playfair Display',
        'bodyFontFamily': 'Inter',
        'titleColor': '#1E293B',
        'descriptionColor': '#64748B',
        'accentColor': '#3B82F6',
        'buttonTextColor': '#FFFFFF',
        'imageUrl': '',
        'logoUrl': '',
        'logoHeight': 140,
        'youtubeUrl': '',
        'isActive': true,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (bytes.length > _heroImageMaxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hero image must be ${(_heroImageMaxBytes ~/ (1024 * 1024))} MB or smaller '
              '(selected: ${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB).',
            ),
          ),
        );
        return;
      }
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedLogoBytes = bytes;
        _selectedLogoMimeType = image.mimeType;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = FormData.fromMap({
        'tagline': _taglineController.text,
        'mainTitle': _titleController.text,
        'description': _descriptionController.text,
        'buttonText': _buttonTextController.text,
        'titleFontFamily': _titleFontFamily,
        'bodyFontFamily': _bodyFontFamily,
        'titleColor': _normalizeHexColor(_titleColorController.text),
        'descriptionColor': _normalizeHexColor(
          _descriptionColorController.text,
        ),
        'accentColor': _normalizeHexColor(_accentColorController.text),
        'buttonTextColor': _normalizeHexColor(
          _buttonTextColorController.text,
        ),
        'youtubeUrl': _youtubeUrlController.text,
        'logoUrl': _logoUrl ?? '',
        'isActive': _isActive.toString(),
      });

      if (_selectedImageBytes != null) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(
              _selectedImageBytes!,
              filename: 'hero_image.png',
              contentType: MediaType('image', 'png'),
            ),
          ),
        );
      }

      if (_selectedLogoBytes != null) {
        final mimeParts = (_selectedLogoMimeType ?? 'image/png').split('/');
        final mediaType = mimeParts.length == 2
            ? MediaType(mimeParts[0], mimeParts[1])
            : MediaType('image', 'png');
        formData.files.add(
          MapEntry(
            'logo',
            MultipartFile.fromBytes(
              _selectedLogoBytes!,
              filename: 'hero_logo.png',
              contentType: mediaType,
            ),
          ),
        );
      }

      final response = await _dio.put(
        'hero',
        data: formData,
      );

      final responseData = response.data;
      final heroData = responseData is Map
          ? Map<String, dynamic>.from(responseData)
          : null;

      if (response.statusCode == 200) {
        if (heroData != null) {
          await _saveHeroToFirestore(heroData);
          _applyHeroData({'_id': heroData['_id'] ?? 'hero', ...heroData});
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hero section updated!')),
        );
        _fetchHeroSection(); // Refresh
      } else {
        throw Exception('Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _normalizeHexColor(
    String value, {
    String fallback = '#1E293B',
  }) {
    var color = value.trim();
    if (color.isEmpty) return fallback;
    if (!color.startsWith('#')) {
      color = '#$color';
    }
    final normalized = color.substring(1);
    if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(normalized)) {
      return fallback;
    }
    return '#${normalized.substring(0, 6).toUpperCase()}';
  }

  String? _validateHexColor(String? value) {
    final color = (value ?? '').trim();
    if (color.isEmpty) return null;
    final normalized = color.startsWith('#') ? color.substring(1) : color;
    final isValid = RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$')
        .hasMatch(normalized);
    return isValid ? null : 'Enter a valid hex color like #1E293B';
  }

  Color? _parseHexColor(String value) {
    var color = value.trim();
    if (color.isEmpty) return null;
    if (color.startsWith('#')) {
      color = color.substring(1);
    }
    if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(color)) {
      return null;
    }
    if (color.length == 6) {
      color = 'FF$color';
    } else if (color.length == 8 && color.startsWith('00')) {
      color = 'FF${color.substring(2)}';
    }
    return Color(int.parse(color, radix: 16));
  }

  String _hexFromColor(Color color) {
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    return '#${hex.substring(2).toUpperCase()}';
  }

  bool _isDarkColor(Color color) => color.computeLuminance() < 0.5;

  Future<void> _openColorPicker(
    TextEditingController controller, {
    required String title,
    required String helperText,
    required String fallbackHex,
  }) async {
    final initialColor =
        _parseHexColor(controller.text) ?? _parseHexColor(fallbackHex) ?? Colors.blue;
    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helperText,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedColor.withOpacity(0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedColor.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.palette_outlined,
                                color: _isDarkColor(selectedColor)
                                    ? Colors.white
                                    : Colors.black87,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected color',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _hexFromColor(selectedColor),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _colorChoices.map((choice) {
                          final isSelected =
                              choice.color.value == selectedColor.value;
                          return Tooltip(
                            message: choice.name,
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedColor = choice.color;
                                });
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: choice.color,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black87
                                        : Colors.black12,
                                    width: isSelected ? 3 : 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: choice.color.withOpacity(0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: _isDarkColor(choice.color)
                                            ? Colors.white
                                            : Colors.black87,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(selectedColor),
              child: const Text('Use Color'),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        controller.text = _hexFromColor(pickedColor);
      });
    }
  }

  Widget _buildColorPickerField({
    required String label,
    required TextEditingController controller,
    required String fallbackHex,
    required String helperText,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (_) => _validateHexColor(controller.text),
      builder: (state) {
        final previewColor =
            _parseHexColor(controller.text) ?? _parseHexColor(fallbackHex) ?? Colors.blue;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openColorPicker(
              controller,
              title: label,
              helperText: helperText,
              fallbackHex: fallbackHex,
            ),
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                border: const OutlineInputBorder(),
                errorText: state.errorText,
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: previewColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: previewColor.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _hexFromColor(previewColor),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.palette_outlined,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final embeddedLogoBytes = _decodeDataImage((_logoUrl ?? '').trim());
    if (_isLoading && _taglineController.text.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hero Section'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Center(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 200,
                          width: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _selectedImageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (_imageUrl != null && _imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    )),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Change Hero Image'),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Max ${_heroImageMaxBytes ~/ (1024 * 1024)} MB per image',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _selectedLogoBytes != null
                              ? Image.memory(_selectedLogoBytes!,
                                  fit: BoxFit.contain)
                              : (_logoUrl != null && _logoUrl!.isNotEmpty
                                  ? (embeddedLogoBytes != null
                                      ? Image.memory(
                                          embeddedLogoBytes,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.network(_logoUrl!,
                                          fit: BoxFit.contain))
                                  : const Icon(
                                      Icons.image_outlined,
                                      size: 44,
                                      color: Colors.grey,
                                    )),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Logo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Fields
              TextFormField(
                controller: _taglineController,
                decoration: const InputDecoration(
                  labelText: 'Tagline',
                  hintText: 'e.g. ✨ We Are Clino',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Main Title',
                  hintText: 'e.g. Feel Your Way For Freshness',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _buttonTextController,
                decoration: const InputDecoration(
                  labelText: 'Button Text',
                  hintText: 'e.g. Our Services',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _titleFontFamily,
                decoration: const InputDecoration(
                  labelText: 'Title Font Family',
                  border: OutlineInputBorder(),
                ),
                items: _fontFamilies
                    .map(
                      (font) => DropdownMenuItem<String>(
                        value: font,
                        child: Text(font),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _titleFontFamily = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _bodyFontFamily,
                decoration: const InputDecoration(
                  labelText: 'Body Font Family',
                  border: OutlineInputBorder(),
                ),
                items: _fontFamilies
                    .map(
                      (font) => DropdownMenuItem<String>(
                        value: font,
                        child: Text(font),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _bodyFontFamily = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              _buildColorPickerField(
                label: 'Title Color',
                controller: _titleColorController,
                fallbackHex: '#1E293B',
                helperText: 'Tap to choose the hero title color',
              ),
              const SizedBox(height: 16),

              _buildColorPickerField(
                label: 'Description Color',
                controller: _descriptionColorController,
                fallbackHex: '#64748B',
                helperText: 'Tap to choose the hero description color',
              ),
              const SizedBox(height: 16),

              _buildColorPickerField(
                label: 'Accent Color',
                controller: _accentColorController,
                fallbackHex: '#3B82F6',
                helperText: 'Used for badge and button background',
              ),
              const SizedBox(height: 16),

              _buildColorPickerField(
                label: 'Button Text Color',
                controller: _buttonTextColorController,
                fallbackHex: '#FFFFFF',
                helperText: 'Tap to choose button text color',
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _youtubeUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL',
                  hintText: 'e.g. https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_library),
                ),
              ),
              const SizedBox(height: 16),

              // Active Switch
              SwitchListTile(
                title: const Text('Is Active?'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Hero Section',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List? _decodeDataImage(String imageUrl) {
    if (!imageUrl.startsWith('data:image')) return null;
    final commaIndex = imageUrl.indexOf(',');
    if (commaIndex == -1 || commaIndex >= imageUrl.length - 1) return null;
    try {
      return base64Decode(imageUrl.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}

class _ColorChoice {
  const _ColorChoice(this.name, this.color);

  final String name;
  final Color color;
}
