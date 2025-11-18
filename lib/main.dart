import 'package:flutter/material.dart';
import 'src/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherDashboardApp());
}

class WeatherDashboardApp extends StatelessWidget {
  const WeatherDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
