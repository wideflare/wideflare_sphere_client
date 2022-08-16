import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:wideflare_sphere_client_app/widgets/LoadingScreen.dart';
import "Home.dart";
import 'Items.dart';
import 'Launcher.dart';
import 'Item.dart';
import '../widgets/FullScreenImage.dart';

import '../widgets/NoItem.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import '../services/SDP.dart';

import '../../config.dart';
import '../widgets/NotFound.dart';
import '../widgets/Error.dart';
import '../widgets/Lock.dart';
import '../widgets/NotExists.dart';
import '../widgets/UnderDevelopment.dart';

class Item extends StatefulWidget {
  final itemId;
  const Item({Key? key, @required this.itemId}) : super(key: key);

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  // String itemImage =
  //     "https://assets.wideflare.com/item-images/a0d8b635adc3a224eb5f65283d109454.jpeg";
  bool pageLoading = true;
  String? itemName;
  Map? extras;
  String? itemBody;
  List<String> itemImages = [];
  String? itemImage;

  bool loadMoreLoading = false;
  bool notFound = false;
  bool pageError = false;
  bool appLocked = false;
  bool underDevelopment = false;
  bool exists = true;
  String appBarTitle = "";
  String announcement = "";

  String getDiscount(int price, int offerPrice) {
    return "${(((price - offerPrice) / price) * 100).toInt()} % off ";
  }

