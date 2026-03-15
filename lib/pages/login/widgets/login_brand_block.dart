import 'package:flutter/material.dart';
import 'package:p2f/widgets/global/p2f_logo.dart';

class LoginBrandBlock extends StatelessWidget {
  const LoginBrandBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const P2fLogo(
      size: 110,
      borderRadius: 26,
      backgroundColor: Colors.transparent,
    );
  }
}
