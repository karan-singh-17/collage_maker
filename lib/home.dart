import 'dart:io';
import 'dart:typed_data';
import 'package:collage_maker_karan_singh/storing_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import 'editing_page.dart';
import 'model/image_model.dart';

class home_page extends StatefulWidget {
  const home_page({Key? key}) : super(key: key);

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  List<String> _selectedImagePaths = [];
  List<ImageData> _images = [];

  Offset _offset = const Offset(100, 250);
  double _scale = 1;
  double _previousScale = 0.1;

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      String? editedImagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              edit_page(image_path: pickedImage.path),
        ),
      );
      if(editedImagePath != null){
        setState(() {
          _selectedImagePaths.add(editedImagePath);
          _images.add(ImageData(path: editedImagePath, offset: _offset, scale: 1));
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Image Collage"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_sharp),
            onPressed: (){
              setState(() {
                _selectedImagePaths = [];
                _images = [];
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveScreenshot,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: (_images.isEmpty) ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.image_outlined,size: 60,color: Colors.grey,) ,
                ),
                SizedBox(height: 20,),
                Text("Click on  +  to add your first image" , style: TextStyle(color: Colors.grey),)
              ],
            )
            
            : Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Screenshot(
                controller: screenshotController,
                child: Stack(
                  children: _images.map((imageData) {
                    int index = _images.indexOf(imageData);
                    double topOffset = imageData.offset.dy + (index * 20.0);
                    double leftOffset = imageData.offset.dx + (index * 20.0);
                    return Positioned(
                      left: leftOffset,
                      top: topOffset,
                      child: LongPressDraggable(
                        feedback: Stack(
                          children: [
                            Image.file(
                              File(imageData.path),
                              height: 200,
                              color: Colors.deepPurple.shade100,
                              colorBlendMode: BlendMode.colorBurn,
                            ),
                          ],
                        ),
                        childWhenDragging: Container(),
                        child: GestureDetector(
                          onScaleStart: (details) {
                            _previousScale = imageData.scale;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              imageData.scale = _previousScale * details.scale;
                            });
                          },
                          child: Stack(
                            children: [
                              Transform.scale(
                                scale: imageData.scale,
                                child: InkWell(
                                  onDoubleTap: () {
                                    setState(() {
                                      imageData.scale = 1.0;
                                    });
                                  },
                                  child: Image.file(
                                    File(imageData.path),
                                    height: 200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onDragEnd: (details) {
                          setState(() {
                            double adjustment = MediaQuery.of(context).size.height -
                                constraints.maxHeight;
                            imageData.offset = Offset(
                                details.offset.dx, details.offset.dy - adjustment);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveScreenshot() async {
    try {
      if (_images.isNotEmpty) {
      Uint8List? screenshot = await screenshotController.capture();
      if (screenshot != null) {
        ImageStorage.saveImage_screens(screenshot, "dsfdg");
        /*final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/collage.png';
        File imageFile = File(imagePath);
        await imageFile.writeAsBytes(screenshot);*/

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Saved"),
              content: Text("Collage saved successfully."),
              actions: [
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.check),
                      //child: Text("OK"),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    }else{
        showDialog(context: context,
            builder: (BuildContext context){
          return AlertDialog(
            content: Text("Add Some Images first"),
          );
            });
      }
    } catch (e) {
      print("Error saving screenshot: $e");
    }
  }
}
