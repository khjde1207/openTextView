import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:open_textview/commonLibrary/HeroDialogRoute.dart';
import 'package:open_textview/component/OptionsBase.dart';
import 'package:open_textview/controller/MainCtl.dart';
import 'package:open_textview/items/Languages.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:permission_handler/permission_handler.dart';

// var isOpen = false;
class Option_OcrCtl extends GetxController {
  final isBackgroundPermissions = true.obs;
  final traineddataFiles = [].obs;
  final bDownloadawait = false.obs;
  @override
  void onInit() async {
    bool hasPermission = await FlutterBackground.hasPermissions;
    isBackgroundPermissions.value = hasPermission;
    isBackgroundPermissions.update((val) {});
    loadTraineData();

    super.onInit();
  }

  loadTraineData() async {
    Directory dir = Directory(await FlutterTesseractOcr.getTessdataPath());
    if (!dir.existsSync()) {
      dir.create();
    }
    traineddataFiles.clear();

    dir.list().forEach((element) async {
      traineddataFiles.add(element.path.split('/').last);
      update();
    });
  }
}

const traineddatas = [
  {
    'name': 'kor',
    'langname': '한글',
    'url':
        'https://github.com/tesseract-ocr/tessdata/raw/master/kor.traineddata'
  },
  {
    'name': 'kor_vert',
    'langname': '한글vert',
    'url':
        'https://github.com/tesseract-ocr/tessdata/raw/master/kor_vert.traineddata'
  },
  {
    'name': 'kor_lstm',
    'langname': '한글lstm',
    'url':
        'https://github.com/tesseract-ocr/tessdata_best/raw/master/kor.traineddata'
  },
  {
    'name': 'kor_lstm_vert',
    'langname': '한글lstm_vert',
    'url':
        'https://github.com/tesseract-ocr/tessdata_best/raw/master/kor_vert.traineddata'
  },
  {
    'name': 'eng',
    'langname': '영어',
    'url':
        'https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata'
  },
  {
    'name': 'eng_lstm',
    'langname': '영어lstm',
    'url':
        'https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata'
  },
];

