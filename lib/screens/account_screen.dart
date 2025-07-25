import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account'), centerTitle: true),
      body: SvgPicture.asset(
        'assets/svgs/dummy_screens/user_profile.svg',
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}
