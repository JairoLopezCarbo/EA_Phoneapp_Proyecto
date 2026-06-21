import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key, required this.onCreated});

  final ValueChanged<RouteModel> onCreated;

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverImageController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _tagsController = TextEditingController();

  RouteDifficulty _difficulty = RouteDifficulty.medium;
  bool _wheelchairAccessible = false;
  bool _isSubmitting = false;

  final List<_PointFormData> _points = [_PointFormData(index: 0)];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _tagsController.dispose();

    for (final point in _points) {
      point.dispose();
    }

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appState = context.read<AppState>();

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final points = _points.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;

        return RoutePointCreateInput(
          name: point.nameController.text,
          description: point.descriptionController.text,
          latitude: double.parse(point.latitudeController.text),
          longitude: double.parse(point.longitudeController.text),
          image: point.imageController.text,
          index: index,
        );
      }).toList();

      final createdRoute = await appState.createRoute(
        name: _nameController.text,
        description: _descriptionController.text,
        coverImage: _coverImageController.text,
        city: _cityController.text,
        country: _countryController.text,
        distance: double.parse(_distanceController.text),
        duration: int.parse(_durationController.text),
        difficulty: _difficulty,
        wheelchairAccessible: _wheelchairAccessible,
        tags: tags,
        points: points,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route created successfully.')),
      );

      widget.onCreated(createdRoute);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _addPoint() {
    setState(() {
      _points.add(_PointFormData(index: _points.length));
    });
  }

  void _removePoint(int index) {
    if (_points.length <= 1) {
      return;
    }

    setState(() {
      final removed = _points.removeAt(index);
      removed.dispose();
    });
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

  String? _integer(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) return requiredMessage;

    final parsed = int.tryParse(value!.trim());
    if (parsed == null) {
      return 'Enter a valid integer';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isAuthenticated) {
      return const Center(child: Text('Log in to create a route.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create route')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 5,
                validator: _required,
              ),
              TextFormField(
                controller: _coverImageController,
                decoration: const InputDecoration(labelText: 'Cover image URL'),
                validator: _required,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: _required,
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: _required,
              ),
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(labelText: 'Distance'),
                keyboardType: TextInputType.number,
                validator: _number,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
                keyboardType: TextInputType.number,
                validator: _integer,
              ),
              DropdownButtonFormField<RouteDifficulty>(
                initialValue: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: RouteDifficulty.values
                    .map(
                      (difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _difficulty = value);
                  }
                },
              ),
              DropdownButtonFormField<bool>(
                initialValue: _wheelchairAccessible,
                decoration: const InputDecoration(
                  labelText: 'Wheelchair accessible',
                ),
                items: const [
                  DropdownMenuItem(value: false, child: Text('No')),
                  DropdownMenuItem(value: true, child: Text('Yes')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _wheelchairAccessible = value);
                  }
                },
              ),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'museum, city, food',
                ),
              ),
              const SizedBox(height: 24),
              Text('Points', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (var i = 0; i < _points.length; i++)
                _PointForm(
                  point: _points[i],
                  index: i,
                  canRemove: _points.length > 1,
                  onRemove: () => _removePoint(i),
                  requiredValidator: _required,
                  numberValidator: _number,
                ),
              OutlinedButton.icon(
                onPressed: _addPoint,
                icon: const Icon(Icons.add),
                label: const Text('Add point'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create route'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointFormData {
  _PointFormData({required this.index});

  final int index;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final imageController = TextEditingController();

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    imageController.dispose();
  }
}

class _PointForm extends StatelessWidget {
  const _PointForm({
    required this.point,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.requiredValidator,
    required this.numberValidator,
  });

  final _PointFormData point;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final String? Function(String?) requiredValidator;
  final String? Function(String?) numberValidator;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Point ${index + 1}')),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            TextFormField(
              controller: point.nameController,
              decoration: const InputDecoration(labelText: 'Point name'),
              validator: requiredValidator,
            ),
            TextFormField(
              controller: point.descriptionController,
              decoration: const InputDecoration(labelText: 'Point description'),
            ),
            TextFormField(
              controller: point.latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
              validator: numberValidator,
            ),
            TextFormField(
              controller: point.longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
              validator: numberValidator,
            ),
            TextFormField(
              controller: point.imageController,
              decoration: const InputDecoration(labelText: 'Point image URL'),
            ),
          ],
        ),
      ),
    );
  }
}
