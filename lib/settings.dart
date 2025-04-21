import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String walletAddress;

  const SettingsPage({super.key, required this.walletAddress});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final int _limit = 5;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<DocumentSnapshot> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('projects')
        .where('walletAddress', isEqualTo: widget.walletAddress)
        .orderBy('createdAt', descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();
    if (querySnapshot.docs.length < _limit) {
      _hasMore = false;
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
      _projects.addAll(querySnapshot.docs);
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _editProject(DocumentSnapshot doc) {
    final nameController = TextEditingController(text: doc['name']);
    final descController = TextEditingController(text: doc['description']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await doc.reference.update({
                'name': nameController.text,
                'description': descController.text,
              });
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await doc.reference.delete();
      setState(() {
        _projects.remove(doc);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Projects')),
      body: ListView.builder(
        itemCount: _projects.length + 1,
        itemBuilder: (context, index) {
          if (index == _projects.length) {
            if (_hasMore) {
              _fetchProjects();
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No more projects')),
              );
            }
          }

          final doc = _projects[index];
          final name = doc['name'];
          final desc = doc['description'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(desc),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editProject(doc),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProject(doc),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
