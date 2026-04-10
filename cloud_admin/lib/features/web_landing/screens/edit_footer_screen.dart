import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_admin/core/config/app_config.dart';

class EditFooterScreen extends ConsumerStatefulWidget {
  const EditFooterScreen({super.key});

  @override
  ConsumerState<EditFooterScreen> createState() => _EditFooterScreenState();
}

class _EditFooterScreenState extends ConsumerState<EditFooterScreen> {
  static const List<Map<String, String>> _defaultPolicyLinks = [
    {'label': 'Privacy Policy', 'route': '/privacy'},
    {'label': 'Terms of Service', 'route': '/terms'},
    {'label': 'Child Protection', 'route': '/child-protection'},
    {'label': 'Sitemap', 'route': '/'},
  ];

  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _copyrightController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _mailController = TextEditingController();

  final List<Map<String, String>> _exploreLinks = [];
  final List<Map<String, String>> _serviceLinks = [];
  final List<Map<String, String>> _policyLinks = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFooter();
  }

  Map<String, dynamic> _defaultFooterData() {
    return {
      'description':
          'Redefining premium garment care with technology and craftsmanship. Your wardrobe deserves nothing but the best.',
      'phone': '+91 98765 43210',
      'email': 'hello@cloudwash.com',
      'address': 'Suite 402, Laundry Lane, Bangalore, KA 560001',
      'copyright': '© ${DateTime.now().year} Cloud Wash. Crafted with precision.',
      'exploreLinks': <Map<String, String>>[],
      'serviceLinks': <Map<String, String>>[],
      'policyLinks': List<Map<String, String>>.from(_defaultPolicyLinks),
      'socialLinks': {
        'facebook': '',
        'instagram': '',
        'email': '',
        'mail': '',
      },
    };
  }

  List<Map<String, String>> _parseLinks(
    dynamic value, {
    List<Map<String, String>> fallback = const [],
  }) {
    if (value is! List) return fallback;

    return value
        .map(
          (item) {
            final map = item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{};
            return {
              'label': map['label']?.toString() ?? '',
              'route': map['route']?.toString() ?? '/',
            };
          },
        )
        .where((link) => link['label']!.trim().isNotEmpty)
        .toList();
  }

  Map<String, String> _parseSocialLinks(dynamic value) {
    if (value is! Map) {
      return {'facebook': '', 'instagram': '', 'email': '', 'mail': ''};
    }

    final social = Map<String, dynamic>.from(value);
    return {
      'facebook': social['facebook']?.toString() ?? '',
      'instagram': social['instagram']?.toString() ?? '',
      'email': social['email']?.toString() ?? '',
      'mail': social['mail']?.toString() ?? social['email']?.toString() ?? '',
    };
  }

  String _resolveVisibleEmail(Map<String, String> social, String fallback) {
    final mail = social['mail']?.trim() ?? '';
    if (mail.isNotEmpty) return mail;

    final socialEmail = social['email']?.trim() ?? '';
    if (socialEmail.isNotEmpty) return socialEmail;

    return fallback.trim();
  }

  void _applyFooterData(Map<String, dynamic> data) {
    final social = _parseSocialLinks(data['socialLinks']);
    final fallbackEmail = data['email']?.toString() ?? '';

    _descriptionController.text = data['description']?.toString() ?? '';
    _phoneController.text = data['phone']?.toString() ?? '';
    _emailController.text = _resolveVisibleEmail(social, fallbackEmail);
    _addressController.text = data['address']?.toString() ?? '';
    _copyrightController.text = data['copyright']?.toString() ??
        '© ${DateTime.now().year} Cloud Wash. Crafted with precision.';
    _facebookController.text = social['facebook'] ?? '';
    _instagramController.text = social['instagram'] ?? '';
    _mailController.text = social['mail'] ?? '';

    _exploreLinks
      ..clear()
      ..addAll(_parseLinks(data['exploreLinks']));
    _serviceLinks
      ..clear()
      ..addAll(_parseLinks(data['serviceLinks']));
    _policyLinks
      ..clear()
      ..addAll(
        _parseLinks(
          data['policyLinks'],
          fallback: _defaultPolicyLinks,
        ),
      );

    if (_policyLinks.isEmpty) {
      _policyLinks.addAll(_defaultPolicyLinks);
    }
  }

  Map<String, dynamic> _buildFooterPayload() {
    final exploreLinks = _parseLinks(_exploreLinks);
    final serviceLinks = _parseLinks(_serviceLinks);
    final policyLinks = _parseLinks(
      _policyLinks,
      fallback: _defaultPolicyLinks,
    );
    final primaryEmail = _emailController.text.trim();
    final supportEmail = _mailController.text.trim();
    final resolvedEmail = primaryEmail.isNotEmpty ? primaryEmail : supportEmail;
    final resolvedSupportEmail =
        supportEmail.isNotEmpty ? supportEmail : resolvedEmail;

    return {
      'description': _descriptionController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': resolvedEmail,
      'address': _addressController.text.trim(),
      'copyright': _copyrightController.text.trim(),
      'exploreLinks': exploreLinks,
      'serviceLinks': serviceLinks,
      'policyLinks': policyLinks.isEmpty ? _defaultPolicyLinks : policyLinks,
      'socialLinks': {
        'facebook': _facebookController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'email': resolvedSupportEmail,
        'mail': resolvedSupportEmail,
      },
    };
  }

  Future<Map<String, dynamic>?> _loadFooterFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('web_landing')
          .doc('footer')
          .get();
      final data = doc.data();
      if (data == null || data.isEmpty) return null;
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadFooterFromApi() async {
    try {
      final response = await http.get(
        AppConfig.apiUri(
          'web-content/footer',
          queryParameters: {
            'ts': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _saveFooterToFirestore(Map<String, dynamic> payload) async {
    try {
      await FirebaseFirestore.instance
          .collection('web_landing')
          .doc('footer')
          .set(
        {
          ...payload,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _saveFooterToApi(Map<String, dynamic> payload) async {
    try {
      final response = await http.put(
        AppConfig.apiUri('web-content/footer'),
        headers: const {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(payload),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadFooter() async {
    setState(() => _isLoading = true);
    try {
      final firestoreFuture = _loadFooterFromFirestore();
      final apiFuture = _loadFooterFromApi();

      final firestoreData = await firestoreFuture;
      final apiData = await apiFuture;

      final mergedData = <String, dynamic>{
        ...?firestoreData,
        ...?apiData,
      };

      if (mergedData.isEmpty) {
        _applyFooterData(_defaultFooterData());
      } else {
        _applyFooterData(mergedData);
      }
      _errorMessage = null;
    } catch (e) {
      _applyFooterData(_defaultFooterData());
      _errorMessage = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loaded default footer data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final payload = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(_buildFooterPayload())) as Map,
      );
      final firestoreSaved = await _saveFooterToFirestore(payload);
      final apiSaved = await _saveFooterToApi(payload);

      if (!firestoreSaved && !apiSaved) {
        throw Exception('Failed to save footer to Firestore and API');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiSaved
                ? 'Footer saved'
                : 'Footer saved for website sync',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _copyrightController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Footer'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load footer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadFooter,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Brand blurb',
                        hint:
                            'Redefining premium garment care with technology and craftsmanship...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Phone',
                              hint: '+91 98765 43210',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'hello@cloudwash.com',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Suite 402, Laundry Lane, Bangalore, KA 560001',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _copyrightController,
                        label: 'Copyright line',
                        hint: '© 2026 Cloud Wash. Crafted with precision.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Social Links',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _facebookController,
                              label: 'Facebook URL',
                              hint: 'https://facebook.com/cloudwash',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _instagramController,
                              label: 'Instagram URL',
                              hint: 'https://instagram.com/cloudwash',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _mailController,
                        label: 'Support Email (for icon link)',
                        hint: 'hello@cloudwash.com',
                      ),
                      const SizedBox(height: 24),
                      _LinksEditor(
                        title: 'Explore Links',
                        items: _exploreLinks,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _LinksEditor(
                        title: 'Services Links',
                        items: _serviceLinks,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _LinksEditor(
                        title: 'Bottom Policy Links',
                        items: _policyLinks,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: const Icon(Icons.save),
                          label: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save footer'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}

class _LinksEditor extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final VoidCallback onChanged;

  const _LinksEditor(
      {required this.title, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: () {
                    items.add({'label': 'New link', 'route': '/'});
                    onChanged();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No links added yet',
                  style: TextStyle(color: Colors.grey)),
            for (int i = 0; i < items.length; i++) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: items[i]['label'],
                      decoration: const InputDecoration(labelText: 'Label'),
                      onChanged: (v) => items[i]['label'] = v,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: items[i]['route'],
                      decoration: const InputDecoration(labelText: 'Route/URL'),
                      onChanged: (v) => items[i]['route'] = v,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      items.removeAt(i);
                      onChanged();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ]
          ],
        ),
      ),
    );
  }
}
