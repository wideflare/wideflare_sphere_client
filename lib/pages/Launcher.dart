import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../widgets/LoadingScreen.dart';
import '../widgets/LoadingMoreItems.dart';
import "Home.dart";
import 'Items.dart';
import 'Launcher.dart';
import 'Item.dart';

import '../widgets/NoItem.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import '../../config.dart';
import '../widgets/NotFound.dart';
import '../widgets/Error.dart';
import '../widgets/Lock.dart';
import '../widgets/NotExists.dart';
import '../widgets/UnderDevelopment.dart';

class Launcher extends StatefulWidget {
  final launcherId;
  const Launcher({Key? key, @required this.launcherId}) : super(key: key);

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  String? launcherName;
  String? launcherThumbnail;
  String? launcherCover;
  int totalItemCount = 0;
  bool nextPage = false;
  int nextPageNumber = 0;
  bool pageLoading = true;
  bool loadMoreLoading = false;
  List<_Itemtemplate> items = [];

  bool notFound = false;
  bool pageError = false;
  bool appLocked = false;
  bool underDevelopment = false;
  bool exists = true;
  String appBarTitle = "";
  String announcement = "";
  loadMore() async {
    try {
      if (mounted)
        setState(() {
          loadMoreLoading = true;
        });
      var response = await http.get(Uri.parse(
          "https://api.wideflare.com/?action=getLauncher&appKey=${Config.APP_KEY}&page=$nextPageNumber&launcherId=${widget.launcherId}"));
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
          List itemArray = resp["items"];
          int itemCount = itemArray.length;
          for (int i = 0; i < itemCount; i++) {
            String itemName = itemArray[i]["itemName"];
            int actionType = itemArray[i]["actionType"];
            String action = itemArray[i]["action"];
            String thumbnail = itemArray[i]["thumbnail"];
            items.add(_Itemtemplate(itemName, actionType, action, thumbnail));
          }
        }

        if (mounted)
          setState(() {
            loadMoreLoading = false;
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
          "https://api.wideflare.com/?action=getLauncher&appKey=${Config.APP_KEY}&page=1&launcherId=${widget.launcherId}"));
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
        launcherName = info["launcherName"];
        launcherThumbnail = info["launcherThumbnail"];
        if (resp["announcement"]["status"]) {
          announcement = resp["announcement"]["announcementBody"];
        }
        launcherCover = info["launcherCover"].toString().isEmpty
            ? null
            : info["launcherCover"];
        totalItemCount = info["totalItemCount"];
        if (info["nextPage"]["status"]) {
          nextPage = true;
          nextPageNumber = info["nextPage"]["page"];
        } else {
          nextPage = false;
        }

        if (info["itemsInThisPage"] != 0) {
          List itemArray = resp["items"];
          int itemCount = itemArray.length;
          for (int i = 0; i < itemCount; i++) {
            String itemName = itemArray[i]["itemName"];
            int actionType = itemArray[i]["actionType"];
            String action = itemArray[i]["action"];
            String thumbnail = itemArray[i]["thumbnail"];
            items.add(_Itemtemplate(itemName, actionType, action, thumbnail));
          }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(launcherName ?? "loading..."),
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
                                      Container(
                                        height: double.infinity,
                                        child: SingleChildScrollView(
                                          child: Column(
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
                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Container(
                                                  color: launcherCover == null
                                                      ? Color(0xff6c6c6c)
                                                      : Colors.black,
                                                  height: 150,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        height: 150,
                                                        width: double.infinity,
                                                        child: launcherCover ==
                                                                null
                                                            ? SizedBox()
                                                            : Image.network(
                                                                launcherCover!,
                                                                fit: BoxFit
                                                                    .cover,
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
                                                              Flexible(
                                                                child: Text(
                                                                  launcherName!,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          35,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 3,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              (totalItemCount != 0)
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: GridView.builder(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4,
                                                                horizontal: 0),
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        gridDelegate:
                                                            SliverGridDelegateWithMaxCrossAxisExtent(
                                                          // crossAxisCount: 3,
                                                          maxCrossAxisExtent:
                                                              150,
                                                          mainAxisSpacing: 8,
                                                          crossAxisSpacing: 8,
                                                          // width / height: fixed for *all* items
                                                          childAspectRatio:
                                                              1 / 1.2,
                                                        ),
                                                        itemCount: items.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Card(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                                      if (items[index]
                                                                              .actionType ==
                                                                          1) {
                                                                        return Items(
                                                                          categoryId:
                                                                              items[index].action,
                                                                        );
                                                                      } else {
                                                                        return Launcher(
                                                                          launcherId:
                                                                              items[index].action,
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                color: Color(
                                                                    0xf5f5f5),
                                                                child: Center(
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              AspectRatio(
                                                                            aspectRatio:
                                                                                1 / 1,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(5),
                                                                              child: Image.network(
                                                                                items[index].thumbnail!,
                                                                                fit: BoxFit.contain,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                2,
                                                                            horizontal:
                                                                                8),
                                                                        child: Text(
                                                                            items[index]
                                                                                .itemName!,
                                                                            overflow:
                                                                                TextOverflow.ellipsis),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Center(
                                                      child: NoItem(),
                                                    ),
                                              (nextPage == true &&
                                                      !loadMoreLoading)
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
                                      ),
                                      loadMoreLoading
                                          ? LoadingMoreItems()
                                          : SizedBox()
                                    ],
                                  ),
                                ),
    );
  }
}

class _Itemtemplate {
  String? itemName;
  int? actionType;
  String? action;
  String? thumbnail;

  _Itemtemplate(this.itemName, this.actionType, this.action, this.thumbnail);
}
