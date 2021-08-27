import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:open_textview/commonLibrary/HeroDialogRoute.dart';
import 'package:open_textview/component/OptionsBase.dart';

// 출처 : https://2colors.colorion.co/
const TWOCOLOR = [
  [0xFF000000, 0xFFFFFFFF],
  [0xFF02343F, 0xFFF0EDCC],
  [0xFF331B3F, 0xFFACC7B4],
  [0xFF0A174E, 0xFFF5D042],
  [0xFF07553B, 0xFFCED46A],
  [0xFF50586C, 0xFFDCE2F0],
  [0xFF815854, 0xFFF9EBDE],
  [0xFF1E4174, 0xFFDDA94B],
  [0xFFA4193D, 0xFFFFDFB9],
  [0xFF1AAFBC, 0xFF80634C],
  [0xFFFFDFDE, 0xFF6A7BA2],
  [0xFF3B1877, 0xFFDA5A2A],
  [0xFF5F4B8B, 0xFFE69A8D],
  [0xFF00203F, 0xFFADEFD1],
  [0xFF606060, 0xFFD6ED17],
  [0xFF2C5F2D, 0xFF97BC62],
  [0xFF00539C, 0xFFEEA47F],
  [0xFF0063B2, 0xFF9CC3D5],
  [0xFF101820, 0xFFFEE715],
  [0xFFCBCE91, 0xFFd3687f],
  [0xFFB1624E, 0xFF5CC8D7],
  [0xFF7b9acc, 0xFFFCF6F5],
  [0xFF101820, 0xFFF2AA4C],
  [0xFFA07855, 0xFFD4B996],
  [0xFF195190, 0xFFA2A2A1],
  [0xFF603F83, 0xFFC7D3D4],
  [0xFF2BAE66, 0xFFFCF6F5],
  [0xFFFAD0C9, 0xFF6E6E6D],
  [0xFF2D2926, 0xFFed6f63],
  [0xFFDAA03D, 0xFF616247],
  [0xFF990011, 0xFFFCF6F5],
  [0xFF364b44, 0xFFD64161],
  [0xFFCBCE91, 0xFF76528B],
  [0xFFFAEBEF, 0xFF333D79],
  [0xFFc72d1b, 0xFFFDD20E],
  [0xFFF2EDD7, 0xFF755139],
  [0xFF1a7a4c, 0xFF101820],
  [0xFFF95700, 0xFFFFFFFF],
  [0xFFFFD662, 0xFF00539C],
  [0xFFD7C49E, 0xFF343148],
  [0xFFcf8360, 0xFFF5C7B8],
  [0xFFDF6589, 0xFF3C1053],
  [0xFFFFE77A, 0xFF2C5F2D],
  [0xFFe9877e, 0xFF9E1030],
  [0xFFFCF951, 0xFF422057],
  [0xFF4B878B, 0xFF921416],
  [0xFF1C1C1B, 0xFFCE4A7E],
  [0xFF00B1D2, 0xFFFDDB27],
  [0xFF558600, 0xFFff9967],
  [0xFFBD7F37, 0xFFA13941],
  [0xFFeedfe2, 0xFF9FC131],
  [0xFF00239C, 0xFFed6a66],
  [0xFFF96167, 0xFFFCE77D],
  [0xFFF9D142, 0xFF292826],
  [0xFFDF678C, 0xFF3D155F],
  [0xFFCCF381, 0xFF4831D4],
  [0xFF4A274F, 0xFFF0A07B],
  [0xFFFFF548, 0xFF3C1A5B],
  [0xFF2E3C7E, 0xFFFBEAEB],
  [0xFFEC4D36, 0xFF1D1B1B],
  [0xFF8BD8BD, 0xFF243665],
  [0xFF141A46, 0xFFEC8B5E],
  [0xFFFEFEFE, 0xFF8AAAE5],
  [0xFF295F2E, 0xFFFFE67C],
  [0xFFF3A950, 0xFF161B21],
  [0xFFef4da0, 0xFF070952],
  [0xFF4A171E, 0xFFE2B143],
  [0xFFD2302C, 0xFFF7F7F9],
  [0xFF348597, 0xFFF4A896],
  [0xFFE7D044, 0xFFA04EF6],
  [0xFF262223, 0xFFDDC6B6],
  [0xFFF4EFEA, 0xFF9A161F],
  [0xFF234E70, 0xFFFBF8BE],
  [0xFFFFE8F5, 0xFF9000FF],
  [0xFF191919, 0xFFBD8F4D],
  [0xFFCC313D, 0xFFF7C5CC],
  [0xFFE2D3F3, 0xFF013DC4],
  [0xFF99F443, 0xFFEC449B],
  [0xFFEE4E34, 0xFFFCEDDA],
  [0xFF96351F, 0xFFDBB98F],
  [0xFFE2D0F9, 0xFF317773],
];

