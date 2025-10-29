import 'package:flutter/material.dart';

class PatientMedia extends StatelessWidget {
  const PatientMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No media found!",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
