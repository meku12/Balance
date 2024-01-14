import 'package:flutter/material.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Page'),
      ),
      body: Center(
        child: const Text('This is the Work Page'),
      ),
    );
  }
}
