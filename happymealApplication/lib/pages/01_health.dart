import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happymeal_application/controllers/health_controller.dart';
import 'package:happymeal_application/models/health_model.dart';
import 'package:happymeal_application/services/health_service.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:happymeal_application/pages/02_height.dart';
import 'package:happymeal_application/pages/03_weight.dart';
import 'package:happymeal_application/pages/04_wrist.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final List<String> entries = ['Height', 'Weight', 'Wrist', 'BMI'];
  
  final HealthController _controller = HealthController(HealthFirebaseService());
  bool _isLoading = false;
  StreamSubscription<bool>? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _syncSubscription = _controller.onSync.listen((bool syncState) {
      if (!mounted) return;
      setState(() {
        _isLoading = syncState;
      });
    });
    _fetchDataForDate(context.read<HealthProvider>().selectedDate);
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String formatPrettyDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _fetchDataForDate(DateTime date) async {
    try {
      final results = await _controller.fetchHealthsByDate(date);
      if (!mounted) return;

      final provider = context.read<HealthProvider>();
      
      if (results.isNotEmpty) {
        final latest = results.last;
        provider.height = latest.height;
        provider.weight = latest.weight;
        provider.wrist = latest.wrist;
      } else {
        provider.clear();
      }

      if (formatDate(date) == formatDate(DateTime.now())) {
        if (results.isNotEmpty) {
          final latest = results.last;
          provider.todayHeight = latest.height;
          provider.todayWeight = latest.weight;
          provider.todayWrist = latest.wrist;
          provider.todayBMI = latest.bmi;
        } else {
          provider.todayHeight = '';
          provider.todayWeight = '';
          provider.todayWrist = '';
          provider.todayBMI = 0.0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching health data: $e');
    }
  }

  Future<void> _saveAllData() async {
    final provider = context.read<HealthProvider>();
    
    if (provider.height.isEmpty || provider.weight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลส่วนสูงและน้ำหนักก่อนทำการบันทึกข้อมูลครับ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      double bmiVal = 0.0;
      try {
        double h = double.parse(provider.height) / 100;
        double w = double.parse(provider.weight);
        bmiVal = w / (h * h);
      } catch (_) {
        bmiVal = 0.0;
      }

      List<Health> existingEntries = await _controller.fetchHealthsByDate(provider.selectedDate);
      if (existingEntries.isNotEmpty) {
        for (var entry in existingEntries) {
          await _controller.updateHealth(entry);
        }
      }

      Health newHealth = Health(
        createdAt: DateTime(
          provider.selectedDate.year,
          provider.selectedDate.month,
          provider.selectedDate.day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        ),
        height: provider.height,
        weight: provider.weight,
        wrist: provider.wrist,
        bmi: bmiVal,
      );

      await _controller.addHealth(newHealth);
      

      await _fetchDataForDate(provider.selectedDate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกข้อมูลสำเร็จในประวัติวันที่: ${formatPrettyDate(provider.selectedDate)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      provider.selectedDate = picked;
      await _fetchDataForDate(picked);
    }
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
                          formatPrettyDate(provider.selectedDate),
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
          if (_isLoading)
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
                onPressed: _saveAllData,
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