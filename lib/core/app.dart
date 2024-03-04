import 'package:flutter/material.dart';
import 'package:drawing/drawing_canvas/presentation/drawing_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Let\'s Draw',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: DrawingPage(),
    );
  }
}
