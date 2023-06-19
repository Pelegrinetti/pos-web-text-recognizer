import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTextScanning = false;
  XFile? imageFile;
  String scannedText = '';

  void getImage(ImageSource imageSource) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: imageSource);

      if (pickedImage != null) {
        isTextScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognizedText(pickedImage);
      }
    } catch (e) {
      isTextScanning = false;
      imageFile = null;
      scannedText = 'Oops! Não foi possível realizar a operação.';
      setState(() {});
    }
  }

  void getRecognizedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = '$scannedText${line.text}\n';
      }
    }
    isTextScanning = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecimento de texto em imagem'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isTextScanning) const CircularProgressIndicator(),
              if (!isTextScanning && imageFile == null)
                Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: Color.fromRGBO(226, 226, 226, 1),
                  ),
                ),
              if (imageFile != null) Image.file(File(imageFile!.path)),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Selecionar imagem'),
              ),
              const SizedBox(height: 10),
              Container(
                width: 300,
                height: 200,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  color: Color.fromRGBO(226, 226, 226, 1),
                ),
                child: TextButton(
                  onPressed: scannedText != '' ? () async {
                    await Clipboard.setData(ClipboardData(text: scannedText));
                  } : null,
                  child:
                      Text(scannedText, style: const TextStyle(fontSize: 20, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Dica: Clique no texto para copiar.',
                style: TextStyle(color: Colors.grey.shade800),
              )
            ],
          ),
        ),
      )),
    );
  }
}
