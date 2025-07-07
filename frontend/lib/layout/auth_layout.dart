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
              const SizedBox(width: 13),
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
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/1.jpg', // 👉 your background image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Center(
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
          ],
        ),
      ),
    );
  }
}