  loadHome() async {
    try {
      var response = await http.get(Uri.parse(
          "https://api.wideflare.com/?action=getItem&appKey=${Config.APP_KEY}&itemId=${widget.itemId}"));
      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        switch (resp["response"]["status"]) {
          case "category-id-invalid":
            print("item not found");
            if (mounted)
              setState(() {
                notFound = true;
                pageLoading = false;
                appBarTitle = "";
              });
            return;
            break;
          case "app-expired":
            if (mounted)
              setState(() {
                appLocked = true;
                pageLoading = false;
                appBarTitle = "";
              });
            return;
            break;
          case "under-construction":
            if (mounted)
              setState(() {
                appBarTitle = "";
                pageLoading = false;
                underDevelopment = true;
              });
            return;
            break;

          case "app-key-invalid":
            if (mounted)
              setState(() {
                exists = false;
                pageLoading = false;
                appBarTitle = "";
              });
            return;
            break;
        } //end of switch

        print(resp);
        var info = resp["info"];
        itemImage = resp["itemImage"];
        itemName = resp["itemName"];
        if (resp["announcement"]["status"]) {
          announcement = resp["announcement"]["announcementBody"];
        }
        itemBody = utf8.decode(base64.decode(resp["body"]));
        extras = resp["extras"]["status"] ? resp["extras"]["extras"] : null;
        if (resp["itemImages"]["status"]) {
          List imageArray = resp["itemImages"]["images"];
          int count = imageArray.length;
          for (int i = 0; i < count; i++) {
            itemImages.add(imageArray[i]["image"]!);
          }
          print(itemImages);
        }
        if (mounted)
          setState(() {
            pageLoading = false;
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          pageError = true;
          pageLoading = false;
          appBarTitle = "Error";
        });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadHome();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    SDP.init(context);
    return Scaffold(
      appBar: AppBar(),
      body: pageLoading
          ? LoadingScreen()
          : pageError
              ? Error()
              : notFound
                  ? NotFound()
                  : appLocked
                      ? Lock()
                      : underDevelopment
                          ? UnderDevelopment()
                          : !exists
                              ? NotExists()
                              : SafeArea(
                                  child: Container(
                                    height: double.infinity,
                                    color: Colors.white,
                                    child: SingleChildScrollView(
                                      child: Stack(
                                        children: [
                                          (itemImages.length != 0)
                                              ? Container(
                                                  width: double.infinity,
                                                  height: 400,
                                                  child: Image.network(
                                                    itemImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : SizedBox(),
                                          Column(
                                            children: [
                                              (!announcement.isEmpty)
                                                  ? Container(
                                                      color: Color(0xff2d2d2d),
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.announcement,
                                                            color:
                                                                Colors.orange,
                                                            size: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    320
                                                                ? 14
                                                                : 16,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    announcement,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize: MediaQuery.of(context).size.width <
                                                                                340
                                                                            ? 12
                                                                            : 14),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(),
                                                          InkWell(
                                                            onTap: (() {
                                                              if (mounted)
                                                                setState(() {
                                                                  announcement =
                                                                      "";
                                                                });
                                                            }),
                                                            child: Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                              size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      320
                                                                  ? 14
                                                                  : 16,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (itemImages.length != 0)
                                                  ? Stack(
                                                      children: [
                                                        SizedBox(
                                                          height: 350,
                                                          child: Container(
                                                            height: 80,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Card(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.6),
                                                                  child:
                                                                      Container(
                                                                    height: 60,
                                                                    // width: 400,
                                                                    constraints: BoxConstraints(
                                                                        minWidth:
                                                                            50,
                                                                        maxWidth:
                                                                            250),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            EdgeInsets.all(4),
                                                                        height:
                                                                            50,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(1),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              for (var image in itemImages)
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    if (mounted)
                                                                                      setState(() {
                                                                                        itemImage = image;
                                                                                      });
                                                                                  },
                                                                                  child: Card(
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(2),
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.all(2),
                                                                                        height: 50,
                                                                                        width: 50,
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: Colors.grey),
                                                                                        ),
                                                                                        child: Image.network(
                                                                                          image,
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    FullScreenImage(
                                                                        image:
                                                                            itemImage!),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Icon(
                                                                Icons
                                                                    .fullscreen,
                                                                size: 30,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              Container(
                                                constraints: BoxConstraints(
                                                  minHeight: 400,
                                                  minWidth: double.infinity,
                                                  maxHeight: double.infinity,
                                                ),
                                                child: Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Card(
                                                              color:
                                                                  Colors.grey,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50)),
                                                              child: Container(
                                                                height: 4,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                itemName!,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 25,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 25,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        (extras != null &&
                                                                extras!.containsKey(
                                                                    "stock") &&
                                                                extras!["stock"] ==
                                                                    false)
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Card(
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        "Out of stock",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                        (extras != null &&
                                                                extras!.containsKey(
                                                                    "offerPrice"))
                                                            ? Row(
                                                                children: [
                                                                  Card(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    color: Colors
                                                                            .orange[
                                                                        900],
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (60 *
                                                                              0.9)
                                                                          : 60,
                                                                      width: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (100 *
                                                                              0.9)
                                                                          : 100,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Offer Price",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Flexible(
                                                                                  child: Text(
                                                                                    "${extras!["offerPrice"]["currency"]} ${extras!["offerPrice"]["price"]} / ${extras!["offerPrice"]["unit"]}",
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12,
                                                                                      decoration: TextDecoration.lineThrough,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Card(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    color: Colors
                                                                            .green[
                                                                        900],
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (60 *
                                                                              0.9)
                                                                          : 60,
                                                                      width: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (100 *
                                                                              0.9)
                                                                          : 100,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Price",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Flexible(
                                                                                  child: Text(
                                                                                    "${extras!["offerPrice"]["currency"]} ${extras!["offerPrice"]["offerPrice"]} / ${extras!["offerPrice"]["unit"]}",
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Card(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    color: Colors
                                                                            .red[
                                                                        900],
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (60 *
                                                                              0.9)
                                                                          : 60,
                                                                      width: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (100 *
                                                                              0.9)
                                                                          : 100,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Discount",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.local_offer,
                                                                                  size: 12,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 2,
                                                                                ),
                                                                                Flexible(
                                                                                  child: Text(
                                                                                    getDiscount((extras!["offerPrice"]["price"]), (extras!["offerPrice"]["offerPrice"])),
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 12,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                        (extras != null &&
                                                                extras!.containsKey(
                                                                    "price") &&
                                                                !extras!.containsKey(
                                                                    "offerPrice"))
                                                            ? Row(
                                                                children: [
                                                                  Card(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    color: Colors
                                                                            .green[
                                                                        900],
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (60 *
                                                                              0.9)
                                                                          : 60,
                                                                      width: MediaQuery.of(context).size.width <
                                                                              340
                                                                          ? (100 *
                                                                              0.9)
                                                                          : 100,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Price",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Flexible(
                                                                                child: Text(
                                                                                  "${extras!["price"]["currency"]} ${extras!["price"]["price"]} / ${extras!["price"]["unit"]}",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 2,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        (extras != null &&
                                                                extras!.containsKey(
                                                                    "location"))
                                                            ? Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    size: 15,
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      extras![
                                                                          "location"],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                itemBody!,
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ], //end of main container
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
    );
  }
}
