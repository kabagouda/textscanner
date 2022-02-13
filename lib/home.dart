import 'dart:io';
import 'Image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool hasImage = false;
  File? image;
  String? imagePath;
  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageimageorary = File(image.path);
      setState(() {
        this.image = imageimageorary;
        imagePath = imageimageorary.path;
        hasImage = true;
      });
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File?> getCroppedFile(String path) async {
    File? croppedFile;

    croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black12,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    return croppedFile;
  }

  @override
  Widget build(BuildContext context) {
    var getInt = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Text Scanner OCR',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black38,
        elevation: 1,
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black26,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  _cameraMethod(context);
                },
                child: _buildContainer(
                    //Select Image from Camera
                    text: '${getInt.select_camera}'.toUpperCase(),
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    containerColor: Color.fromARGB(95, 39, 5, 102),
                    textColor: Colors.white),
              ),
              GestureDetector(
                onTap: () async {
                  _galleryMethod(context);
                },
                child: _buildContainer(
                    //Select Image from Gallery
                    text: '${getInt.select_gallery}'.toUpperCase(),
                    icon: Icon(
                      Icons.perm_media,
                      color: Colors.white,
                    ),
                    containerColor: Color.fromARGB(255, 3, 64, 114),
                    textColor: Colors.white),
              ),
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        // icon: Icons.add,
        child: Icon(
          Icons.add,
        ),
        activeIcon: Icons.close,
        backgroundColor: Color.fromARGB(255, 3, 64, 114),
        spacing: 3,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        visible: true,
        direction: SpeedDialDirection.up,
        renderOverlay: false,
        elevation: 8.0,
        isOpenOnStart: false,
        animationSpeed: 15,
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            backgroundColor: Color.fromARGB(255, 252, 138, 8),
            foregroundColor: Colors.white,
            label: 'Camera',
            onTap: () async {
              await _cameraMethod(context);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.photo_library),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Gallery',
            onTap: () async {
              await _galleryMethod(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _galleryMethod(BuildContext context) async {
    await getImage(ImageSource.gallery);
    if (hasImage == true) {
      //if hasImage crop and push to Image_Screen
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return Image_Screen(image: image);
        },
      ));
    }
  }

  Future<void> _cameraMethod(BuildContext context) async {
    await getImage(ImageSource.camera); //get image
    if (hasImage == true) {
      //if hasImage crop and push to Image_Screen
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return Image_Screen(image: image);
        },
      ));
    }
  }

  Widget _buildContainer(
      {required String text,
      required Icon icon,
      required Color containerColor,
      required Color textColor}) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(right: 5, left: 10),
      margin: EdgeInsets.only(right: 50, bottom: 20, left: 50),
      color: containerColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          icon,
          SizedBox(
            width: 15,
          ),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
