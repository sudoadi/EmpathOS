import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';

class FaceCameraScreen extends StatefulWidget {
  const FaceCameraScreen({Key? key}) : super(key: key);

  @override
  State<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends State<FaceCameraScreen> {
  File? _capturedImage;
  late FaceCameraController controller;

  @override
  void initState() {
    super.initState();
    controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        setState(() => _capturedImage = image);
      },
      onFaceDetected: (Face? face) {
        // Do something when a face is detected (if needed)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FaceCamera Example App'),
      ),
      body: Builder(builder: (context) {
        if (_capturedImage != null) {
          return Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.file(
                  _capturedImage!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await controller.startImageStream();
                    setState(() => _capturedImage = null);
                  },
                  child: const Text(
                    'Capture Again',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          );
        }
        return SmartFaceCamera(
          controller: controller,
          messageBuilder: (context, face) {
            if (face == null) {
              return _message('Place your face in the camera');
            }
            if (!face.wellPositioned) {
              return _message('Center your face in the square');
            }
            return const SizedBox.shrink();
          },
        );
      }),
    );
  }

  Widget _message(String msg) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
    child: Text(
      msg,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 14, height: 1.5, fontWeight: FontWeight.w400),
    ),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
