import 'package:flutter/material.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:provider/provider.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final _formKey = GlobalKey<FormState>();
  String _weight = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Weight'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.scale),
                  hintText: 'Enter your weight',
                  labelText: 'Weight',
                  suffixText: 'KG',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกน้ำหนัก';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
                onSaved: (value) {
                  _weight = value!;
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  context.read<HealthProvider>().weight = _weight;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('อัปเดตน้ำหนักชั่วคราวสำเร็จ = $_weight KG'),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  await Future.delayed(
                    const Duration(milliseconds: 1000),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}