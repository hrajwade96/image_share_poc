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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("4 Images are already picked"),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 10),
            Text(
              'Selected Images: ${_images.length}/4',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _images.isEmpty
                  ? const Center(child: Text('No images selected'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_images[index], fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share,
                                          color: Colors.grey),
                                      onPressed: () =>
                                          shareFile(_images[index]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
