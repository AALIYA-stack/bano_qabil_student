import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Learning Progress',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _ProgressCard(
            title: 'Modules Completed',
            value: '8 / 12',
            progress: .67,
          ),

          _ProgressCard(
            title: 'Attendance',
            value: '87%',
            progress: .87,
          ),

          _ProgressCard(
            title: 'Assignment Average',
            value: '82%',
            progress: .82,
          ),

          const SizedBox(height: 25),

          const Text(
            'Career Readiness',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text('CV'),
              subtitle: Text(
                'CV preparation completed',
              ),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text('GitHub'),
              subtitle: Text(
                'GitHub profile created',
              ),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.radio_button_unchecked,
              ),
              title: Text('3 Projects'),
              subtitle: Text(
                'Complete three portfolio projects',
              ),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.radio_button_unchecked,
              ),
              title: Text('Mock Interview'),
              subtitle: Text(
                'Attend a mock interview',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
      const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius:
              BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}