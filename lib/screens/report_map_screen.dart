import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReportMapScreen extends StatelessWidget {
  const ReportMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Map'), centerTitle: true),
      body: SvgPicture.asset(
        'assets/svgs/dummy_screens/user_report_map.svg',
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}
