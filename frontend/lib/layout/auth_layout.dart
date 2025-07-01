import 'package:flutter/material.dart';

import '../widget/widget_exporter.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AuthLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 50, // adjust height as needed
                fit: BoxFit.contain,
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          forceMaterialTransparency: true,
          leading:
              Navigator.canPop(context)
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  )
                  : null,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 640,
              child: Center(
                child: ReusableCardWidget(
                  child: Padding(
                    padding: const EdgeInsets.all(83),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
