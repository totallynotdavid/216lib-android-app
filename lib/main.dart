import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(
    url: 'https://vjtcpvdllgblxwymjvib.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqdGNwdmRsbGdibHh3eW1qdmliIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg1MTE1NzQsImV4cCI6MjAwNDA4NzU3NH0.CeTvw_nk69GFF2N_1JyC13xXXW_UHVXANyCM6g8WaNE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Opening Reporter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openLibrary() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConfirmationScreen(image: image)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Opener"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openLibrary,
          child: const Text("Report Opening"),
        ),
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  final XFile image;

  const ConfirmationScreen({super.key, required this.image});

  Future<void> uploadImageAndRecord(BuildContext context) async {
    var fileBytes = File(image.path).readAsBytesSync();
    var fileName = image.name;

    var response = await http.post(
      Uri.parse('YOUR-SUPABASE-FUNCTION-URL'),
      headers: {"Content-Type": "application/json"},
      body: {
        'image': fileBytes,
        'name': fileName,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Image uploaded and recorded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Opening")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(image.path)),
          ),
          ElevatedButton(
            onPressed: () => uploadImageAndRecord(context),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
