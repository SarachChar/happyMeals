import 'package:flutter/material.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:happymeal_application/pages/02_height.dart';
import 'package:happymeal_application/pages/03_weight.dart';
import 'package:happymeal_application/pages/04_wrist.dart';
import 'package:provider/provider.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final List<String> entries = ['Height', 'Weight', 'Wrist', 'BMI'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().fetchHealthData();
    });
  }

  IconData getHealthIcon(String title) {
    switch (title) {
      case 'Height': return Icons.height;
      case 'Weight': return Icons.scale;
      case 'Wrist': return Icons.straighten;
      case 'BMI': return Icons.monitor_weight;
      default: return Icons.error;
    }
  }

  double calculateBMI(String height, String weight) {
    try {
      double h = double.parse(height) / 100;
      double w = double.parse(weight);
      return w / (h * h);
    } catch (_) {
      return 0.0;
    }
  }

  String getBMIResult(double bmi) {
    if (bmi <= 0.0) return 'ยังไม่มีข้อมูล';
    if (bmi < 18.5) return 'น้ำหนักน้อย';
    if (bmi < 23) return 'ปกติ';
    if (bmi < 25) return 'น้ำหนักเกิน';
    if (bmi < 30) return 'อ้วน';
    return 'อ้วนมาก';
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<HealthProvider>();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      await provider.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<HealthProvider>();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.inversePrimary,
        title: const Text("Health Information"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date Record Selected",
                          style: TextStyle(color: scheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.formatPrettyDate(provider.selectedDate),
                          style: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Icon(Icons.calendar_today_outlined, color: scheme.primary),
                  ],
                ),
              ),
            ),
          ),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                String title = entries[index];
                String subtitle = 'กดเพื่อระบุข้อมูลของวันนี้';
                
                if (title == 'Height' && provider.height.isNotEmpty) {
                  subtitle = '${provider.height} CM';
                }
                if (title == 'Weight' && provider.weight.isNotEmpty) {
                  subtitle = '${provider.weight} KG';
                }
                if (title == 'Wrist' && provider.wrist.isNotEmpty) {
                  subtitle = '${provider.wrist} CM';
                }
                if (title == 'BMI') {
                  if (provider.height.isNotEmpty && provider.weight.isNotEmpty) {
                    double bmi = calculateBMI(provider.height, provider.weight);
                    String result = getBMIResult(bmi);
                    subtitle = '${bmi.toStringAsFixed(2)} ($result)';
                  } else {
                    subtitle = 'กรุณากรอกข้อมูลส่วนสูงและน้ำหนักก่อน';
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: scheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        switch (title) {
                          case 'Height':
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HeightPage()));
                            break;
                          case 'Weight':
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightPage()));
                            break;
                          case 'Wrist':
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const WristPage()));
                            break;
                          case 'BMI':
                            if (provider.height.isEmpty || provider.weight.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('กรุณากรอกส่วนสูงและน้ำหนักก่อนครับ')),
                              );
                            }
                            break;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: Icon(getHealthIcon(title), color: scheme.primary, size: 26),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            if (title != 'BMI') Icon(Icons.arrow_forward_ios, size: 16, color: scheme.outline),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () async {
                  if (provider.height.isEmpty || provider.weight.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('กรุณากรอกข้อมูล ส่วนสูง และ น้ำหนัก ก่อนทำการบันทึกข้อมูลครับ'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  try {
                    await provider.saveAllHealthData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('บันทึกข้อมูลสำเร็จในประวัติวันที่: ${provider.formatPrettyDate(provider.selectedDate)}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}