import 'package:flutter/material.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:provider/provider.dart';

class HeightPage extends StatefulWidget {
  const HeightPage({super.key});

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  final _formKey = GlobalKey<FormState>();
  String _height = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Height'),
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
                  icon: Icon(Icons.height),
                  hintText: 'Enter your height',
                  labelText: 'Height',
                  suffixText: 'CM',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกส่วนสูง';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
                onSaved: (value) {
                  _height = value!;
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  context.read<HealthProvider>().height = _height;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('อัปเดตส่วนสูงสำเร็จ = $_height CM'),
                      duration: const Duration(seconds: 4),
                    ),
                  );

                  await Future.delayed(
                    const Duration(milliseconds: 1500),
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