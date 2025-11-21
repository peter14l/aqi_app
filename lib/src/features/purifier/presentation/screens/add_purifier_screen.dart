import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';
import 'package:aqi_app/src/features/purifier/presentation/providers/purifier_provider.dart';

class AddPurifierScreen extends ConsumerStatefulWidget {
  const AddPurifierScreen({super.key});

  @override
  _AddPurifierScreenState createState() => _AddPurifierScreenState();
}

class _AddPurifierScreenState extends ConsumerState<AddPurifierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Purifier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Purifier Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the purifier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addPurifier,
                child: const Text('Add Purifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPurifier() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(purifierNotifierProvider.notifier);
      final newPurifier = PurifierState(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        status: 'off',
        mode: 'auto',
        fanSpeed: 1,
        isConnected: true,
        lastUpdated: DateTime.now(),
      );

      try {
        await notifier.addPurifier(newPurifier);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add purifier: $e')),
          );
        }
      }
    }
  }
}
