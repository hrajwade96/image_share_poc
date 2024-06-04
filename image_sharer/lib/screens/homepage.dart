import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (_images.length < 4) {
          _images.add(File(pickedFile.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("4 Images are already picked"),
          ));
        }
      });
    }
  }

  Future<void> shareFile(File image) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    debugPrint('${directory?.path} / ${image.path}');

    await WhatsappShare.shareFile(
      phone: '911234567890',
      filePath: [(image.path)],
    );
  }

  Future<bool?> isInstalled() async {
    final val = await WhatsappShare.isInstalled(
      package: Package.whatsapp,
    );

    if (kDebugMode) {
      print('Whatsapp is installed check: $val');
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload and Share'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(_images[index], fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.grey),
                          onPressed: () => shareFile(_images[index]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
