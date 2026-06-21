import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/localization.dart';

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.routeCreated)));

      widget.onCreated(createdRoute);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizedError(context, error))));
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
      return context.l10n.requiredField;
    }
    return null;
  }

  String? _number(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) return requiredMessage;

    final parsed = double.tryParse(value!.trim());
    if (parsed == null) {
      return context.l10n.validNumber;
    }
    return null;
  }

  String? _integer(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) return requiredMessage;

    final parsed = int.tryParse(value!.trim());
    if (parsed == null) {
      return context.l10n.validInteger;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isAuthenticated) {
      return Center(child: Text(context.l10n.loginToCreateRoute));
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createRoute)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.name),
                validator: _required,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                ),
                minLines: 3,
                maxLines: 5,
                validator: _required,
              ),
              TextFormField(
                controller: _coverImageController,
                decoration: InputDecoration(
                  labelText: context.l10n.coverImageUrl,
                ),
                validator: _required,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: context.l10n.city),
                validator: _required,
              ),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: context.l10n.country),
                validator: _required,
              ),
              TextFormField(
                controller: _distanceController,
                decoration: InputDecoration(labelText: context.l10n.distance),
                keyboardType: TextInputType.number,
                validator: _number,
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: context.l10n.duration),
                keyboardType: TextInputType.number,
                validator: _integer,
              ),
              DropdownButtonFormField<RouteDifficulty>(
                initialValue: _difficulty,
                decoration: InputDecoration(labelText: context.l10n.difficulty),
                items: RouteDifficulty.values
                    .map(
                      (difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(localizedDifficulty(context, difficulty)),
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
                decoration: InputDecoration(
                  labelText: context.l10n.wheelchairAccessible,
                ),
                items: [
                  DropdownMenuItem(value: false, child: Text(context.l10n.no)),
                  DropdownMenuItem(value: true, child: Text(context.l10n.yes)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _wheelchairAccessible = value);
                  }
                },
              ),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: context.l10n.tags,
                  hintText: context.l10n.tagsHint,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.points,
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                label: Text(context.l10n.addPoint),
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
                    : Text(context.l10n.createRoute),
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
                Expanded(child: Text(context.l10n.pointNumber(index + 1))),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            TextFormField(
              controller: point.nameController,
              decoration: InputDecoration(labelText: context.l10n.pointName),
              validator: requiredValidator,
            ),
            TextFormField(
              controller: point.descriptionController,
              decoration: InputDecoration(
                labelText: context.l10n.pointDescription,
              ),
            ),
            TextFormField(
              controller: point.latitudeController,
              decoration: InputDecoration(labelText: context.l10n.latitude),
              keyboardType: TextInputType.number,
              validator: numberValidator,
            ),
            TextFormField(
              controller: point.longitudeController,
              decoration: InputDecoration(labelText: context.l10n.longitude),
              keyboardType: TextInputType.number,
              validator: numberValidator,
            ),
            TextFormField(
              controller: point.imageController,
              decoration: InputDecoration(
                labelText: context.l10n.pointImageUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
