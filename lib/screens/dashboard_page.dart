import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, double>> _getData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("ab_events")
        .where("action", isEqualTo: "time_to_add")
        .get();

    final groupA = snapshot.docs.where((d) => d["group"] == "A").toList();
    final groupB = snapshot.docs.where((d) => d["group"] == "B").toList();

    double avgA = groupA.isEmpty
        ? 0
        : groupA.map((d) => d["duration_ms"] as int).reduce((a, b) => a + b) /
              groupA.length;

    double avgB = groupB.isEmpty
        ? 0
        : groupB.map((d) => d["duration_ms"] as int).reduce((a, b) => a + b) /
              groupB.length;

    return {
      "A": avgA / 1000, // segundos
      "B": avgB / 1000,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard A/B")),
      body: FutureBuilder<Map<String, double>>(
        future: _getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text("Grupo A");
                          case 1:
                            return const Text("Grupo B");
                          default:
                            return const Text("");
                        }
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: data["A"]!,
                        color: Colors.blue,
                        width: 30,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: data["B"]!,
                        color: const Color.fromARGB(255, 217, 2, 255),
                        width: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
