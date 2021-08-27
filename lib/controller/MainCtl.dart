import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:open_textview/controller/MainAudio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:image/image.dart' as im;
import 'dart:ui' as ui;

class FindObj {
  FindObj({this.pos, this.contents});
  int pos;
  String contents;
}

class MainCtl extends GetxController {
  final itemScrollctl = ItemScrollController();
  final itemPosListener = ItemPositionsListener.create();
  final curPos = 0.obs;

  final contents = [].obs;

  // 기능 영역
  // --- 검색기능 ---
  final findText = "".obs;
  final findList = List<FindObj>.empty().obs;

  final LocalStorage storage = new LocalStorage('opentextview');

  final playState = false.obs;

  final ocrData = {
    "total": 0,
    "current": 0,
    "brun": 0,
  }.obs;
  final history = [].obs;
  final config = {
    "theme": [].obs,
    "tts": {
      // 'language': 'ko-KR',
      'speechRate': 1.toDouble(),
      'volume': 1.toDouble(),
      'pitch': 1.toDouble(),
      'groupcnt': 1,
      'headsetbutton': false,
      'audiosession': true,
    }.obs,
    "filter": [].obs,
    "nav": [].obs, // 하단 네비게이션바
    "picker": {}.obs,
    "ocr": {
      "path": "",
      "lang": [],
    }.obs
  }.obs;

  final imgFiles = [].obs;
  final isScroll = false.obs;

  void onScroll() {
    // 스크롤 중에 이동 방지
    isScroll.update((val) => true);

    var min = itemPosListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge > 0)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;

    curPos.value = min;
    int whereIdx = history.indexWhere((element) {
      return element['name'] == (config['picker'] as Map)['name'];
    });
    DateTime now = DateTime.now();
    DateFormat formatter = new DateFormat('yyyy-MM-dd hh-mm-ss');
    // if (curPos.value > 0) {
    // }

