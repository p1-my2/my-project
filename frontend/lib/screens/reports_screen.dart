import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Reports",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Card(
              elevation: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [

                    Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 20),

                    Text(
                      "No reports available",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Generate an analysis report after uploading and analysing a dataset.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}