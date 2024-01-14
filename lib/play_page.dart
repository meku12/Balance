import 'package:flutter/material.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Page'),
      ),
      body: Center(
        child: const Text('This is the Play Page'),
      ),
    );
  }
}