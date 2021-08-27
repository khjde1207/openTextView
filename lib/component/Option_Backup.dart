import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:get/get.dart';
import 'package:open_textview/commonLibrary/HeroDialogRoute.dart';
import 'package:open_textview/component/OptionsBase.dart';
import 'package:permission_handler/permission_handler.dart';

// var isOpen = false;

class Option_Backup extends OptionsBase {
  @override
  String get name => '뱩업/복구';

  @override
  void openSetting() async {
    String contents = '''
        {"config" : ${jsonEncode(controller.config)},"history" : ${jsonEncode(controller.history)}}
        ''';
    HeroPopup(
        tag: name,
        title: Text.rich(TextSpan(children: [
          TextSpan(
            text: name,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' (복구후엔 어플을 재실행 해 주세요.)',
            style: Theme.of(Get.context).textTheme.bodyText1,
          ),
        ])),
        callback: (completion) {},
        children: [
          ElevatedButton(
            onPressed: () async {
              FilePicker.platform.getDirectoryPath().then((value) async {
                if (value != null) {
                  var status = await Permission.storage.status;

                  if (!status.isGranted) {
                    await Permission.storage.request();
                  }
                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                  if (androidInfo.version.sdkInt >= 30) {
                    status = await Permission.manageExternalStorage.status;
                    if (!status.isGranted) {
                      await Permission.manageExternalStorage.request();
                    }
                  }
                  Directory d = Directory(value);
                  File f = File('${d.path}/opentextview_backup.json');
                  if (!f.existsSync()) {
                    try {
                      await f.create();
                    } catch (e) {
                      showDialog(
                          context: Get.context,
                          builder: (c) => AlertDialog(
                                title: Text('백업 에러'),
                                content: new Text(
                                    '${d.path} 경로에 권한이 없습니다. 다른 경로를 선택해 주세요.'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Get.back(),
                                    child: Text('닫기'),
                                  )
                                ],
                              ));
                      return;
                    }
                  }
                  f.writeAsString(contents);
                  showDialog(
                      context: Get.context,
                      builder: (c) => AlertDialog(
                            title: Text('백업'),
                            content: new Text('${f.path} 경로에 백업 되었습니다.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                child: Text('닫기'),
                              )
                            ],
                          ));
                }
              });

              // Clipboard.setData(ClipboardData(text: contents));
            },
            child: Text('백업'),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          ElevatedButton(
            onPressed: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: false,
                allowedExtensions: ['json'],
              );

              if (result.files.isNotEmpty) {
                PlatformFile platformfile = result.files.first;
                File file = File(platformfile.path);
                Uint8List u8list = file.readAsBytesSync();
                DecodingResult decodeContents =
                    await CharsetDetector.autoDecode(u8list);

                String contents = decodeContents.string;
                try {
                  var json = jsonDecode(contents);
                  if ((json['config'] as Map).isEmpty &&
                      (json['history'] as List).isEmpty) {
                    return;
                  }
                  showDialog(
                      context: Get.context,
                      builder: (c) => AlertDialog(
                            title: Text('파일 내용'),
                            content: SingleChildScrollView(
                              child: Text(contents),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                child: Text('취소'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  controller.setConfig((json['config'] as Map),
                                      (json['history'] as List));
                                  Get.back(); // 현재 팝업 닫기
                                  Get.back();
                                },
                                child: Text('적용'),
                              )
                            ],
                          ));
                } catch (e) {}
              }
            },
            child: Text('복구'),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(contents),
          )
        ]);

    // TODO: implement openSetting
  }

  void TESTopenSetting() {
    // if (!isOpen) {
    Get.back();
    // return;
    // }
    Future.delayed(const Duration(milliseconds: 300), () {
      openSetting();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TESTopenSetting();
    return Hero(
        tag: name,
        child: Material(
            type: MaterialType.transparency, // likely needed
            child: IconButton(
                onPressed: () {
                  openSetting();
                },
                icon: buildIcon())));
  }

  @override
  Widget buildIcon() {
    return Stack(
      children: [
        Icon(
          Icons.backup_sharp,
        ),
      ],
    );
  }
}
