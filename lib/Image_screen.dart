import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:text_scanner/result_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Image_Screen extends StatefulWidget {
  final File? image;
  Image_Screen({Key? key, required this.image}) : super(key: key);

  @override
  _Image_ScreenState createState() => _Image_ScreenState();
}

class _Image_ScreenState extends State<Image_Screen> {
  File? image;
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
            toolbarTitle: '${AppLocalizations.of(context)!.cropper}',//'Cropper',
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
  void initState() {
    image = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     var getInt = AppLocalizations.of(context)!;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Image', //'Preparing to extract text',
            style: TextStyle(color: Colors.white),
          ),
          actions: [IconButton(icon: Icon(Icons.done),onPressed: () => _navigate(context),)],
          backgroundColor: Colors.black38,
          elevation: 1,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: height / 1.5, child: Image.file(image!)),
            SizedBox(
              height: height / 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.crop),
                      onPressed: () async {
                        File? cropImage = await getCroppedFile(widget.image!.path);
                        setState(() {
                          image = cropImage;
                        });
                        // _navigate(context);
                      },
                    ),
                    Text('${getInt.resize}', //'Resize',
                    style: TextStyle(fontWeight:FontWeight.bold))
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () => _navigate(context),
                    ),
                    Text('${getInt.convert}'//'Convert'
                    ,
                    style: TextStyle(fontWeight:FontWeight.bold))
                  ],
                )
              ],
            )
          ],
        ));
  }

  Future<void> _navigate(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return Result(image: image);
      },
    ));
    // }
  }
}
