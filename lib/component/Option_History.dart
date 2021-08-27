import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:open_textview/commonLibrary/HeroDialogRoute.dart';
import 'package:open_textview/component/OptionsBase.dart';
import 'package:open_textview/controller/MainCtl.dart';
import 'package:path_provider/path_provider.dart';

class Option_History_ctl extends GetxController {
  String strFindHistry = "";
}

class Option_History extends OptionsBase {
  Option_History() {
    Get.put(Option_History_ctl());
  }
  @override
  String get name => '히스토리';

  BuildContext context = null;

  @override
  void openSetting() async {
    Directory tempDir = await getTemporaryDirectory();

    HeroPopup(
        tag: name,
        title: Row(children: [
          // buildIcon(),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700),
          )
        ]),
        callback: (completion) {
          var ctl = Get.find<Option_History_ctl>();
          ctl.strFindHistry = "";
        },
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              decoration: InputDecoration(
                labelText: "검색할 단어 / 문장을 입력해 주세요.",
              ),
              onSubmitted: (value) {
                var ctl = Get.find<Option_History_ctl>();
                ctl.strFindHistry = value;
                ctl.update();
              },
            ),
          ),
          SizedBox(
              height: Get.height * 0.6,
              child: GetBuilder<MainCtl>(builder: (ctl) {
                return GetBuilder<Option_History_ctl>(builder: (findctl) {
                  List copyList = List.from(ctl.history);
                  copyList.sort((a, b) {
                    return b['date'].compareTo(a['date']);
                  });
                  if (findctl.strFindHistry.length > 0) {
                    copyList = copyList.where((el) {
                      return el['name'].indexOf(findctl.strFindHistry) >= 0;
                    }).toList();
                  }
                  return Container(
                      padding: EdgeInsets.only(top: 0, left: 10, right: 10),
                      child: ListView(
                        children: [
                          ...copyList.map((element) {
                            int idx = ctl.history.indexOf(element);

                            return Dismissible(
                                key: UniqueKey(),
                                background: Container(color: Colors.red),
                                onDismissed: (direction) {
                                  // e.deleteSync(recursive: true);

                                  ctl.history.removeAt(idx);
                                  ctl.update();
                                  return ctl.history;
                                  // ctl.update();
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Text(element['name']),
                                    subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('위치 : ${element['pos']}'),
                                          Text('마지막 갱신 시간 : ${element['date']}')
                                        ]),
                                  ),
                                ));
                          }).toList(),
                        ],
                      ));
                });
              }))
        ]);
    // showDialog(
    //     context: Get.context,
    //     builder: (BuildContext context) {
    //       return GetBuilder<MainCtl>(builder: (ctl) {
    //         RxList filterlist = controller.config['filter'];
    //         List copyList = [...ctl.history];
    //         copyList.sort((a, b) {
    //           return b['date'].compareTo(a['date']);
    //         });

    //         return SimpleDialog(title: Text(name), children: [
    //           SizedBox(
    //               height: Get.height * 0.7,
    //               width: Get.width * 0.9,
    //               child: Container(
    //                   padding: EdgeInsets.only(top: 10, left: 10, right: 10),
    //                   child: ListView(
    //                     children: [
    //                       ...copyList.map((element) {
    //                         return Card(
    //                           child: ListTile(
    //                             title: Text(element['name']),
    //                             subtitle: Column(
    //                                 crossAxisAlignment:
    //                                     CrossAxisAlignment.start,
    //                                 children: [
    //                                   Text('위치 : ${element['pos']}'),
    //                                   Text('마지막 갱신 시간 : ${element['date']}')
    //                                 ]),
    //                           ),
    //                         );
    //                       }).toList(),
    //                     ],
    //                   )))
    //         ]);
    //       });
    //     }).whenComplete(() {});
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
    this.context = context;
    // TESTopenSetting();
    // TODO: implement build
    return Hero(
        tag: name,
        child: Material(
            type: MaterialType.transparency, // likely needed
            child: IconButton(
              onPressed: () {
                openSetting();
              },
              icon: buildIcon(),
            )));
  }

  @override
  Widget buildIcon() {
    // TODO: implement buildIcon
    return Stack(
      children: [
        Icon(
          Icons.history_outlined,
        ),
      ],
    );
  }
}
