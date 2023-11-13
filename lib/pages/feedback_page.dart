import 'dart:html' as html;

import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  html.File? _selectedFile;
  String _fileName = "No file selected";

  void _pickFile() {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*,.pdf,.doc,.docx' // Modify this to restrict/select the files you want
      ..click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      setState(() {
        _selectedFile = file;
        _fileName = file.name;
      });
      // You can upload or process the file here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Feedback",
                hintText: "Enter your feedback...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Select File/Image'),
            ),
            const SizedBox(height: 10),
            Text('Selected File: $_fileName'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseStore.sendFeedback(_feedbackController.text, _selectedFile);
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
