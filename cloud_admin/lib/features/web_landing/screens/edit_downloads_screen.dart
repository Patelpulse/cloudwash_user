import 'package:cloud_admin/features/web_landing/models/stats_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_admin/core/config/app_config.dart';

class EditDownloadsScreen extends ConsumerStatefulWidget {
  const EditDownloadsScreen({super.key});

  @override
  ConsumerState<EditDownloadsScreen> createState() => _EditDownloadsScreenState();
}

class _EditDownloadsScreenState extends ConsumerState<EditDownloadsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _appStoreController;
  late TextEditingController _playStoreController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _appStoreController = TextEditingController();
    _playStoreController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _appStoreController.dispose();
    _playStoreController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(AppConfig.apiUri('web-content/stats'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stats = StatsModel.fromJson(data);

        _tagController.text = stats.appDownloadTag;
        _titleController.text = stats.appDownloadTitle;
        _subtitleController.text = stats.appDownloadSubtitle;
        _appStoreController.text = stats.appStoreUrl;
        _playStoreController.text = stats.playStoreUrl;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      var request =
          http.MultipartRequest('PUT', AppConfig.apiUri('web-content/stats'));

      request.fields['appDownloadTag'] = _tagController.text;
      request.fields['appDownloadTitle'] = _titleController.text;
      request.fields['appDownloadSubtitle'] = _subtitleController.text;
      request.fields['appStoreUrl'] = _appStoreController.text;
      request.fields['playStoreUrl'] = _playStoreController.text;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Saved Successfully')));
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit App Download Section'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
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
                    _buildSectionHeader('General Content', Icons.text_fields_rounded),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Tag Label',
                        hintText: 'e.g. DOWNLOAD THE APP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Main Title',
                        hintText: 'e.g. Your Personal Laundry Manager...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subtitleController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle / Description',
                        hintText: 'e.g. Book, track, and manage...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Download Links', Icons.link_rounded),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _appStoreController,
                      decoration: const InputDecoration(
                        labelText: 'App Store URL',
                        hintText: 'https://apps.apple.com/...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.apple),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _playStoreController,
                      decoration: const InputDecoration(
                        labelText: 'Play Store URL',
                        hintText: 'https://play.google.com/...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.play_arrow_rounded),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Section Content',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}