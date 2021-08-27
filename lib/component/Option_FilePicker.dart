import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:open_textview/component/OptionsBase.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class Option_FilePicker extends OptionsBase {
  BuildContext context = null;

  @override
  String get name => '파일 탐색기';

  @override
  Widget build(BuildContext context) {
    // TESTopenSetting();
    this.context = context;

    // TODO: implement build
    return IconButton(
      onPressed: () {
        openSetting();
        // openSetting();
      },
      icon: buildIcon(),
      // Text('tts필터')
    );
  }

  @override
  Widget buildIcon() {
    // TODO: implement buildIcon
    return Icon(
      Icons.folder_open,
    );
  }

  bReadyOcr() async {
    if (await FlutterBackground.hasPermissions) {
      bool rtn = false;
      Directory dir = Directory(await FlutterTesseractOcr.getTessdataPath());
      rtn = (await dir.list().length > 0);
      Directory ocrdir = Directory((controller.config['ocr'] as RxMap)['path']);
      rtn = ocrdir.existsSync();
      File f = File('${ocrdir.path}/test1234567890.txt');
      try {
        await f.create();
        await f.delete();
      } catch (e) {
        rtn = false;
      }

      return rtn;
    }
    return false;
  }

  @override
  void openSetting() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: //---
          await bReadyOcr() ? ['txt', 'zip', '7z'] : ['txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile platformfile = result.files.first;
      RxMap picker = controller.config['picker'];

      // if (controller.ocrData['brun'] == 1 &&
      //     (platformfile.extension == "zip" || platformfile.extension == "7z")) {
      //   controller.ocrData.update('brun', (value) => 0);
      //   Future.delayed(const Duration(seconds: 5000), () {
      //     picker.assignAll({
      //       'name': platformfile.name,
      //       'bytes': platformfile.bytes,
      //       'size': platformfile.size,
      //       'extension': platformfile.extension,
      //       'path': platformfile.path,
      //     });
      //   });
      // } else {
      picker.assignAll({
        'name': platformfile.name,
        'bytes': platformfile.bytes,
        'size': platformfile.size,
        'extension': platformfile.extension,
        'path': platformfile.path,
      });
      // }

      // controller.update();
      // ---------- 마지막 연 파일은 캐시에 남기고 다른 캐시 삭제 로직 --------
      // Directory tempDir = await getTemporaryDirectory();
      // Directory filpikerDir = Directory(tempDir.path + '/file_picker');
      // List fileList = filpikerDir.listSync();
      // fileList.forEach((element) {
      //   String fileName = element.path.split('/').last;
      //   if (platformfile.name != fileName) {
      //     (element as File).delete();
      //   }
      // });

      // controller.update();
    }
  }
}
