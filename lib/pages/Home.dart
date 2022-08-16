import 'dart:convert';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import "package:flutter/material.dart";
import 'package:wideflare_sphere_client_app/widgets/LoadingMoreItems.dart';
import 'package:wideflare_sphere_client_app/widgets/NoItem.dart';
import "../widgets/LoadingScreen.dart";
import "Home.dart";
import 'Items.dart';
import 'Launcher.dart';
import 'Item.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../config.dart';
import '../widgets/NotFound.dart';
import '../widgets/Error.dart';
import '../widgets/Lock.dart';
import '../widgets/NotExists.dart';
import '../widgets/UnderDevelopment.dart';

import 'package:ai_awesome_message/ai_awesome_message.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final String appCover =
  //     "https://assets.wideflare.com/launcher-cover/ec60385ca373627fe8a16a01a595e6e0.jpeg";
  // final String appIcon =
  //     "https://assets.wideflare.com/app-icon/8987ce495e5efd80b0c1338ff3afe6cb.png";
  // final String iconImage =
  //     "https://assets.wideflare.com/launcher-item-image/5242d5c973f15026b9b12b458c8792ca.png";

  String? appName = null;
  String? appCover = null;
  String? businessLocation = null;
  String? appIcon = null;
  List<_ItemTemplate> items = [];
  bool pageLoading = true;
  bool nextPage = false;
  int nextPageNumber = 0;
  bool loadMoreLoading = false;

  String appBarTitle = "";

  bool notFound = false;
  bool pageError = false;
  bool appLocked = false;
  bool underDevelopment = false;
  bool exists = true;

  bool message = false;
  String? messageTitle;
  String? messageBody;

  String announcement = "";

  loadMore() async {
    try {
      if (mounted)
        setState(() {
          loadMoreLoading = true;
        });

      var response = await http.get(Uri.parse(
          'https://api.wideflare.com/?action=getHome&appKey=${Config.APP_KEY}&page=$nextPageNumber'));

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

        var info = resp["info"];
        if (info["nextPage"]["status"]) {
          nextPage = true;
          nextPageNumber = info["nextPage"]["page"];
        } else {
          nextPage = false;
        }

        if (info["itemsInThisPage"] != 0) {
          List itemsList = resp["items"];
          int itemListLength = itemsList.length;

          for (int i = 0; i < itemListLength; i++) {
            String itemName = itemsList[i]["itemName"];
            int actionType = itemsList[i]["actionType"];
            String action = itemsList[i]["action"];
            String thumbnail = itemsList[i]["thumbnail"];
            items.add(_ItemTemplate(itemName, actionType, action, thumbnail));
          }
        }

        if (mounted)
          setState(() {
            loadMoreLoading = false;
            print("load more loaded");
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

  loadHome() async {
    try {
      var response = await http.get(Uri.parse(
          'https://api.wideflare.com/?action=getHome&appKey=${Config.APP_KEY}&page=1'));
      print(json.decode(response.body));

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

        var info = resp["info"];
        // sleep(const Duration(seconds: 5));

        ///show dialog
        if (resp["popup"]["status"])
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                resp["popup"]["popupTitle"],
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 340 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                resp["popup"]["popupMessage"],
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 340 ? 14 : 16,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("ok"))
              ],
            ),
          );

        if (resp['message']['status']) {
          message = true;
          messageTitle = resp["message"]["messageTitle"];
          messageBody = resp["message"]["messageBody"];
        }

        if (resp["announcement"]["status"]) {
          announcement = resp["announcement"]["announcementBody"];
        }

        appName = info["appName"];
        appBarTitle = appName!;
        appCover =
            info["homeCover"].toString().isEmpty ? null : info["homeCover"];
        businessLocation = info["appLocation"]["location"]?.toString();
        appIcon = info["appIcon"];
        if (info["nextPage"]["status"]) {
          nextPage = true;
          nextPageNumber = info["nextPage"]["page"];
        } else {
          nextPage = false;
        }

        if (info["itemsInThisPage"] != 0) {
          List itemsList = resp["items"];
          int itemListLength = itemsList.length;

          for (int i = 0; i < itemListLength; i++) {
            String itemName = itemsList[i]["itemName"];
            int actionType = itemsList[i]["actionType"];
            String action = itemsList[i]["action"];
            String thumbnail = itemsList[i]["thumbnail"];
            items.add(_ItemTemplate(itemName, actionType, action, thumbnail));
          }
        }

        if (mounted)
          setState(() {
            pageLoading = false;
            print("pageLoading false");
          });
      } else {
        throw Exception("Failed");
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
    super.initState();
    if (mounted)
      setState(() {
        pageLoading = true;
        loadHome();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
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
                                  child: Stack(
                                    children: [
                                      SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            (!announcement.isEmpty)
                                                ? Container(
                                                    color: Color(0xff2d2d2d),
                                                    padding: EdgeInsets.all(4),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons.announcement,
                                                          color: Colors.orange,
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
                                                            color: Colors.white,
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
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Container(
                                                color: appCover == null
                                                    ? Color(0xfff5f5f5)
                                                    : Colors.black,
                                                height: 300,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 300,
                                                      width: double.infinity,
                                                      child: appCover == null
                                                          ? SizedBox()
                                                          : Image.network(
                                                              appCover!,
                                                              fit: BoxFit.cover,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.6),
                                                              colorBlendMode:
                                                                  BlendMode
                                                                      .modulate),
                                                    ),
                                                    Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Card(
                                                              color:
                                                                  Colors.white,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                child:
                                                                    Container(
                                                                  height: 100,
                                                                  width: 100,
                                                                  child: Image
                                                                      .network(
                                                                    appIcon!,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            appName == null
                                                                ? SizedBox()
                                                                : Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(1),
                                                                    child: Text(
                                                                      appName!,
                                                                      style: TextStyle(
                                                                          color: appCover == null
                                                                              ? Colors
                                                                                  .black
                                                                              : Colors
                                                                                  .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              21),
                                                                    ),
                                                                  ),
                                                            businessLocation ==
                                                                    null
                                                                ? SizedBox()
                                                                : Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(1),
                                                                    child: Text(
                                                                      businessLocation!,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize: MediaQuery.of(context).size.width <
                                                                                340
                                                                            ? 12
                                                                            : 14,
                                                                        color: appCover ==
                                                                                null
                                                                            ? Colors.black
                                                                            : Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                            businessLocation ==
                                                                    null
                                                                ? SizedBox()
                                                                : Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(1),
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                            primary: Colors
                                                                                .green),
                                                                        onPressed:
                                                                            () {},
                                                                        child: Text(
                                                                            "View Location")),
                                                                  )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            (message)
                                                ? AwesomeHelper.createAwesome(
                                                    title: messageTitle!,
                                                    message: messageBody!,
                                                    tipType: TipType.INFO,
                                                  )
                                                : SizedBox(),
                                            items.length == 0
                                                ? NoItem()
                                                : SizedBox(),
                                            Padding(
                                              padding: EdgeInsets.all(4),
                                              child: GridView.builder(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 0),
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                                  // crossAxisCount: 3,
                                                  maxCrossAxisExtent:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              340
                                                          ? 100
                                                          : 150,
                                                  mainAxisSpacing:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              340
                                                          ? 5
                                                          : 8,
                                                  crossAxisSpacing:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              340
                                                          ? 5
                                                          : 8,
                                                  // width / height: fixed for *all* items
                                                  childAspectRatio: 1 / 1.3,
                                                ),
                                                itemCount: items.length,
                                                itemBuilder: (context, index) {
                                                  return Card(
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) {
                                                              if (items[index]
                                                                      .actionType ==
                                                                  1) {
                                                                return Items(
                                                                  categoryId:
                                                                      items[index]
                                                                          .action,
                                                                );
                                                              } else {
                                                                return Launcher(
                                                                  launcherId:
                                                                      items[index]
                                                                          .action,
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        color: Color(0xf5f5f5),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        1 / 1,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      child: Image
                                                                          .network(
                                                                        items[index]
                                                                            .thumbnail!,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 4),
                                                                Container(
                                                                  child:
                                                                      Flexible(
                                                                    child: Text(
                                                                      items[index]
                                                                          .itemName!,
                                                                      style: TextStyle(
                                                                          fontSize: MediaQuery.of(context).size.width < 340
                                                                              ? 12
                                                                              : 14),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          2,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            (nextPage && !loadMoreLoading)
                                                ? ElevatedButton(
                                                    onPressed: () {
                                                      loadMore();
                                                    },
                                                    child: Text("Load more"),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                      ),
                                      loadMoreLoading
                                          ? LoadingMoreItems()
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
    );
  }
}

class _ItemTemplate {
  String? itemName;
  int? actionType;
  String? action;
  String? thumbnail;

  _ItemTemplate(this.itemName, this.actionType, this.action, this.thumbnail);
}
