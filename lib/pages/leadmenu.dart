import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authProvider.dart';

class Leadmenu extends StatelessWidget {
  const Leadmenu({super.key});

  @override
  Widget build(BuildContext context) {
    final globalUserId = Provider.of<AuthProvider>(context).userId ?? "Guest";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "👤 $globalUserId",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "XYZ  Quiz ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "give few minute for your Skill?",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
