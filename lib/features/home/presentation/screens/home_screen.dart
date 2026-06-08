import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Center(
        child: Text(
          'AIDC Home!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
