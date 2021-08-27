import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:open_textview/commonLibrary/HeroDialogRoute.dart';
import 'package:open_textview/component/OptionsBase.dart';
import 'package:open_textview/controller/MainCtl.dart';
import 'package:open_textview/items/Languages.dart';

// var isOpen = false;

class Option_Tts extends OptionsBase {
  @override
  String get name => 'TTS 설정';

  @override
  void openSetting() {
    HeroPopup(
        tag: name,
        title: Row(children: [
          // buildIcon(),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700),
          )
        ]),
        children: [
          Column(children: [
            Container(
              padding: EdgeInsets.all(10),
              child: GetBuilder<MainCtl>(
                builder: (context) {
                  String langCode =
                      (controller.config['tts'] as Map)['language'];
                  return Column(
                    children: [
                      // SizedBox(
                      //     width: double.infinity,
                      //     child: ElevatedButton(
                      //       onPressed: () async {
                      //         openSettingLanguage();
                      //       },
                      //       child: Text(
                      //           '현재 설정 언어 : ${langCode} (${LANG[langCode]['ko']}) '),
                      //     )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    '속도 : ${((controller.config['tts'] as Map)['speechRate'] as double).toPrecision(2).toString()}')),
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                    onPressed: () {
                                      (controller.config['tts']
                                          as Map)['speechRate'] -= 0.01;
                                      controller.update();
                                    },
                                    icon: Icon(Icons.navigate_before_sharp))),
                            Expanded(
                              flex: 6,
                              child: Slider(
                                value: (controller.config['tts']
                                    as Map)['speechRate'],
                                min: 0,
                                max: 5,
                                divisions: 500,
                                label: ((controller.config['tts']
                                        as Map)['speechRate'] as double)
                                    .toPrecision(2)
                                    .toString(),
                                onChanged: (double v) {
                                  (controller.config['tts']
                                      as Map)['speechRate'] = v.toPrecision(2);

                                  controller.update();
                                },
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () {
                                    (controller.config['tts']
                                        as Map)['speechRate'] += 0.01;

                                    controller.update();
                                  },
                                  icon: Icon(Icons.navigate_next_sharp),
                                )),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    '볼륨 : ${((controller.config['tts'] as Map)['volume'] as double).toPrecision(1).toString()}')),
                            Expanded(
                              flex: 6,
                              child: Slider(
                                value:
                                    (controller.config['tts'] as Map)['volume'],
                                min: 0,
                                max: 1,
                                divisions: 10,
                                label: ((controller.config['tts']
                                        as Map)['volume'] as double)
                                    .toPrecision(1)
                                    .toString(),
                                onChanged: (double v) {
                                  (controller.config['tts'] as Map)['volume'] =
                                      v;

                                  controller.update();
                                },
                              ),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    '피치 : ${((controller.config['tts'] as Map)['pitch'] as double).toPrecision(1).toString()}')),
                            Expanded(
                              flex: 6,
                              child: Slider(
                                value:
                                    (controller.config['tts'] as Map)['pitch'],
                                min: 0.5,
                                max: 2,
                                divisions: 15,
                                label: ((controller.config['tts']
                                        as Map)['pitch'] as double)
                                    .toPrecision(1)
                                    .toString(),
                                onChanged: (double v) {
                                  (controller.config['tts'] as Map)['pitch'] =
                                      v;

                                  controller.update();
                                },
                              ),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: Text('줄단위 읽기: ')),
                            Expanded(
                              flex: 6,
                              child: SpinBox(
                                min: 1,
                                max: 20,
                                incrementIcon: Icon(
                                  Icons.add,
                                  color: Theme.of(Get.context).iconTheme.color,
                                ),
                                decrementIcon: Icon(
                                  Icons.remove,
                                  color: Theme.of(Get.context).iconTheme.color,
                                ),
                                value: (controller.config['tts']
                                            as Map)['groupcnt']
                                        .toDouble() ??
                                    1,
                                onChanged: (value) {
                                  (controller.config['tts']
                                      as Map)['groupcnt'] = value.toInt();
                                  controller.update();
                                },
                              ),
                            ),
                          ]),
                      Divider(),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text('헤드셋 버튼 사용'),
                          value: (controller.config['tts']
                                  as Map)['headsetbutton'] ??
                              false,
                          onChanged: (b) {
                            (controller.config['tts'] as Map)['headsetbutton'] =
                                b;
                            controller.update();
                          }),
                      CheckboxListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text('다른 플레이어 실행시 정지'),
                          value: (controller.config['tts']
                                  as Map)['audiosession'] ??
                              false,
                          onChanged: (b) {
                            (controller.config['tts'] as Map)['audiosession'] =
                                b;
                            controller.update();
                            // ctl.filterTmpCtl['expr'] = b;
                            // ctl.update();
                          }),
                    ],
                  );
                },
              ),
            ),
          ])
        ]);
    // });
    // .whenComplete(() {});
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
          Icons.volume_mute_rounded,
        ),
        Container(
            margin: EdgeInsets.only(left: 15, top: 4),
            child: Icon(
              Icons.settings_rounded,
              size: 15,
            )),
      ],
    );
  }
}
