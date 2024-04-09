import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:collage_maker_karan_singh/storing_image.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class edit_page extends StatefulWidget {
  final String image_path;
  const edit_page({super.key, required this.image_path});

  @override
  State<edit_page> createState() => _edit_pageState();
}

class _edit_pageState extends State<edit_page> {
  late CustomImageCropController controller;


  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () async {
              final image = await controller.onCropImage();
              if(image != null){
                Uint8List bytes = image.bytes;
                List<String> parts = widget.image_path.split('/');
                String lastSegment = parts.last;
                String imagePath = await ImageStorage.saveImage(bytes, lastSegment);
                if(imagePath != null) {
                  Navigator.pop(context, imagePath);
                }
              }
              //Navigator.pop(context, widget.image_path);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomImageCrop(
              shape: CustomCropShape.Square,
              //forceInsideCropArea: true,
              canRotate: false,
              cropController: controller,
              image: FileImage(File(widget.image_path)),
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: controller.reset),
              IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => controller.addTransition(CropImageData(scale: 1.33))),
              IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => controller.addTransition(CropImageData(scale: 0.75))),
              IconButton(icon: const Icon(Icons.rotate_left), onPressed: () => controller.addTransition(CropImageData(angle: -pi / 4))),
              IconButton(icon: const Icon(Icons.rotate_right), onPressed: () => controller.addTransition(CropImageData(angle: pi / 4))),
              /*IconButton(
                icon: const Icon(Icons.crop),
                onPressed: () async {
                  final image = await controller.onCropImage();
                  if(image != null){
                    Uint8List bytes = image.bytes;
                    List<String> parts = widget.image_path.split('/');
                    String lastSegment = parts.last;
                    String imagePath = await ImageStorage.saveImage(bytes, lastSegment);
                    if(imagePath != null) {
                      Navigator.pop(context, imagePath);
                    }
                  }
                },
              ),*/
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      )
    );
  }
}
