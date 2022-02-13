import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:text_scanner/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Result extends StatefulWidget {
  final File? image;
  Result({Key? key, required this.image}) : super(key: key);

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  var textDetector = GoogleMlKit.vision.textDetector();
  String scanText = '';
  bool scanEnd = false;

  bool isEdit = false;

  String? editvalue;

  Future getText(File file) async {
    final inputImage = InputImage.fromFile(file);
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          setState(() {
            scanText = scanText + '  ' + element.text;
          });
        }
        scanText = scanText + '\n';
      }
    }
    setState(() {
      scanEnd = true;
    });
  }

  @override
  void initState() {
    getText(widget.image!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var _getIntl = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${ _getIntl.result}',
         // 'Result',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black38,
      ),
      body: scanEnd == false
          ? _buildShimmer()
          : Container(
              color: Colors.black12,
              child: scanText == ''
                  ? _buildDetectedText()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1.7 /
                                              3,
                                      child: _buildTextField(),
                                      padding: EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        borderRadius: BorderRadius.circular(5),
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: isEdit == false
                                            ? Center()
                                            : TextButton.icon(
                                                style: TextButton.styleFrom(
                                                    primary: Colors.black),
                                                icon: Icon(Icons.save),
                                                label: Text('${_getIntl.save_modify_text}'//'Save modify text'
                                                ),
                                                onPressed: () async {
                                                  setState(() {
                                                    scanText = editvalue!;
                                                    isEdit = false;
                                                  });
                                                  await _launchMaterialBanner(
                                                      context,
                                                      bannerText:'${_getIntl.text_modified}'
                                                          // 'Text modified '
                                                        );
                                                },
                                              ))
                                  ]),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                        height: height * 1 / 3,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: Image.file(
                                          widget.image!,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildBottomBar(context),
                        )
                      ],
                    ),
            ),
    );
  }

  Future<void> _launchMaterialBanner(BuildContext context,
      {required String bannerText}) async {
    ScaffoldMessenger.of(context)
        .showMaterialBanner(_buildMaterialBanner(bannerText));
    await Future.delayed(const Duration(seconds: 10), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomBarButton(
              icon: Icons.content_copy_outlined,
              text: '${ AppLocalizations.of(context)!.copy_the_text}',//'Copy the text',
              onTap: () async {
                Clipboard.setData(ClipboardData(text: scanText));
                await _launchMaterialBanner(
                  context,
                  bannerText: '${ AppLocalizations.of(context)!.copy_to_clipboard}'//'Copy to Clipboard',
                );
              }),
          _buildBottomBarButton(
              icon: Icons.reply_outlined,
              text: '${ AppLocalizations.of(context)!.share}',//'Share',
              onTap: () async {
                await Share.share(scanText);
              }),
          _buildBottomBarButton(
              icon: Icons.cancel,
              text: '${ AppLocalizations.of(context)!.close}',//'Close',
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return Home();
                  },
                ));;
              })
        ],
      ),
    );
  }

  Widget _buildDetectedText() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${AppLocalizations.of(context)!.detected_text}'
        //'We are not detect any text , Please choose another image containing text',
        ,style: TextStyle(color: Colors.red),
      ),
    ));
  }

  Widget _buildBottomBarButton(
      {required IconData icon,
      required String text,
      required void Function()? onTap}) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.black,
            ),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  MaterialBanner _buildMaterialBanner(String text) {
    return MaterialBanner(
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black38,
      actions: [
        TextButton(
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Center(
      child: SizedBox(
        width: 200.0,
        height: 100.0,
        child: Shimmer.fromColors(
          baseColor: Colors.black38,
          highlightColor: Colors.black,
          child: Text(
            'Wait ...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      initialValue: scanText,
      maxLines: null,
      decoration: InputDecoration(border: InputBorder.none),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          editvalue = value;
          isEdit = true;
        });
      },
      onFieldSubmitted: (value) {
        setState(() {
          scanText = value;
        });
      },
    );
  }
}
