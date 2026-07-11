import 'package:flutter/material.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:happymeal_application/pages/02_height.dart';
import 'package:happymeal_application/pages/03_weight.dart';
import 'package:happymeal_application/pages/04_wrist.dart';
import 'package:provider/provider.dart';


class HealthPage extends StatelessWidget {
  HealthPage({super.key});

  final List<String> entries = ['Height', 'Weight', 'Wrist', 'BMI'];

  String getUnit(String title) {
  if (title == 'Height') return 'CM';
  if (title == 'Weight') return 'KG';
  if (title == 'Wrist') return 'CM';
  if (title == 'BMI') return '';
  return '';
}
  
  IconData getHealthIcon(String title) {
    switch (title) {
      case 'Height':
        return Icons.height;
      case 'Weight':
        return Icons.scale;
      case 'Wrist':
        return Icons.straighten;
      case 'BMI':
        return Icons.monitor_weight;
      default:
        return Icons.error;
    }
  }
  
  double calculateBMI(String height, String weight) {
  double h = double.parse(height) / 100;
  double w = double.parse(weight);
  return w / (h * h);
  }

  String getBMIResult(double bmi) {
    if (bmi < 18.5) return 'น้ำหนักน้อย';
    if (bmi < 23) return 'ปกติ';
    if (bmi < 25) return 'น้ำหนักเกิน';
    if (bmi < 30) return 'อ้วน';
    return 'อ้วนมาก';
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Health Information"),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, value, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              String title = entries[index];
              String subtitle = 'กดเพื่อเพิ่มข้อมูล';
              if (title == 'Height' && value.height.isNotEmpty) {
                subtitle = '${value.height} CM';
              }

              if (title == 'Weight' && value.weight.isNotEmpty) {
                subtitle = '${value.weight} KG';
              }

              if (title == 'Wrist' && value.wrist.isNotEmpty) {
                subtitle = '${value.wrist} CM';
              }

              if (title == 'BMI') {
                if (value.height.isNotEmpty && value.weight.isNotEmpty) {
                  double bmi = calculateBMI(value.height, value.weight);
                  String result = getBMIResult(bmi);

                  subtitle = '${bmi.toStringAsFixed(2)} ($result)';
                } else {
                  subtitle = 'กรุณากรอกส่วนสูง และ น้ำหนัก';
                }
              }

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  switch (title) {
                    case 'Height':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HeightPage(),
                        ),
                      );
                      break;

                    case 'Weight':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeightPage(),
                        ),
                      );
                      break;

                    case 'Wrist':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WristPage(),
                        ),
                      );
                      break;

                    case 'BMI':
                      if (value.height.isEmpty || value.weight.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('กรุณากรอกส่วนสูงและน้ำหนักก่อน'),
                          ),
                        );
                      } else {
                        double bmi = calculateBMI(value.height, value.weight);
                        String result = getBMIResult(bmi);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'BMI = ${bmi.toStringAsFixed(2)} ($result)',
                            ),
                          ),
                        );
                      }
                      break;
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        getHealthIcon(title),
                        size: 30,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}