import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_heatmap/pages/calendar.dart';
import 'package:google_maps_heatmap/pages/heatmap.dart';
import 'package:google_maps_heatmap/pages/statistics.dart';

class DashboardPage extends StatefulWidget
{
  const DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
{
  final pages = [ const CalendarPage(), const HeatmapPage(), const StatisticsPage() ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Heatmap Monitor"),
          centerTitle: true,
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Heatmap"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistics"),
          ],
        )
    );
  }
}