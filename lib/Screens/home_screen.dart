import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary App'),
      ),
      body: Container(
        height: s.height,
        width: s.width,
        child: Column(
          children: [
            Text('Dictionary App'),
          ],
        ),
      ),
    );
  }
}
