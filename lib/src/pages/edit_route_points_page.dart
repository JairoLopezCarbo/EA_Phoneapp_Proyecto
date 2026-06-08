import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';

class EditRoutePointsPage extends StatefulWidget {
  const EditRoutePointsPage({super.key, required this.routeId});

  final String routeId;

  @override
  State<EditRoutePointsPage> createState() => _EditRoutePointsPageState();
}

class _EditRoutePointsPageState extends State<EditRoutePointsPage> {
  bool _saving = false;

  Future<void> _openPointForm({RoutePointModel? point}) async {
    final result = await showDialog<_PointFormResult>(
      context: context,
      builder: (_) => _PointDialog(point: point),
    );

    if (result == null || !mounted) return;

    setState(() => _saving = true);

    try {
      final appState = context.read<AppState>();

      if (point == null) {
        await appState.createPointForRoute(
          routeId: widget.routeId,
          name: result.name,
          description: result.description,
          latitude: result.latitude,
          longitude: result.longitude,
          image: result.image,
        );
      } else {
        await appState.updatePointForRoute(
          routeId: widget.routeId,
          point: point.copyWith(
            name: result.name,
            description: result.description,
            latitude: result.latitude,
            longitude: result.longitude,
            image: result.image,
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(point == null ? 'Point created.' : 'Point updated.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePoint(RoutePointModel point) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete point'),
        content: Text('Are you sure you want to delete "${point.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _saving = true);

    try {
      await context.read<AppState>().deletePointFromRoute(
            routeId: widget.routeId,
            pointId: point.id,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Point deleted.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = context.watch<AppState>().routeById(widget.routeId);

    if (route == null) {
      return const Scaffold(
        body: Center(child: Text('Route not found.')),
      );
    }

    final points = [...route.points]..sort((a, b) => a.index.compareTo(b.index));

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit points - ${route.name}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _openPointForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add point'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_saving) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          if (points.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: Text('This route has no points yet.')),
            ),
          for (final point in points)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(point.name),
                subtitle: Text(
                  '${point.latitude}, ${point.longitude}'
                  '${point.description == null || point.description!.trim().isEmpty ? '' : '\n${point.description}'}',
                ),
                isThreeLine: point.description != null &&
                    point.description!.trim().isNotEmpty,
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed:
                          _saving ? null : () => _openPointForm(point: point),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _saving ? null : () => _deletePoint(point),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PointFormResult {
  const _PointFormResult({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.image,
  });

  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String image;
}

class _PointDialog extends StatefulWidget {
  const _PointDialog({this.point});

  final RoutePointModel? point;

  @override
  State<_PointDialog> createState() => _PointDialogState();
}

class _PointDialogState extends State<_PointDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _imageController;

  @override
  void initState() {
    super.initState();

    final point = widget.point;

    _nameController = TextEditingController(text: point?.name ?? '');
    _descriptionController =
        TextEditingController(text: point?.description ?? '');
    _latitudeController =
        TextEditingController(text: point?.latitude.toString() ?? '');
    _longitudeController =
        TextEditingController(text: point?.longitude.toString() ?? '');
    _imageController = TextEditingController(text: point?.image ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }

    return null;
  }

  String? _number(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) return requiredMessage;

    final parsed = double.tryParse(value!.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _PointFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        image: _imageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.point != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit point' : 'Add point'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: _number,
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: _number,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}