class Option_Ocr extends OptionsBase {
  @override
  String get name => 'OCR 설정';
  void alertStoragePermissionError(path) {
    showDialog(
        context: Get.context,
        builder: (c) => AlertDialog(
              title: Text('백업 에러'),
              content: new Text('${path} 경로에 권한이 없습니다. 다른 경로를 선택해 주세요.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('닫기'),
                )
              ],
            ));
  }

  void downloadtrainedata(obj) async {
    // String targetFileName = obj['url'].split('/').last;
    var ctl = Get.find<Option_OcrCtl>();
    ctl.bDownloadawait.value = true;
    ctl.update();
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(obj['url']));
    HttpClientResponse response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    String dir = await FlutterTesseractOcr.getTessdataPath();

    File file = new File('$dir/${obj['name']}.traineddata');
    await file.writeAsBytes(bytes);
    ctl.bDownloadawait.value = false;
    ctl.update();
    ctl.loadTraineData();
  }

  @override
  void openSetting() async {
    Get.put(Option_OcrCtl());
    // openSettingLanguage();
    // bool isBackgroundPermissions = await FlutterBackground.hasPermissions;
    HeroPopup(
        tag: name,
        title: Row(children: [
          // buildIcon(),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700),
          )
        ]),
        callback: (completion) {},
        children: [
          Stack(children: [
            SizedBox(
                height: Get.height * 0.7,
                // width: Get.width * 0.9,
                child: ListView(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: GetBuilder<MainCtl>(
                      builder: (context) {
                        String langCode =
                            (controller.config['tts'] as Map)['language'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Divider(),
                            Row(
                              children: [
                                Expanded(
                                    flex: 7,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        controller.ocrData
                                            .update('brun', (value) => 0);
                                      },
                                      child: Text('OCR 강제 종료'),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(
                                    flex: 10,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await FlutterBackground
                                            .disableBackgroundExecution();
                                      },
                                      child: Text('백그라우드 작업 끄기'),
                                    )),
                              ],
                            ),
                            Divider(),
                            Text(
                              'OCR 기능을 위해 아래 기능을 설정 해주셔야 합니다.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            Text('1. OCR 작동중 꺼지는걸 방지 하기 위해 백그라운드 실행을 허용해 주세요.'),
                            GetX<Option_OcrCtl>(
                              builder: (ctl) {
                                if (ctl.isBackgroundPermissions.value) {
                                  return Text(
                                    '백그라운드 실행 이 허용 되었습니다.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  );
                                }
                                return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        var config =
                                            FlutterBackgroundAndroidConfig(
                                          notificationTitle: '오픈텍뷰',
                                          notificationText: 'ocr 실행중입니다.',
                                        );

                                        ctl.isBackgroundPermissions.value =
                                            await FlutterBackground.initialize(
                                                androidConfig: config);
                                        ctl.isBackgroundPermissions
                                            .update((val) {});
                                      },
                                      child: Text('백그라운드 작동 활성화'),
                                    ));
                              },
                            ),
                            Divider(),
                            Obx(() {
                              List langs =
                                  (controller.config['ocr'] as RxMap)['lang'] ??
                                      [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '2. ocr 적용할 언어를 선택해 주세요.',
                                  ),
                                  Container(
                                      height: 50,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        children: [
                                          ...traineddatas
                                              .map((e) => e['name'])
                                              .map((lan) {
                                            return TextButton.icon(
                                              // style: TextButton.styleFrom(
                                              //   primary: Colors.red, // foreground
                                              // ),
                                              // check_box_outline_blank
                                              icon: Icon(langs.indexOf(lan) >= 0
                                                  ? Icons.check_box
                                                  : Icons
                                                      .check_box_outline_blank),
                                              onPressed: () {
                                                RxMap conf = (controller
                                                    .config['ocr'] as RxMap);
                                                conf.update('lang', (value) {
                                                  List l = value ?? [];
                                                  int idx = l.indexOf(lan);
                                                  if (idx < 0) {
                                                    l.add(lan);
                                                  } else {
                                                    l.removeAt(idx);
                                                  }
                                                  return l;
                                                });
                                                // List target = conf['lang'];
                                                // target.add('kor');

                                                // lang = ;
                                              },
                                              label: Text('${lan}'),
                                            );
                                          }).toList()
                                        ],
                                      )),
                                  Divider(),
                                  Text(
                                      '3. OCR 처리 완료후 파일 저장 경로 를 선택해주세요(강제 종료시 저장하지 않습니다.)'),
                                  Text('[선택된경로]/OCR 폴더에 저장됩니다. '),
                                  Text(
                                      '선택된경로 : ${(controller.config['ocr'] as RxMap)['path']} ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ElevatedButton(
                                    onPressed: () async {
                                      FilePicker.platform
                                          .getDirectoryPath()
                                          .then((value) async {
                                        var status =
                                            await Permission.storage.status;
                                        if (!status.isGranted) {
                                          await Permission.storage.request();
                                        }

                                        DeviceInfoPlugin deviceInfo =
                                            DeviceInfoPlugin();
                                        AndroidDeviceInfo androidInfo =
                                            await deviceInfo.androidInfo;
                                        if (androidInfo.version.sdkInt >= 30) {
                                          status = await Permission
                                              .manageExternalStorage.status;
                                          if (!status.isGranted) {
                                            await Permission
                                                .manageExternalStorage
                                                .request();
                                          }
                                        }
                                        if (value != null) {
                                          Directory d =
                                              Directory('${value}/OCR');
                                          if (!d.existsSync()) {
                                            try {
                                              await d.create();
                                            } catch (e) {
                                              print(e);
                                              alertStoragePermissionError(
                                                  value);
                                              return;
                                            }
                                          }
                                          File f = File(
                                              '${d.path}/test11223344556677.txt');
                                          if (!f.existsSync()) {
                                            try {
                                              await f.create();
                                            } catch (e) {
                                              print(e);
                                              alertStoragePermissionError(
                                                  f.path);
                                              return;
                                            }
                                            f.delete();
                                          }
                                          (controller.config['ocr'] as RxMap)
                                              .update(
                                                  'path', (value) => d.path);
                                        }
                                      });
                                    },
                                    child: Text('ocr처리 이후 txt 파일 저장 경로 선택'),
                                  ),
                                ],
                              );
                            }),
                            Divider(),
                            Text('4. 학습데이터 를 다운로드 해주세요. 개당 15~25MB 사이입니다. '),
                            GetBuilder<Option_OcrCtl>(builder: (ctl) {
                              return Column(
                                // shrinkWrap: true,
                                children: [
                                  ...traineddatas.map((e) {
                                    String targetFileName =
                                        '${e['name']}.traineddata';
                                    // e['url'].split('/').last;

                                    return ListTile(
                                      title: Text(e['langname']),
                                      leading: Checkbox(
                                        value: ctl.traineddataFiles
                                                .indexOf(targetFileName) >=
                                            0,
                                        onChanged: (value) {},
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          downloadtrainedata(e);
                                        },
                                        child: Text(e['name']),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            })
                          ],
                        );
                      },
                    ),
                  ),
                ])),
            GetBuilder<Option_OcrCtl>(builder: (ctl) {
              if (ctl.bDownloadawait.value) {
                return Container(
                  height: Get.height * 0.7,
                  color: Colors.black26,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  )),
                );
              }
              return SizedBox();
            })
          ])
        ]);
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
        // Center(
        // child:
        Column(
          // padding: EdgeInsets.only(top: 0),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OCR',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        )
        // )

        // Icon(
        //   Icons.photo,
        // ),
        // Container(
        //     margin: EdgeInsets.only(left: 0, top: 0),
        //     child: Icon(
        //       Icons.format_color_text,
        //       color: Theme.of(Get.context).cardTheme.color,
        //       // size: 18,
        //     )),
      ],
    );
  }
}
