import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../services/data_service.dart';

class ReflectionsScreen extends StatefulWidget {
  const ReflectionsScreen({super.key});

  @override
  State<ReflectionsScreen> createState() => _ReflectionsScreenState();
}

class _ReflectionsScreenState extends State<ReflectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ReflectionNote> _reflections = <ReflectionNote>[];

  @override
  void initState() {
    super.initState();
    _loadReflections();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadReflections() {
    _reflections = DataService().getReflections();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showReflectionDialog({ReflectionNote? note}) async {
    final TextEditingController titleController =
        TextEditingController(text: note?.title ?? '');
    final TextEditingController bodyController =
        TextEditingController(text: note?.content ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(note == null ? 'New Reflection' : 'Edit Reflection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String body = bodyController.text.trim();
                if (title.isEmpty || body.isEmpty) {
                  return;
                }

                final NavigatorState navigator = Navigator.of(dialogContext);
                final ScaffoldMessengerState messenger =
                    ScaffoldMessenger.of(context);

                final ReflectionNote updatedNote = ReflectionNote(
                  id: note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  type: note?.type ?? 'personal',
                  content: body,
                  date: note?.date ?? DateTime.now(),
                );

                await DataService().saveReflection(updatedNote);
                if (!mounted) {
                  return;
                }

                navigator.pop();
                _loadReflections();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      note == null
                          ? 'Reflection saved.'
                          : 'Reflection updated.',
                    ),
                  ),
                );
              },
              child: Text(note == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    bodyController.dispose();
  }

  Future<void> _confirmDelete(ReflectionNote note) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Reflection'),
          content: Text('Delete "${note.title}" from your reflections?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await DataService().deleteReflection(note.id);
    if (!mounted) {
      return;
    }

    _loadReflections();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final List<ReflectionNote> filteredNotes = _filteredNotes();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FB),
        elevation: 0,
        title: Text(
          'Reflections',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your reflections...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showReflectionDialog(),
                icon: const Icon(Icons.edit),
                label: const Text('Create New Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Recent Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (filteredNotes.isNotEmpty)
              ...filteredNotes.map((ReflectionNote note) => _buildNoteCard(context, note))
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _searchController.text.trim().isEmpty
                      ? 'No notes yet. Create one from any lesson or from this screen.'
                      : 'No reflections match your search.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 40),
            _buildEncouragementCard(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<ReflectionNote> _filteredNotes() {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _reflections;
    }

    return _reflections.where((ReflectionNote note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.type.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildNoteCard(BuildContext context, ReflectionNote note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${note.type.toUpperCase()} NOTE',
                        style: const TextStyle(
                          color: Color(0xFFC7A962),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(note.date),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showReflectionDialog(note: note),
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit note',
                ),
                IconButton(
                  onPressed: () => _confirmDelete(note),
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete note',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncouragementCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Study Reminder',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Use this space to capture what God is teaching you through each Sunday School lesson. Short notes are fine. Consistency matters more than length.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
