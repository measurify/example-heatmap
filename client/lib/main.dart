import 'package:flutter/material.dart';
import 'package:google_maps_heatmap/pages/dashboard.dart';
import 'package:google_maps_heatmap/pages/login.dart';

void main()
{
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    initialRoute: "/login",
    routes: {
      "/login" : (context) => const LoginPage(),
      "/dashboard" : (context) => const DashboardPage(),
      },
  ));
}