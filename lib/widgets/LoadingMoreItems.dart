import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class LoadingMoreItems extends StatelessWidget {
  const LoadingMoreItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            color: Colors.teal,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        )),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        child: Text(
                          "Loading more items",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
