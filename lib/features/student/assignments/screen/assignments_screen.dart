import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = [
      {
        'title': 'Flutter UI Project',
        'due': 'Tomorrow',
        'status': 'Pending',
      },
      {
        'title': 'Firebase Authentication',
        'due': '12 Sep 2026',
        'status': 'Pending',
      },
      {
        'title': 'Dart OOP Task',
        'due': '05 Sep 2026',
        'status': 'Submitted',
      },
      {
        'title': 'Mobile App Design',
        'due': '01 Sep 2026',
        'status': 'Marked',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final item = assignments[index];

          return Card(
            margin:
            const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
              const EdgeInsets.all(16),
              leading: CircleAvatar(
                child: Icon(
                  item['status'] == 'Marked'
                      ? Icons.check
                      : Icons.assignment,
                ),
              ),
              title: Text(
                item['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding:
                const EdgeInsets.only(top: 7),
                child: Text(
                  'Due: ${item['due']}',
                ),
              ),
              trailing: Text(
                item['status']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                  item['status'] == 'Marked'
                      ? Colors.green
                      : item['status'] ==
                      'Submitted'
                      ? Colors.blue
                      : Colors.orange,
                ),
              ),
              onTap: () {
                _showAssignment(context, item);
              },
            ),
          );
        },
      ),
    );
  }

  void _showAssignment(
      BuildContext context,
      Map<String, String> assignment,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                assignment['title']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Due: ${assignment['due']}',
              ),

              const SizedBox(height: 12),

              const Text(
                'Complete the assigned task and submit your work before the deadline.',
              ),

              const SizedBox(height: 24),

              if (assignment['status'] ==
                  'Pending')
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.upload_file,
                    ),
                    label: const Text(
                      'Submit Assignment',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}