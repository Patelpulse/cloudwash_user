import 'package:cloud_admin/features/web_landing/models/why_choose_us_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_admin/core/config/app_config.dart';

class EditWhyChooseUsScreen extends ConsumerStatefulWidget {
  const EditWhyChooseUsScreen({super.key});

  @override
  ConsumerState<EditWhyChooseUsScreen> createState() =>
      _EditWhyChooseUsScreenState();
}

class _EditWhyChooseUsScreenState extends ConsumerState<EditWhyChooseUsScreen> {
  List<WhyChooseUsModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final uri = AppConfig.apiUri(
        'why-choose-us',
        queryParameters: {
          'ts': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final parsedItems =
              decoded.map((e) => WhyChooseUsModel.fromJson(e)).toList();
          if (!mounted) return;
          setState(() {
            _items = parsedItems;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Unexpected response format from server.';
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Server returned status ${response.statusCode}.\n${response.body}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    if (!await _showDeleteConfirmation()) return;
    try {
      final response = await http.delete(AppConfig.apiUri('why-choose-us/$id'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item?'),
            content: const Text(
                'Are you sure you want to delete this item? This action cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showAddEditDialog([WhyChooseUsModel? item]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _WhyChooseUsDialog(
        existingItem: item,
        onSave: _fetchItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Why Choose Us'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchItems,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Failed to load items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchItems,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No items yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to add your first "Why Choose Us" item.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.check_circle_outline,
                  color: Colors.deepOrange),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (item.iconUrl.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Icon: ${item.iconUrl}',
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      color: item.isActive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit',
                  onPressed: () => _showAddEditDialog(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () => _deleteItem(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WhyChooseUsDialog extends StatefulWidget {
  final WhyChooseUsModel? existingItem;
  final VoidCallback onSave;

  const _WhyChooseUsDialog(
      {this.existingItem, required this.onSave});

  @override
  State<_WhyChooseUsDialog> createState() => _WhyChooseUsDialogState();
}

class _WhyChooseUsDialogState extends State<_WhyChooseUsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconUrlController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingItem?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingItem?.description ?? '');
    _iconUrlController =
        TextEditingController(text: widget.existingItem?.iconUrl ?? '');
    _isActive = widget.existingItem?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _iconUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final isEdit = widget.existingItem != null;
      final body = jsonEncode({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'iconUrl': _iconUrlController.text.trim().isEmpty
            ? 'default'
            : _iconUrlController.text.trim(),
        'isActive': _isActive,
      });

      final response = await (isEdit ? http.put : http.post)(
        AppConfig.apiUri(
          isEdit
              ? 'why-choose-us/${widget.existingItem!.id}'
              : 'why-choose-us',
        ),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        widget.onSave();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit
                ? 'Item updated successfully!'
                : 'Item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to save: ${response.statusCode}\n${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingItem == null ? 'Add Why Choose Us Item' : 'Edit Item',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Expert Team',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe this benefit...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _iconUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Icon Name or URL (optional)',
                    hintText: 'e.g. star, check, or https://...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text('Show this item on the website'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingItem == null ? 'Add Item' : 'Save Changes'),
        ),
      ],
    );
  }
}