    if (whereIdx >= 0) {
      history[whereIdx]['pos'] = curPos.value;
      history[whereIdx]['date'] = formatter.format(now);
      history.refresh();
    }
    update(['scroll']);
  }

  @override
  void onInit() async {
    super.onInit();

    if (!AudioService.connected) {
      await AudioService.connect();
    }

    AudioService.currentMediaItemStream.listen((event) {
      if (event?.extras != null) {
        if (!isScroll.value) {
          itemScrollctl.jumpTo(
              index: event.extras['pos'] as int, alignment: 0.1);
        }
        curPos.value = event.extras['pos'];
        curPos.update((val) {});
      }
      // itemScrollctl.jumpTo(index: event.extras['pos']);
    });

    itemPosListener.itemPositions.addListener(onScroll);

    debounce(isScroll, (v) {
      if (v) {
        isScroll.update((val) {
          return false;
        });
      }
    }, time: Duration(milliseconds: 500));
    // 설정 이벤트
    ever(config['theme'], changeTheme);
    debounce(config['tts'], (ttsConf) async {
      // tts 옵션 변경시 tts 옵션 처리 로직 부분 .
      if (AudioService.runningStream.value) {
        AudioService.customAction('tts', ttsConf);
      }
    }, time: Duration(milliseconds: 500));
    debounce(config['filter'], (filterList) {
      // tts 음성 시 무시하거나 대체될 로직 부분 ,
      if (AudioService.runningStream.value) {
        AudioService.customAction('filter', filterList);
      }
    }, time: Duration(milliseconds: 500));

    debounce(config['picker'], (v) async {
      if (ocrData['brun'] == 1) {
        ocrData.update('brun', (value) => 0);
        await Future.delayed(const Duration(milliseconds: 4000));
      }
      if ((v as Map).isNotEmpty && v['extension'] == 'zip') {
        File f = File(
            '${(config['ocr'] as RxMap)['path']}/${v['name'].split('.')[0]}.txt');
        if (f.existsSync()) {
          showDialog(
              context: Get.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("openTextView"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "이미 ocr 이 완료된 파일 입니다. OCR작업 하시겠습니까?",
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      child: new Text("취소"),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    ElevatedButton(
                      child: new Text("작업"),
                      onPressed: () {
                        jobOcr(v);
                        Get.back();
                      },
                    ),
                  ],
                );
              });
          return;
        }
        jobOcr(v);
      }
      if ((v as Map).isNotEmpty && v['extension'] == 'txt') {
        File file = File(v['path']);
        if (file.existsSync()) {
          if (AudioService.runningStream.value) {
            AudioService.stop();
          }
          Uint8List u8list = file.readAsBytesSync();
          String decodeContents;
          try {
            DecodingResult decodingResult = await CharsetDetector.autoDecode(
              u8list,
            );
            decodeContents = decodingResult.string;
          } catch (e) {
            decodeContents = await CharsetConverter.decode('EUC-KR', u8list);
          }
          // contents.assignAll([]);
          contents.clear();

          contents.assignAll(decodeContents.split('\n'));
          update();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            int whereIdx = history.indexWhere((element) {
              return element['name'] == (config['picker'] as Map)['name'];
            });
            DateTime now = DateTime.now();
            DateFormat formatter = new DateFormat('yyyy-MM-dd hh-mm-ss');
            if (whereIdx < 0) {
              history.add(
                  {'name': v['name'], 'pos': 0, 'date': formatter.format(now)});
              itemScrollctl.jumpTo(index: 0, alignment: 0.1);
            } else {
              itemScrollctl.jumpTo(
                  index: history[whereIdx]['pos'] as int, alignment: 0.1);
              history[whereIdx]['date'] = formatter.format(now);
            }
            itemPosListener.itemPositions.addListener(onScroll);
          });
        }
      }
    }, time: Duration(milliseconds: 300));

    // [*]--------------[*]
    // 옵션 로드 / 공통 이벤트 처리 로직
    // [*]--------------[*]
    await storage.ready;

    // 초기 설정 파일 로드
    // print('초기 설정 파일 로드');
    // print(storage.getItem('config'));
    // print(storage.getItem('history'));
    // print('초기 설정 파일 로드 end');
    try {
      assignConfig(storage.getItem('config') ?? {});
      assignHistory(storage.getItem('history') ?? []);
    } catch (e) {
      // storage.clear();
    }

    // save config , 초기 설정 로드 후 저장 이벤트 를 셋팅 한다.
    config.keys.forEach((key) {
      debounce(config[key], (v) async {
        await storage.ready;
        await storage.setItem('config', config.toJson());
      }, time: Duration(milliseconds: 400));
    });

    debounce(history, (v) async {
      await storage.ready;
      await storage.setItem('history', history.toJson());
    }, time: Duration(milliseconds: 500));
  }

  void jobOcr(v) async {
    File file = File(v['path']);
    if (file.existsSync()) {
      imgFiles.clear();
      Directory unzipDir =
          Directory('${file.parent.path}/${v['name'].split('.')[0]}');

      await ZipFile.extractToDirectory(
          zipFile: file,
          destinationDir: unzipDir,
          onExtracting: (zipEntry, progress) {
            if (!zipEntry.isDirectory) {
              String ex = zipEntry.name.split('.').last;
              if (ex == 'gif' || ex == 'jpg' || ex == 'png') {
                imgFiles.add('${unzipDir.path}/${zipEntry.name}');
              }
            }
            if (File('${unzipDir.path}/${zipEntry.name}').existsSync()) {
              return ZipFileOperation.skipItem;
            }
            return ZipFileOperation.includeItem;
          });
      DateTime now = DateTime.now();
      DateFormat formatter = new DateFormat('yyyy-MM-dd hh-mm-ss');
      int whereIdx = history.indexWhere((element) {
        return element['name'] == (config['picker'] as Map)['name'];
      });
      if (whereIdx < 0) {
        history
            .add({'name': v['name'], 'pos': 0, 'date': formatter.format(now)});
      }
      // return;

      contents.clear();

      imgFiles.sort((a, b) {
        return a.compareTo(b);
      });
      // return;
      ocrData.update('total', (value) => imgFiles.length);

      await FlutterBackground.initialize(
          androidConfig: FlutterBackgroundAndroidConfig(
        notificationTitle: '오픈텍뷰',
        notificationText: 'ocr 실행중입니다.',
      ));
      await FlutterBackground.enableBackgroundExecution();
      ocrData.update('brun', (value) => 1);

      for (int i = 0; i < imgFiles.length; i++) {
        if (ocrData['brun'] == 0) {
          break;
        }
        ocrData.update('current', (value) => i + 1);

        // print(
        //     '${(config['ocr'] as RxMap)['path']}${imgFiles[i].toString().split('/').last}_ocr.jpg');
        // File(
        //     '${(config['ocr'] as RxMap)['path']}${imgFiles[i].toString().split('/').last}_ocr.jpg')
        //   ..writeAsBytesSync(im.encodeJpg(image));
        im.Image image =
            im.decodeImage(File(imgFiles[i].toString()).readAsBytesSync());
        image = im.adjustColor(
          image.clone(),
          gamma: 5,
        );
        File('${imgFiles[i].toString()}_ocr.jpg')
          ..writeAsBytesSync(im.encodeJpg(image));
        // print(i);
        String conv = await _ocr('${imgFiles[i].toString()}_ocr.jpg');
        if (conv.split('   ').length > 3) {
          im.Image image =
              im.decodeImage(File(imgFiles[i].toString()).readAsBytesSync());
          image = im.adjustColor(
            image.clone(),
            gamma: 20,
          );
          File('${imgFiles[i].toString()}_ocr.jpg')
            ..writeAsBytesSync(im.encodeJpg(image));
          conv = await _ocr('${imgFiles[i].toString()}_ocr.jpg');
        }
        // String text = await FlutterTesseractOcr.extractText(
        //     '${imgFiles[i].toString()}_ocr.jpg',
        //     language: ((config['ocr'] as RxMap)['lang'] as List).join("+"),
        //     args: {
        //       "psm": "4",
        //       "preserve_interword_spaces": "1",
        //     });
        // text = text.replaceAll('"\n', '___QWER!@#"___');
        // text = text.replaceAll('”\n', '___QWER!@#”___');
        // text = text.replaceAll('\'\n', '___QWER!@#\'___');
        // text = text.replaceAll('’\n', '___QWER!@#’___');
        // text = text.replaceAll('.\n', '___QWER!@#!!___');
        // text = text.replaceAll('\n\n', '___QWER!@#___');
        // text = text.replaceAll('\n', '');

        // text = text.replaceAll('___QWER!@#___', '\n\n');
        // text = text.replaceAll('___QWER!@#!!___', '.\n\n');
        // text = text.replaceAll('___QWER!@#’___', '’\n');
        // text = text.replaceAll('___QWER!@#"___', '"\n');
        // text = text.replaceAll('___QWER!@#”___', '”\n');
        // text = text.replaceAll('___QWER!@#\'___', '\'\n');

        var arr = conv.split('\n');
        if (contents.isNotEmpty) {
          int len = contents.last.length - 1 ?? 0;
          if (contents.last
                  .lastIndexOf(RegExp('\\.|"|\'|”|’|\\!|\\?|\\\|\\)|\\]')) <
              len) {
            contents.last += ' ' + arr.first;
            arr.removeAt(0);
          }
        }

        contents.addAll(arr);
        // contents 업데이트후 tts 작동 중이면 tts 에 contents 도 같이 갱신 해줘야함.
        if (AudioService.runningStream.value) {
          AudioService.customAction('contents', contents);
        }
        update();
      }
      if (ocrData['brun'] == 1) {
        File f = File(
            '${(config['ocr'] as RxMap)['path']}/${v['name'].split('.')[0]}.txt');
        if (!f.existsSync()) {
          f.create();
        }
        f.writeAsString(contents.join('\n'));
      }
      ocrData.update('brun', (value) => 0);
      await FlutterBackground.disableBackgroundExecution();
    }
  }

  Future<String> _ocr(path) async {
    String text = await FlutterTesseractOcr.extractText(path,
        language: ((config['ocr'] as RxMap)['lang'] as List).join("+"),
        args: {
          "psm": "4",
          "oem": "2",
          "preserve_interword_spaces": "1",
        });
    text = text.replaceAll('"\n', '___QWER!@#"___');
    text = text.replaceAll('”\n', '___QWER!@#”___');
    text = text.replaceAll('\'\n', '___QWER!@#\'___');
    text = text.replaceAll('’\n', '___QWER!@#’___');
    text = text.replaceAll('.\n', '___QWER!@#!!___');
    text = text.replaceAll('\n\n', '___QWER!@#___');
    text = text.replaceAll('\n', '');

    text = text.replaceAll('___QWER!@#___', '\n\n');
    text = text.replaceAll('___QWER!@#!!___', '.\n\n');
    text = text.replaceAll('___QWER!@#’___', '’\n');
    text = text.replaceAll('___QWER!@#"___', '"\n');
    text = text.replaceAll('___QWER!@#”___', '”\n');
    text = text.replaceAll('___QWER!@#\'___', '\'\n');
    return text;
  }

  setConfig(Map<String, dynamic> config, List history) {
    try {
      int whereIdx = history.indexWhere((element) {
        return element['name'] == (config['picker'] as Map)['name'];
      });
      assignConfig(config ?? {});
      assignHistory(history ?? []);
      itemScrollctl.jumpTo(index: history[whereIdx]['pos'], alignment: 0.1);
    } catch (e) {}
  }

  assignHistory(List tmpHistory) {
    history.assignAll(tmpHistory);
  }

  assignConfig(Map<String, dynamic> tmpConfig) {
    tmpConfig.keys.forEach((key) {
      if (config[key] == null) {
        return;
      }
      try {
        if (config[key] is RxList && (tmpConfig[key] as List).isNotEmpty) {
          (config[key] as RxList).assignAll(tmpConfig[key]);
        } else if (config[key] is RxMap && (tmpConfig[key] as Map).isNotEmpty) {
          (config[key] as RxMap).assignAll(tmpConfig[key]);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  changeTheme(v) {
    if (v != null && v.length <= 0) {
      return;
    }
    int c1 = v[0];
    int c2 = v[1];

    Color color1 = Color(c1);
    Color color2 = Color(c2);
    Get.changeTheme(ThemeData(
        scaffoldBackgroundColor: color1,
        dialogBackgroundColor: color1,
        appBarTheme: AppBarTheme(
            backgroundColor: color1,
            textTheme: TextTheme(
              headline3: TextStyle(color: color2),
              headline4: TextStyle(color: color2),
              headline5: TextStyle(color: color2),
              headline6: TextStyle(color: color2),
              headline1: TextStyle(color: color2),
              headline2: TextStyle(color: color2),
              bodyText1: TextStyle(color: color2),
              bodyText2: TextStyle(color: color2),
              subtitle1: TextStyle(color: color2),
              subtitle2: TextStyle(color: color2),
              overline: TextStyle(color: color2),
              caption: TextStyle(color: color2),
            )),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: color1),
        cardTheme: CardTheme(color: getSwatchShade(color1, 400)), //
        hintColor: color2,
        colorScheme: ColorScheme.light(
          primary: color2,
          primaryVariant: color2,
          secondary: color2,
          secondaryVariant: color2,
          surface: getSwatchShade(color1, 400),
          // background: color1,
          // error: color1,
          onPrimary: color1,
          onSecondary: color1,
          onSurface: color2,
        ),
        accentColor: color2,
        iconTheme: IconThemeData(color: color2),
        // accentIconTheme: IconThemeData(color: color2),
        primaryIconTheme: IconThemeData(color: color2),
        popupMenuTheme: PopupMenuThemeData(color: getSwatchShade(color1, 400)),
        checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all(color2),
            checkColor: MaterialStateProperty.all(color1)),
        textTheme: TextTheme(
          headline3: TextStyle(color: color2),
          headline4: TextStyle(color: color2),
          headline5: TextStyle(color: color2),
          headline6: TextStyle(color: color2),
          headline1: TextStyle(color: color2),
          headline2: TextStyle(color: color2),
          bodyText1: TextStyle(color: color2),
          bodyText2: TextStyle(color: color2),
          subtitle1: TextStyle(color: color2),
          subtitle2: TextStyle(color: color2),
          overline: TextStyle(color: color2),
          caption: TextStyle(color: color2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: color2),
          border: OutlineInputBorder(
            borderSide: BorderSide(),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: color2,
            ),
          ),
        ),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: color2)));
  }

  Color getSwatchShade(Color c, int swatchValue) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withSaturation(1 - (swatchValue / 1000)).toColor();
  }

  void play() async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    RxList colors = (config["theme"] as RxList);

    await AudioService.start(
      backgroundTaskEntrypoint: textToSpeechTaskEntrypoint,
      androidNotificationChannelName: '오픈텍스트뷰어',
      androidNotificationColor: colors.isNotEmpty ? colors[0] : 0xFFFFFFFF,
      androidNotificationIcon: 'mipmap/ic_launcher',
      params: {
        ...Map.from(config),
        "contents": contents,
        "history": List.from(history)
      },
    );

    await AudioService.play();
  }

  void stop() async {
    await AudioService.stop();
    await AudioService.disconnect();
  }
}