class Option_Theme extends OptionsBase {
  @override
  String get name => '테마설정';
  BuildContext context = null;

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
        callback: (completion) {},
        children: [
          SizedBox(
              height: Get.height * 0.7,
              // width: Get.width * 0.9,
              child: Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Expanded(
                          child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 1,
                              childAspectRatio: 7.0 / 1.0,
                              children: [
                            ...TWOCOLOR.map((e) {
                              int idx = TWOCOLOR.indexOf(e) + 1;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Container(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text('${idx}번째 테마 : ')),
                                  ),
                                  Expanded(
                                      child: MaterialButton(
                                    // padding: EdgeInsets.all(0),
                                    // minWidth: 0,
                                    color: Color(e[0]),
                                    child: Icon(
                                      Icons.volume_up,
                                      color: Color(e[1]),
                                    ),
                                    shape: CircleBorder(),
                                    onPressed: () {
                                      controller.config.update('theme',
                                          (value) {
                                        RxList list = value;
                                        list.assignAll([e[0], e[1]]);
                                        return value;
                                      });
                                      controller.update();
                                    },
                                  )),
                                  Expanded(
                                      child: MaterialButton(
                                    // padding: EdgeInsets.all(0),
                                    // minWidth: 0,
                                    color: Color(e[1]),
                                    child: Icon(Icons.volume_up,
                                        color: Color(e[0])),
                                    shape: CircleBorder(),
                                    onPressed: () {
                                      controller.config.update('theme',
                                          (value) {
                                        return (value as RxList)
                                          ..assignAll([e[1], e[0]]);
                                      });
                                    },
                                  )),
                                ],
                              );
                            }).toList()
                          ]))
                    ],
                  )))
        ]);
    // showDialog(
    //     context: Get.context,
    //     // barrierColor: Colors.transparent,
    //     // isDismissible: false,
    //     builder: (BuildContext context) {
    //       return SimpleDialog(
    //           title: Text(
    //             name,
    //             style: TextStyle(fontWeight: FontWeight.w700),
    //           ),
    //           children: [
    //             SizedBox(
    //                 height: Get.height * 0.75,
    //                 width: Get.width * 0.9,
    //                 child: Container(
    //                     padding: EdgeInsets.all(5),
    //                     child: Column(
    //                       children: [
    //                         Expanded(
    //                             child: GridView.count(
    //                                 shrinkWrap: true,
    //                                 crossAxisCount: 1,
    //                                 childAspectRatio: 7.0 / 1.0,
    //                                 children: [
    //                               ...TWOCOLOR.map((e) {
    //                                 int idx = TWOCOLOR.indexOf(e) + 1;
    //                                 return Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.spaceAround,
    //                                   children: [
    //                                     Expanded(
    //                                       child: Container(
    //                                           padding:
    //                                               EdgeInsets.only(left: 20),
    //                                           child: Text('${idx}번째 테마 : ')),
    //                                     ),
    //                                     Expanded(
    //                                         child: MaterialButton(
    //                                       // padding: EdgeInsets.all(0),
    //                                       // minWidth: 0,
    //                                       color: Color(e[0]),
    //                                       child: Icon(
    //                                         Icons.volume_up,
    //                                         color: Color(e[1]),
    //                                       ),
    //                                       shape: CircleBorder(),
    //                                       onPressed: () {
    //                                         controller.config.update('theme',
    //                                             (value) {
    //                                           RxList list = value;
    //                                           list.assignAll([e[0], e[1]]);
    //                                           return value;
    //                                         });
    //                                       },
    //                                     )),
    //                                     Expanded(
    //                                         child: MaterialButton(
    //                                       // padding: EdgeInsets.all(0),
    //                                       // minWidth: 0,
    //                                       color: Color(e[1]),
    //                                       child: Icon(Icons.volume_up,
    //                                           color: Color(e[0])),
    //                                       shape: CircleBorder(),
    //                                       onPressed: () {
    //                                         controller.config.update('theme',
    //                                             (value) {
    //                                           return (value as RxList)
    //                                             ..assignAll([e[1], e[0]]);
    //                                         });
    //                                       },
    //                                     )),
    //                                   ],
    //                                 );
    //                               }).toList()
    //                             ]))
    //                       ],
    //                     )))
    //           ]);
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
              icon: buildIcon())),
    );
  }

  @override
  Widget buildIcon() {
    // Get.put(Option_ThemeCtl());
    // TODO: implement buildIcon
    return Stack(
      children: [
        Icon(
          Icons.palette_rounded,
        ),
      ],
    );
  }
}
