import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import "package:flutter/material.dart";
import '../widgets/LoadingScreen.dart';
import '../widgets/LoadingMoreItems.dart';
import 'package:ribbon_widget/ribbon_widget.dart';
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

class Items extends StatefulWidget {
  final String? categoryId;
  const Items({Key? key, @required this.categoryId}) : super(key: key);

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  // String launcherIcon =
  //     "https://assets.wideflare.com/item-thumbnail/e37aa303f3459d17806374e56f0ad99f.png";
  int totalItems = 0;
  bool nextPage = true;
  int nextPageNumber = 0;

  String? launcherIcon;
  bool pageLoading = true;
  String? categoryName;
  String? categorythumbnail;
  String? appCover;
  String? appBarTitle;

  bool loadMoreLoading = false;
  bool notFound = false;
  bool pageError = false;
  bool appLocked = false;
  bool underDevelopment = false;
  bool exists = true;
  String announcement = "";

  List<_ItemTemplate> items = [];

  String getDiscount(int price, int offerPrice) {
    return "${(((price - offerPrice) / price) * 100).toInt()} % off ";
  }

  loadMore() async {
    if (mounted)
      setState(() {
        loadMoreLoading = true;
      });

    try {
      var response = await http.get(Uri.parse(
          "https://api.wideflare.com/?action=getItems&appKey=${Config.APP_KEY}&page=$nextPageNumber&categoryId=${widget.categoryId}"));
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
          List itemsArray = resp["items"];
          int itemsCount = itemsArray.length;

          for (int i = 0; i < itemsCount; i++) {
            String itemName = itemsArray[i]["itemName"];
            String itemId = itemsArray[i]["itemId"];
            Map? extras = itemsArray[i]["extras"]["status"]
                ? itemsArray[i]["extras"]["extras"]
                : null;
            String itemImage = itemsArray[i]["itemImage"];
            items.add(_ItemTemplate(itemName, itemId, extras, itemImage));
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
          "https://api.wideflare.com/?action=getItems&appKey=${Config.APP_KEY}&page=1&categoryId=${widget.categoryId}"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var resp = json.decode(response.body);
        print(resp["response"]["status"]);
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
        }

        var info = resp["info"];
        print(resp);
        totalItems = info["totalItemCount"];
        appCover =
            info["homeCover"].toString().isEmpty ? null : info["homeCover"];
        categoryName = info["categoryName"];
        appBarTitle = categoryName;
        categorythumbnail = info["categoryThumbnail"];

        if (resp["announcement"]["status"]) {
          announcement = resp["announcement"]["announcementBody"];
        }

        if (info["nextPage"]["status"]) {
          nextPage = true;
          nextPageNumber = info["nextPage"]["page"];
        } else {
          nextPage = false;
        }

        if (info["itemsInThisPage"] != 0) {
          List itemsArray = resp["items"];
          int itemsCount = itemsArray.length;

          for (int i = 0; i < itemsCount; i++) {
            String itemName = itemsArray[i]["itemName"];
            String itemId = itemsArray[i]["itemId"];
            Map? extras = itemsArray[i]["extras"]["status"]
                ? itemsArray[i]["extras"]["extras"]
                : null;
            String itemImage = itemsArray[i]["itemImage"];
            items.add(_ItemTemplate(itemName, itemId, extras, itemImage));
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
    print(widget.categoryId);
    loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? "loading..."),
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
                                                    ? Color(0xff6c6c6c)
                                                    : Colors.black,
                                                height: 80,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      width: double.infinity,
                                                      child: appCover == null
                                                          ? SizedBox()
                                                          : appCover == null
                                                              ? SizedBox()
                                                              : Image.network(
                                                                  appCover!,
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
                                                                .all(2.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Card(
                                                                  color: Colors
                                                                      .white,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          60,
                                                                      width: 60,
                                                                      child: Image
                                                                          .network(
                                                                        categorythumbnail!,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          categoryName!,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 21),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Colors.white),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.all(2),
                                                                            child:
                                                                                Text(
                                                                              "$totalItems items",
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            totalItems == 0
                                                ? SizedBox()
                                                : Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4),
                                                    child: GridView.builder(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0,
                                                              horizontal: 0),
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                                        // crossAxisCount: 3,
                                                        maxCrossAxisExtent: 200,
                                                        mainAxisSpacing: 2,
                                                        crossAxisSpacing: 2,
                                                        // width / height: fixed for *all* items
                                                        // childAspectRatio: 1 / 1.5,
                                                        childAspectRatio: 1 / 1,
                                                      ),
                                                      itemCount: items.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: (() {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                                  return Item(
                                                                      itemId: items[
                                                                              index]
                                                                          .itemId);
                                                                },
                                                              ),
                                                            );
                                                          }),
                                                          child: Card(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Container(
                                                              color: Color(
                                                                  0xf5f5f5),
                                                              child: Center(
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
                                                                              BorderRadius.circular(5),
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Image.network(
                                                                                  items[index].itemImage!,
                                                                                  color: (items[index].extras != null && items[index].extras!.containsKey("stock") && items[index].extras!["stock"] == false) ? Colors.grey.shade600.withOpacity(0.6) : Colors.white.withOpacity(0.8),
                                                                                  colorBlendMode: BlendMode.modulate,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                                (items[index].extras != null && items[index].extras!.containsKey("offerPrice"))
                                                                                    ? Ribbon(
                                                                                        child: Container(
                                                                                          height: 80,
                                                                                          width: 80,
                                                                                        ),
                                                                                        title: getDiscount(items[index].extras!["offerPrice"]["price"], items[index].extras!["offerPrice"]["offerPrice"]),
                                                                                        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                                                                        color: Colors.red,
                                                                                        location: RibbonLocation.topStart,
                                                                                        farLength: 60,
                                                                                        nearLength: 25,
                                                                                      )
                                                                                    : SizedBox(),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(2.0),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      Card(
                                                                                        color: Colors.white.withOpacity(0.6),
                                                                                        child: Container(
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.all(4),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Row(
                                                                                                  children: [
                                                                                                    Flexible(
                                                                                                      child: Text(
                                                                                                        items[index].itemName!,
                                                                                                        overflow: TextOverflow.ellipsis,
                                                                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                                                        maxLines: 5,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                SizedBox(height: 2),
                                                                                                (items[index].extras != null && items[index].extras!.containsKey("offerPrice"))
                                                                                                    ? Column(
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Flexible(
                                                                                                                child: Text(
                                                                                                                  "${items[index].extras!["offerPrice"]["currency"]} ${items[index].extras!["offerPrice"]["price"]} / ${items[index].extras!["offerPrice"]["unit"]}",
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 8,
                                                                                                                    decoration: TextDecoration.lineThrough,
                                                                                                                  ),
                                                                                                                  maxLines: 2,
                                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                                ),
                                                                                                              ),
                                                                                                              SizedBox(
                                                                                                                width: 4,
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Flexible(
                                                                                                                child: Text(
                                                                                                                  "${items[index].extras!["offerPrice"]["currency"]} ${items[index].extras!["offerPrice"]["offerPrice"]} / ${items[index].extras!["offerPrice"]["unit"]}",
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 10,
                                                                                                                  ),
                                                                                                                  maxLines: 2,
                                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                                ),
                                                                                                              ),
                                                                                                              SizedBox(
                                                                                                                width: 4,
                                                                                                              ),
                                                                                                            ],
                                                                                                          )
                                                                                                        ],
                                                                                                      )
                                                                                                    : SizedBox(),
                                                                                                (items[index].extras != null && items[index].extras!.containsKey("price") && !items[index].extras!.containsKey("offerPrice"))
                                                                                                    ? Row(
                                                                                                        children: [
                                                                                                          Flexible(
                                                                                                            child: Text(
                                                                                                              "${items[index].extras!["price"]["currency"]} ${items[index].extras!["price"]["price"]} / ${items[index].extras!["price"]["unit"]}",
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 10,
                                                                                                              ),
                                                                                                              maxLines: 2,
                                                                                                              overflow: TextOverflow.ellipsis,
                                                                                                            ),
                                                                                                          ),
                                                                                                          SizedBox(
                                                                                                            width: 4,
                                                                                                          ),
                                                                                                        ],
                                                                                                      )
                                                                                                    : SizedBox(),
                                                                                                (items[index].extras != null && items[index].extras!.containsKey("location"))
                                                                                                    ? Row(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          Icon(
                                                                                                            Icons.location_on,
                                                                                                            color: Colors.black,
                                                                                                            size: 10,
                                                                                                          ),
                                                                                                          Flexible(
                                                                                                            child: Text(
                                                                                                              items[index].extras!["location"],
                                                                                                              maxLines: 2,
                                                                                                              overflow: TextOverflow.ellipsis,
                                                                                                              style: TextStyle(fontSize: 10, color: Colors.black),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      )
                                                                                                    : SizedBox()
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                (items[index].extras != null && items[index].extras!.containsKey("stock") && items[index].extras!["stock"] == false)
                                                                                    ? Center(
                                                                                        child: Text(
                                                                                          "Out of stock",
                                                                                          style: TextStyle(
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox()
                                                                              ],
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
                                                        );
                                                      },
                                                    ),
                                                  ),
                                            totalItems == 0
                                                ? NoItem()
                                                : SizedBox(),
                                            (nextPage == true &&
                                                    !loadMoreLoading)
                                                ? ElevatedButton(
                                                    onPressed: () {
                                                      loadMore();
                                                    },
                                                    child: Text(
                                                      "Load more",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
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
  String? itemId;
  Map? extras;
  String? itemImage;

  _ItemTemplate(this.itemName, this.itemId, this.extras, this.itemImage);
}
