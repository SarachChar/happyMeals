import 'package:flutter/material.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:provider/provider.dart';

class WristPage extends StatefulWidget {
  const WristPage({super.key});

  @override
  State<WristPage> createState() => _WristPageState();
}

class _WristPageState extends State<WristPage> {
  final _formKey = GlobalKey<FormState>();
  String _wrist = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Wrist'),
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
                  icon: Icon(Icons.straighten),
                  hintText: 'Enter your wrist size',
                  labelText: 'Wrist',
                  suffixText: 'CM',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรอบข้อมือ';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
                onSaved: (value) {
                  _wrist = value!;
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  context.read<HealthProvider>().wrist = _wrist;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('อัปเดตรอบเอวสำเร็จ = $_wrist CM'),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  await Future.delayed(
                    const Duration(milliseconds: 1500)
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